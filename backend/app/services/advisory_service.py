"""
Service layer for advisory pipeline control-plane operations.
"""

from __future__ import annotations

import hashlib
import logging
import re
from typing import Optional
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import and_
from sqlalchemy.orm import Session

from app.models.advisory_job import AdvisoryJob
from app.models.trip_advisory import TripAdvisory
from app.models.advisory_user_action import AdvisoryUserAction
from app.models.trip import Trip
from app.models.trip_metadata import TripMetadata

logger = logging.getLogger(__name__)


def _normalize_query(text: str | None) -> str:
    """Canonical form for hashing: strip, lowercase, collapse whitespace."""
    if not text:
        return ""
    return re.sub(r"\s+", " ", text.strip().lower())


def _compute_request_hash(job_type: str, query_text: str | None = None,
                           segment_id: str | None = None) -> str:
    """Deterministic SHA-256 for job idempotency."""
    if job_type == "on_demand":
        raw = f"on_demand:{_normalize_query(query_text)}"
    elif job_type == "location_trigger":
        raw = f"location_trigger:{segment_id or ''}"
    else:
        raw = job_type  # pre_trip
    return hashlib.sha256(raw.encode()).hexdigest()


class AdvisoryService:
    def __init__(self, db: Session):
        self.db = db

    # ── Job creation ──────────────────────────────────────────────

    def create_advisory_job(
        self,
        user_id: UUID,
        trip_id: UUID,
        job_type: str,
        query_text: str | None = None,
        trigger_payload: dict | None = None,
    ) -> AdvisoryJob:
        trip = self._get_trip_for_owner(trip_id=trip_id, user_id=user_id)

        segment_id = (trigger_payload or {}).get("segment_id")
        request_hash = _compute_request_hash(job_type, query_text, segment_id)

        # Location trigger coalescing: merge into existing active job
        if job_type == "location_trigger":
            existing = self._find_active_job(trip_id, job_type, request_hash)
            if existing:
                # Coalesce: append trigger payload into scrape_plan
                plan = existing.scrape_plan or {}
                triggers = plan.get("coalesced_triggers", [])
                if trigger_payload:
                    triggers.append(trigger_payload)
                plan["coalesced_triggers"] = triggers
                existing.scrape_plan = plan
                self.db.commit()
                self.db.refresh(existing)
                logger.info(
                    "[ADVISORY_JOB] coalesced trigger into job_id=%s trip_id=%s",
                    existing.id, trip_id,
                )
                return existing

        # Duplicate detection for other types
        existing = self._find_active_job(trip_id, job_type, request_hash)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={
                    "error": "duplicate_job",
                    "existing_job_id": str(existing.id),
                    "detail": f"An identical {job_type} advisory job is already active.",
                },
            )

        job = AdvisoryJob(
            user_id=user_id,
            trip_id=trip_id,
            status="queued",
            stage=None,
            progress=0.0,
            job_type=job_type,
            request_hash=request_hash,
            query_text=query_text,
            scrape_plan={"trigger_payload": trigger_payload} if trigger_payload else None,
            retry_count=0,
            max_retries=3,
            next_attempt_at=None,
        )
        self.db.add(job)
        self.db.commit()
        self.db.refresh(job)
        logger.info(
            "[ADVISORY_JOB] created job_id=%s trip_id=%s type=%s",
            job.id, trip_id, job_type,
        )
        return job

    # ── Queries ───────────────────────────────────────────────────

    def get_advisory_jobs(
        self,
        user_id: UUID,
        trip_id: UUID,
        status_filter: str | None = None,
        page: int = 1,
        page_size: int = 20,
    ) -> tuple[list[AdvisoryJob], int]:
        self._get_trip_for_owner(trip_id=trip_id, user_id=user_id)
        q = self.db.query(AdvisoryJob).filter(AdvisoryJob.trip_id == trip_id)
        if status_filter:
            q = q.filter(AdvisoryJob.status == status_filter)
        total = q.count()
        jobs = (
            q.order_by(AdvisoryJob.created_at.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
            .all()
        )
        return jobs, total

    def get_trip_advisories(
        self,
        user_id: UUID,
        trip_id: UUID,
        category: str | None = None,
        page: int = 1,
        page_size: int = 50,
    ) -> tuple[list[TripAdvisory], int]:
        self._get_trip_for_owner(trip_id=trip_id, user_id=user_id)
        q = self.db.query(TripAdvisory).filter(
            TripAdvisory.trip_id == trip_id,
            TripAdvisory.status.in_(["pending", "delivered"]),
        )
        if category:
            q = q.filter(TripAdvisory.category == category)
        total = q.count()
        advisories = (
            q.order_by(TripAdvisory.confidence_score.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
            .all()
        )
        return advisories, total

    # ── User actions ──────────────────────────────────────────────

    def record_user_action(
        self,
        user_id: UUID,
        advisory_id: UUID,
        action: str,
        action_metadata: dict | None = None,
    ) -> AdvisoryUserAction:
        advisory = (
            self.db.query(TripAdvisory)
            .filter(TripAdvisory.id == advisory_id)
            .first()
        )
        if not advisory:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Advisory not found",
            )
        if advisory.user_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not your advisory",
            )

        # Snapshot trip metadata at action time for preference learning
        metadata_snapshot = self._snapshot_trip_metadata(advisory.trip_id)

        user_action = AdvisoryUserAction(
            user_id=user_id,
            trip_id=advisory.trip_id,
            advisory_id=advisory_id,
            action=action,
            action_metadata=action_metadata,
            trip_metadata_snapshot=metadata_snapshot,
        )
        self.db.add(user_action)
        self.db.commit()
        self.db.refresh(user_action)
        logger.info(
            "[ADVISORY_ACTION] user=%s advisory=%s action=%s",
            user_id, advisory_id, action,
        )
        return user_action

    # ── Internals ─────────────────────────────────────────────────

    def _get_trip_for_owner(self, trip_id: UUID, user_id: UUID) -> Trip:
        trip = self.db.query(Trip).filter(Trip.id == trip_id).first()
        if not trip:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trip not found",
            )
        if trip.user_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not own this trip",
            )
        return trip

    def _find_active_job(
        self, trip_id: UUID, job_type: str, request_hash: str
    ) -> AdvisoryJob | None:
        return (
            self.db.query(AdvisoryJob)
            .filter(
                AdvisoryJob.trip_id == trip_id,
                AdvisoryJob.job_type == job_type,
                AdvisoryJob.request_hash == request_hash,
                AdvisoryJob.status.in_(["queued", "processing"]),
            )
            .with_for_update(skip_locked=True)
            .first()
        )

    def _snapshot_trip_metadata(self, trip_id: UUID) -> dict:
        meta = (
            self.db.query(TripMetadata)
            .filter(TripMetadata.trip_id == trip_id)
            .first()
        )
        if not meta:
            return {}
        return {
            "traveler_type": meta.traveler_type,
            "age_group": meta.age_group,
            "travel_style": meta.travel_style,
            "difficulty_level": meta.difficulty_level,
            "budget_category": meta.budget_category,
            "activity_focus": meta.activity_focus,
            "tags": meta.tags,
        }
