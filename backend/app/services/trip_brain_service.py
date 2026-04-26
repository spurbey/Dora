"""
Trip Brain Service — owns all mutations of trip_advisory_state.

Implements the canonical locking pattern from the plan:

    1. PREPARE (outside transaction): fetch from network (geocode, weather,
       Reddit) and build payloads in memory. No DB write yet.
    2. ENSURE brain row via idempotent INSERT ON CONFLICT DO NOTHING
       (self-heal — covers the "seed-on-create failed silently" case).
    3. BEGIN explicit transaction.
    4. SELECT ... FOR UPDATE the brain row.
    5. Apply changes via a SINGLE UPDATE statement — use jsonb_set /
       array_append / CASE guards so mutations are atomic at the SQL level.
    6. COMMIT. Invalidate Redis cache.

Callers (cycle worker, advisory worker, feedback endpoint, ignore sweep)
contend on row lock only for milliseconds. Any code path that wraps network
IO inside steps 3–6 is a bug; tests enforce this.
"""

from __future__ import annotations

import hashlib
import json
import logging
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Iterable, Optional
from uuid import UUID

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.config import settings
from app.models.advisory_user_action import AdvisoryUserAction
from app.models.route import Route
from app.models.trip import Trip
from app.models.trip_advisory import TripAdvisory
from app.models.trip_advisory_state import TripAdvisoryState
from app.models.trip_metadata import TripMetadata
from app.models.user_metadata import UserMetadata
from app.services.advisory_cache import advisory_cache
from app.services.geocoding_service import reverse_geocode
from app.services.route_sampler import (
    Sample,
    concatenate_legs,
    polyline_signature,
    project_gps_to_fraction,
    sample_polyline,
)
from app.services.trip_classifier import (
    cadence_for,
    classify,
    mode_for,
    shape_from_trip,
)

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Transaction helper
# ---------------------------------------------------------------------------


def _safe_tx(db: Session):
    """Return a context manager for a DB write block.

    If the session already has an active transaction (e.g. test harness wraps
    each test in a connection-level transaction), use a SAVEPOINT via
    ``begin_nested()``. Otherwise open a fresh transaction via ``begin()``.
    This avoids ``InvalidRequestError: a transaction is already begun`` in
    tests while still providing proper commit semantics in production.
    """
    if db.in_transaction():
        return db.begin_nested()
    return db.begin()


# ---------------------------------------------------------------------------
# Result types
# ---------------------------------------------------------------------------


@dataclass
class TargetContext:
    locality_key: str
    locality: Optional[str]
    region: Optional[str]
    country: Optional[str]
    center_lat: float
    center_lng: float
    mode: str  # "route" | "radius"
    sample_idx: Optional[int] = None  # only in route mode
    trip_metadata: dict = field(default_factory=dict)
    user_metadata: dict = field(default_factory=dict)
    recent_categories: dict = field(default_factory=dict)
    baseline_findings: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        return {
            "locality_key": self.locality_key,
            "locality": self.locality,
            "region": self.region,
            "country": self.country,
            "center_lat": self.center_lat,
            "center_lng": self.center_lng,
            "mode": self.mode,
            "sample_idx": self.sample_idx,
            "trip_metadata": self.trip_metadata,
            "user_metadata": self.user_metadata,
            "recent_categories": self.recent_categories,
            "baseline_findings": self.baseline_findings,
        }


@dataclass
class TargetDecision:
    """Returned by pick_next_target so callers can distinguish outcomes."""
    outcome: str  # "found" | "no_target" | "off_route"
    target: Optional[TargetContext] = None


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _now_utc() -> datetime:
    return datetime.now(timezone.utc)


def _metadata_snapshot(tm: Optional[TripMetadata]) -> dict:
    if tm is None:
        return {}
    return {
        "traveler_type": tm.traveler_type or [],
        "age_group": tm.age_group,
        "travel_style": tm.travel_style or [],
        "difficulty_level": tm.difficulty_level,
        "budget_category": tm.budget_category,
        "activity_focus": tm.activity_focus or [],
        "tags": getattr(tm, "tags", None) or [],
    }


def _user_metadata_snapshot(um: Optional[UserMetadata]) -> dict:
    if um is None:
        return {}
    return {
        "dietary_restrictions": um.dietary_restrictions or [],
        "budget_range": um.budget_range,
        "preferred_travel_style": um.preferred_travel_style or [],
        "dislikes": um.dislikes or [],
        "notification_enabled": um.notification_enabled,
        "advisory_quiet_hours": um.advisory_quiet_hours,
    }


def _route_legs_for_trip(db: Session, trip_id: UUID) -> list[Route]:
    return (
        db.query(Route)
        .filter(Route.trip_id == trip_id)
        .order_by(Route.order_in_trip.asc())
        .all()
    )


def _leg_distance_summaries(legs: Iterable[Route]) -> list[dict]:
    return [{"distance_km": leg.distance_km} for leg in legs]


# ---------------------------------------------------------------------------
# Service
# ---------------------------------------------------------------------------


class TripBrainService:
    """Mutates trip_advisory_state and owns advisory pipeline memory."""

    # ------------------------------------------------------------------
    # Construction / context
    # ------------------------------------------------------------------
    def __init__(self, db: Session):
        self.db = db

    # ------------------------------------------------------------------
    # ensure_brain — self-heal INSERT ON CONFLICT DO NOTHING
    # ------------------------------------------------------------------
    def ensure_brain(self, trip_id: UUID, user_id: UUID) -> TripAdvisoryState:
        """Insert a default brain row if one doesn't exist; return the current row.

        Uses INSERT ... ON CONFLICT DO NOTHING so concurrent inserts are
        idempotent.
        """
        self.db.execute(
            text(
                """
                INSERT INTO trip_advisory_state (trip_id, user_id)
                VALUES (:trip_id, :user_id)
                ON CONFLICT (trip_id) DO NOTHING
                """
            ),
            {"trip_id": str(trip_id), "user_id": str(user_id)},
        )
        self.db.commit()
        return (
            self.db.query(TripAdvisoryState)
            .filter(TripAdvisoryState.trip_id == trip_id)
            .one()
        )

    # ------------------------------------------------------------------
    # seed_on_trip_creation — light seed at trip creation time
    # ------------------------------------------------------------------
    async def seed_on_trip_creation(self, trip_id: UUID) -> TripAdvisoryState:
        """Prepare initial brain state from the trip + metadata + routes snapshot.

        Network-heavy Reddit seeding is deferred: we defer to the advisory
        worker by marking a scrape_plan.seed_only flag on a pre_trip job
        (caller may enqueue; this service stays pure of job scheduling).
        Route sampling + reverse geocoding of sample points happens here.
        """
        trip: Optional[Trip] = (
            self.db.query(Trip).filter(Trip.id == trip_id).one_or_none()
        )
        if trip is None:
            raise ValueError(f"seed_on_trip_creation: trip {trip_id} not found")

        tm = (
            self.db.query(TripMetadata)
            .filter(TripMetadata.trip_id == trip_id)
            .one_or_none()
        )
        um = (
            self.db.query(UserMetadata)
            .filter(UserMetadata.user_id == trip.user_id)
            .one_or_none()
        )
        legs = _route_legs_for_trip(self.db, trip_id)

        shape = shape_from_trip(
            trip_start_date=trip.start_date,
            trip_end_date=trip.end_date,
            routes=_leg_distance_summaries(legs),
        )
        trip_class = classify(shape)
        cadence = cadence_for(trip_class)
        mode = mode_for(trip_class)

        # Route sampling + per-sample reverse geocode (network — outside tx).
        samples_payload: dict = {
            "samples": [],
            "polyline_version": None,
            "sample_count": 0,
        }
        if mode == "route":
            combined = concatenate_legs([leg.route_geojson for leg in legs])
            if len(combined) >= 2:
                sig = polyline_signature(combined)
                samples = sample_polyline(
                    combined, count=settings.ADVISORY_SAMPLE_COUNT
                )
                resolved_samples = []
                for s in samples:
                    gc = await reverse_geocode(s.lat, s.lng)
                    resolved_samples.append(
                        {
                            "idx": s.idx,
                            "lat": s.lat,
                            "lng": s.lng,
                            "fraction": s.fraction,
                            "locality_key": gc.locality_key if gc else "",
                            "locality": gc.locality if gc else None,
                            "region": gc.region if gc else None,
                            "country": gc.country if gc else None,
                            "geocode_source": "mapbox" if gc else None,
                            "covered_at": None,
                        }
                    )
                samples_payload = {
                    "samples": resolved_samples,
                    "polyline_version": f"sha256:{sig}",
                    "sample_count": len(resolved_samples),
                }

        trip_meta_snap = _metadata_snapshot(tm)
        user_meta_snap = _user_metadata_snapshot(um)

        self.ensure_brain(trip_id, trip.user_id)

        with _safe_tx(self.db):
            self.db.execute(
                text(
                    """
                    UPDATE trip_advisory_state
                    SET lifecycle_state = 'seeded',
                        trip_class = :trip_class,
                        cadence_seconds = :cadence,
                        mode = :mode,
                        trip_metadata_snapshot = CAST(:tm_snap AS jsonb),
                        user_metadata_snapshot = CAST(:um_snap AS jsonb),
                        route_samples = CAST(:samples AS jsonb),
                        last_seed_at = now(),
                        last_seed_reason = 'initial',
                        updated_at = now()
                    WHERE trip_id = :trip_id
                    """
                ),
                {
                    "trip_id": str(trip_id),
                    "trip_class": trip_class,
                    "cadence": cadence,
                    "mode": mode,
                    "tm_snap": json.dumps(trip_meta_snap),
                    "um_snap": json.dumps(user_meta_snap),
                    "samples": json.dumps(samples_payload),
                },
            )

        await advisory_cache.invalidate_brain(str(trip_id))
        await advisory_cache.set_mode(str(trip_id), mode)

        return (
            self.db.query(TripAdvisoryState)
            .filter(TripAdvisoryState.trip_id == trip_id)
            .one()
        )

    # ------------------------------------------------------------------
    # enrich_on_tracking_start — flip to active, compute next_eligible_at
    # ------------------------------------------------------------------
    async def enrich_on_tracking_start(self, trip_id: UUID) -> TripAdvisoryState:
        """Live session started — flip brain to active + Mode B (live_companion).

        Phase machine:
            planning → live_companion (always, on first session start)
            paused   → preserved (manual pauses survive session start)
            live_companion → no-op (idempotent re-fires)
        """
        trip = self.db.query(Trip).filter(Trip.id == trip_id).one_or_none()
        if trip is None:
            raise ValueError(f"enrich_on_tracking_start: trip {trip_id} not found")

        brain = self.ensure_brain(trip_id, trip.user_id)
        cadence = int(brain.cadence_seconds or settings.ADVISORY_CYCLE_POLL_SECONDS)

        with _safe_tx(self.db):
            self.db.execute(
                text(
                    """
                    UPDATE trip_advisory_state
                    SET lifecycle_state = CASE
                            WHEN lifecycle_state IN ('paused', 'completed', 'errored')
                            THEN lifecycle_state
                            ELSE 'active'
                        END,
                        phase = CASE
                            WHEN phase = 'paused' THEN 'paused'
                            ELSE 'live_companion'
                        END,
                        last_phase_change_at = CASE
                            WHEN phase IN ('planning', NULL) THEN now()
                            ELSE last_phase_change_at
                        END,
                        next_eligible_at = now() + make_interval(secs => :cadence),
                        updated_at = now()
                    WHERE trip_id = :trip_id
                    """
                ),
                {"trip_id": str(trip_id), "cadence": cadence},
            )

        await advisory_cache.invalidate_brain(str(trip_id))
        return (
            self.db.query(TripAdvisoryState)
            .filter(TripAdvisoryState.trip_id == trip_id)
            .one()
        )

    # ------------------------------------------------------------------
    # reseed — debounced; preserves advised_* and streak
    # ------------------------------------------------------------------
    async def reseed(
        self, trip_id: UUID, reasons: list[str]
    ) -> TripAdvisoryState:
        if not reasons:
            reasons = ["manual"]

        trip = self.db.query(Trip).filter(Trip.id == trip_id).one_or_none()
        if trip is None:
            raise ValueError(f"reseed: trip {trip_id} not found")

        brain = self.ensure_brain(trip_id, trip.user_id)

        # Debounce check — within window, queue reasons and return early.
        if brain.last_seed_at:
            elapsed = (_now_utc() - brain.last_seed_at).total_seconds()
            if elapsed < settings.ADVISORY_RESEED_MIN_INTERVAL_SECONDS:
                with _safe_tx(self.db):
                    # Append reasons with dedupe guard.
                    self.db.execute(
                        text(
                            """
                            UPDATE trip_advisory_state
                            SET pending_reseed_reasons = (
                                SELECT ARRAY(
                                    SELECT DISTINCT unnest(
                                        pending_reseed_reasons || CAST(:reasons AS text[])
                                    )
                                )
                            ),
                                updated_at = now()
                            WHERE trip_id = :trip_id
                            """
                        ),
                        {
                            "trip_id": str(trip_id),
                            "reasons": "{" + ",".join(reasons) + "}",
                        },
                    )
                await advisory_cache.invalidate_brain(str(trip_id))
                return (
                    self.db.query(TripAdvisoryState)
                    .filter(TripAdvisoryState.trip_id == trip_id)
                    .one()
                )

        # Outside the debounce window — run a fresh seed (re-classify,
        # re-sample, re-geocode). Preserves advised_*, ignore_streak,
        # no_pick_attempts by not touching those columns.
        tm = (
            self.db.query(TripMetadata)
            .filter(TripMetadata.trip_id == trip_id)
            .one_or_none()
        )
        um = (
            self.db.query(UserMetadata)
            .filter(UserMetadata.user_id == trip.user_id)
            .one_or_none()
        )
        legs = _route_legs_for_trip(self.db, trip_id)
        shape = shape_from_trip(
            trip_start_date=trip.start_date,
            trip_end_date=trip.end_date,
            routes=_leg_distance_summaries(legs),
        )
        trip_class = classify(shape)
        cadence = cadence_for(trip_class)
        mode = mode_for(trip_class)

        samples_payload: dict = {
            "samples": [],
            "polyline_version": None,
            "sample_count": 0,
        }
        if mode == "route":
            combined = concatenate_legs([leg.route_geojson for leg in legs])
            if len(combined) >= 2:
                sig = polyline_signature(combined)
                samples = sample_polyline(
                    combined, count=settings.ADVISORY_SAMPLE_COUNT
                )
                resolved = []
                for s in samples:
                    gc = await reverse_geocode(s.lat, s.lng)
                    resolved.append(
                        {
                            "idx": s.idx,
                            "lat": s.lat,
                            "lng": s.lng,
                            "fraction": s.fraction,
                            "locality_key": gc.locality_key if gc else "",
                            "locality": gc.locality if gc else None,
                            "region": gc.region if gc else None,
                            "country": gc.country if gc else None,
                            "geocode_source": "mapbox" if gc else None,
                            "covered_at": None,
                        }
                    )
                samples_payload = {
                    "samples": resolved,
                    "polyline_version": f"sha256:{sig}",
                    "sample_count": len(resolved),
                }

        trip_meta_snap = _metadata_snapshot(tm)
        user_meta_snap = _user_metadata_snapshot(um)
        reason = "route_changed" if "route_changed" in reasons else reasons[0]

        with _safe_tx(self.db):
            self.db.execute(
                text(
                    """
                    UPDATE trip_advisory_state
                    SET trip_class = :trip_class,
                        cadence_seconds = :cadence,
                        mode = :mode,
                        trip_metadata_snapshot = CAST(:tm_snap AS jsonb),
                        user_metadata_snapshot = CAST(:um_snap AS jsonb),
                        route_samples = CAST(:samples AS jsonb),
                        pending_reseed_reasons = '{}'::text[],
                        last_seed_at = now(),
                        last_seed_reason = :reason,
                        updated_at = now()
                    WHERE trip_id = :trip_id
                    """
                ),
                {
                    "trip_id": str(trip_id),
                    "trip_class": trip_class,
                    "cadence": cadence,
                    "mode": mode,
                    "tm_snap": json.dumps(trip_meta_snap),
                    "um_snap": json.dumps(user_meta_snap),
                    "samples": json.dumps(samples_payload),
                    "reason": reason,
                },
            )

        await advisory_cache.invalidate_brain(str(trip_id))
        await advisory_cache.set_mode(str(trip_id), mode)

        return (
            self.db.query(TripAdvisoryState)
            .filter(TripAdvisoryState.trip_id == trip_id)
            .one()
        )

    # ------------------------------------------------------------------
    # pick_next_target — cycle worker asks "what's next?"
    # ------------------------------------------------------------------
    async def pick_next_target(self, trip_id: UUID) -> TargetDecision:
        trip = self.db.query(Trip).filter(Trip.id == trip_id).one_or_none()
        if trip is None:
            return TargetDecision(outcome="no_target")

        brain = self.ensure_brain(trip_id, trip.user_id)
        advised = set(brain.advised_locality_keys or [])
        mode = brain.mode

        if mode == "route":
            return await self._pick_next_route_target(
                trip_id=trip_id, brain=brain, advised=advised
            )
        if mode == "radius":
            return await self._pick_next_radius_target(
                trip_id=trip_id, brain=brain, advised=advised
            )
        return TargetDecision(outcome="no_target")

    async def _pick_next_route_target(
        self,
        *,
        trip_id: UUID,
        brain: TripAdvisoryState,
        advised: set[str],
    ) -> TargetDecision:
        route_samples = brain.route_samples or {}
        samples = route_samples.get("samples") or []
        if not samples:
            return TargetDecision(outcome="no_target")

        # Latest GPS point.
        row = self.db.execute(
            text(
                """
                SELECT latitude, longitude
                FROM trip_route_raw_point
                WHERE trip_server_id = :trip_id
                  AND captured_at >= now() - interval '10 minutes'
                ORDER BY captured_at DESC
                LIMIT 1
                """
            ),
            {"trip_id": str(trip_id)},
        ).fetchone()
        if row is None:
            return TargetDecision(outcome="no_target")

        gps_lat, gps_lng = float(row[0]), float(row[1])

        # Off-route check via persisted route_geom geography, nearest leg.
        off_row = self.db.execute(
            text(
                """
                SELECT ST_Distance(
                    ST_SetSRID(ST_MakePoint(:gps_lng, :gps_lat), 4326)::geography,
                    route_geom
                ) AS dist_m
                FROM routes
                WHERE trip_id = :trip_id
                  AND route_geom IS NOT NULL
                ORDER BY dist_m ASC
                LIMIT 1
                """
            ),
            {"trip_id": str(trip_id), "gps_lat": gps_lat, "gps_lng": gps_lng},
        ).fetchone()
        if off_row is not None:
            dist_m = float(off_row[0]) if off_row[0] is not None else 0.0
            if dist_m > settings.ADVISORY_OFF_ROUTE_THRESHOLD_METERS:
                return TargetDecision(outcome="off_route")

        # Project GPS onto the concatenated polyline to get current fraction.
        legs = _route_legs_for_trip(self.db, trip_id)
        combined = concatenate_legs([leg.route_geojson for leg in legs])
        progress = project_gps_to_fraction(combined, gps_lat, gps_lng) or 0.0

        # Pick first uncovered sample at or past current progress whose
        # locality hasn't been advised yet.
        for s in samples:
            try:
                if s.get("covered_at"):
                    continue
                if s.get("fraction", 0.0) < progress - 0.01:
                    continue
                lk = s.get("locality_key") or ""
                if not lk:
                    continue
                if lk in advised:
                    continue
                return TargetDecision(
                    outcome="found",
                    target=TargetContext(
                        locality_key=lk,
                        locality=s.get("locality"),
                        region=s.get("region"),
                        country=s.get("country"),
                        center_lat=float(s["lat"]),
                        center_lng=float(s["lng"]),
                        mode="route",
                        sample_idx=s.get("idx"),
                        trip_metadata=dict(brain.trip_metadata_snapshot or {}),
                        user_metadata=dict(brain.user_metadata_snapshot or {}),
                        recent_categories=dict(brain.recent_categories or {}),
                        baseline_findings=dict(brain.baseline_findings or {}),
                    ),
                )
            except (TypeError, ValueError, KeyError):
                continue

        return TargetDecision(outcome="no_target")

    async def _pick_next_radius_target(
        self,
        *,
        trip_id: UUID,
        brain: TripAdvisoryState,
        advised: set[str],
    ) -> TargetDecision:
        # Prefer Redis centroid buffer; fall back to DB aggregation.
        points = await advisory_cache.get_centroid_points(str(trip_id))
        if points:
            avg_lat = sum(p[1] for p in points) / len(points)
            avg_lng = sum(p[2] for p in points) / len(points)
        else:
            row = self.db.execute(
                text(
                    """
                    WITH recent AS (
                        SELECT latitude, longitude
                        FROM trip_route_raw_point
                        WHERE trip_server_id = :trip_id
                          AND captured_at >= now() - make_interval(
                              secs => :window_secs
                          )
                          AND accuracy_m <= 100
                        ORDER BY captured_at DESC
                        LIMIT 500
                    )
                    SELECT
                        AVG(latitude), AVG(longitude), COUNT(*),
                        COALESCE(
                            (
                                SELECT MAX(
                                    ST_Distance(
                                        ST_SetSRID(
                                            ST_MakePoint(r.longitude, r.latitude),
                                            4326
                                        )::geography,
                                        ST_SetSRID(
                                            ST_MakePoint(
                                                (SELECT AVG(longitude) FROM recent),
                                                (SELECT AVG(latitude) FROM recent)
                                            ),
                                            4326
                                        )::geography
                                    )
                                ) FROM recent r
                            ),
                            0
                        ) AS max_dispersion_m
                    FROM recent
                    """
                ),
                {
                    "trip_id": str(trip_id),
                    "window_secs": settings.ADVISORY_CENTROID_WINDOW_SECONDS,
                },
            ).fetchone()
            if row is None or row[0] is None:
                return TargetDecision(outcome="no_target")
            n = int(row[2] or 0)
            max_disp = float(row[3] or 0.0)
            if n < 5 or max_disp > 5000:
                return TargetDecision(outcome="no_target")
            avg_lat, avg_lng = float(row[0]), float(row[1])

        gc = await reverse_geocode(avg_lat, avg_lng)
        if gc is None or not gc.locality_key:
            return TargetDecision(outcome="no_target")
        if gc.locality_key in advised:
            return TargetDecision(outcome="no_target")

        return TargetDecision(
            outcome="found",
            target=TargetContext(
                locality_key=gc.locality_key,
                locality=gc.locality,
                region=gc.region,
                country=gc.country,
                center_lat=gc.center_lat,
                center_lng=gc.center_lng,
                mode="radius",
                sample_idx=None,
                trip_metadata=dict(brain.trip_metadata_snapshot or {}),
                user_metadata=dict(brain.user_metadata_snapshot or {}),
                recent_categories=dict(brain.recent_categories or {}),
                baseline_findings=dict(brain.baseline_findings or {}),
            ),
        )

    # ------------------------------------------------------------------
    # apply_feedback — streak math with defense-in-depth on implicit_ignore
    # ------------------------------------------------------------------
    def apply_feedback(
        self, advisory_id: UUID, action_type: str
    ) -> Optional[TripAdvisoryState]:
        """Record user feedback's effect on the trip brain.

        action_type is either one of the explicit TripAdvisory action
        enum values (dismissed, liked, saved, acted_on, converted_to_place)
        or the special value 'implicit_ignore' fired by the ignore sweep.
        """
        advisory = (
            self.db.query(TripAdvisory)
            .filter(TripAdvisory.id == advisory_id)
            .one_or_none()
        )
        if advisory is None:
            return None

        trip_id = advisory.trip_id

        # Defense-in-depth: if this is an implicit_ignore call and an
        # explicit action now exists on the advisory (race with the sweep's
        # NOT EXISTS guard), skip.
        if action_type == "implicit_ignore":
            has_action = (
                self.db.query(AdvisoryUserAction.id)
                .filter(AdvisoryUserAction.advisory_id == advisory_id)
                .first()
            )
            if has_action is not None:
                return None

        brain = self.ensure_brain(trip_id, advisory.user_id)
        is_explicit = action_type != "implicit_ignore"

        with _safe_tx(self.db):
            if is_explicit:
                # Reset streak; implicit-resume if paused due to inactivity.
                self.db.execute(
                    text(
                        """
                        UPDATE trip_advisory_state
                        SET ignore_streak = 0,
                            lifecycle_state = CASE
                                WHEN lifecycle_state = 'paused'
                                 AND paused_reason = 'inactivity'
                                THEN 'active'
                                ELSE lifecycle_state
                            END,
                            paused_reason = CASE
                                WHEN lifecycle_state = 'paused'
                                 AND paused_reason = 'inactivity'
                                THEN NULL
                                ELSE paused_reason
                            END,
                            paused_at = CASE
                                WHEN lifecycle_state = 'paused'
                                 AND paused_reason = 'inactivity'
                                THEN NULL
                                ELSE paused_at
                            END,
                            updated_at = now()
                        WHERE trip_id = :trip_id
                        """
                    ),
                    {"trip_id": str(trip_id)},
                )
            else:
                # Increment; pause when threshold reached.
                self.db.execute(
                    text(
                        """
                        UPDATE trip_advisory_state
                        SET ignore_streak = ignore_streak + 1,
                            lifecycle_state = CASE
                                WHEN ignore_streak + 1 >= :threshold
                                 AND lifecycle_state = 'active'
                                THEN 'paused'
                                ELSE lifecycle_state
                            END,
                            paused_reason = CASE
                                WHEN ignore_streak + 1 >= :threshold
                                 AND lifecycle_state = 'active'
                                THEN 'inactivity'
                                ELSE paused_reason
                            END,
                            paused_at = CASE
                                WHEN ignore_streak + 1 >= :threshold
                                 AND lifecycle_state = 'active'
                                THEN now()
                                ELSE paused_at
                            END,
                            updated_at = now()
                        WHERE trip_id = :trip_id
                        """
                    ),
                    {
                        "trip_id": str(trip_id),
                        "threshold": settings.ADVISORY_IGNORE_PAUSE_THRESHOLD,
                    },
                )

        return (
            self.db.query(TripAdvisoryState)
            .filter(TripAdvisoryState.trip_id == trip_id)
            .one()
        )

    # ------------------------------------------------------------------
    # mark_cycle_outcome — single entry point for every cycle terminus
    # ------------------------------------------------------------------
    async def mark_cycle_outcome(
        self,
        trip_id: UUID,
        outcome: str,
        *,
        target: Optional[TargetContext] = None,
        advisory_ids: Optional[list[UUID]] = None,
        poi_place_ids: Optional[list[str]] = None,
        categories_delivered: Optional[list[str]] = None,
    ) -> TripAdvisoryState:
        """See plan: 5 outcomes (delivered|no_pick|failed|no_target|off_route).

        Never called with network IO outstanding — caller must finish all
        scraping / LLM work and assemble metadata first.

        IMPORTANT — transaction boundary:
            We deliberately do NOT use ``begin_nested`` (savepoint) here.
            Earlier prod runs showed cycle jobs churning every 2 minutes
            because the savepoint committed but the outer transaction was
            then rolled back at session-close, undoing cadence advancement.
            We now run the UPDATE in the outer transaction the session
            already autobegun, then commit explicitly. Callers in cycle
            worker / advisory worker do not commit after, by contract.
        """
        valid = {"delivered", "no_pick", "failed", "no_target", "off_route"}
        if outcome not in valid:
            raise ValueError(f"invalid outcome: {outcome}")

        trip = self.db.query(Trip).filter(Trip.id == trip_id).one_or_none()
        if trip is None:
            raise ValueError(f"mark_cycle_outcome: trip {trip_id} not found")

        brain = self.ensure_brain(trip_id, trip.user_id)
        cadence = int(brain.cadence_seconds or 3600)
        locality_key = target.locality_key if target else None

        if outcome == "delivered":
            if not locality_key:
                raise ValueError("delivered outcome requires target.locality_key")
            new_pois = [p for p in (poi_place_ids or []) if p]
            self.db.execute(
                text(
                    """
                    UPDATE trip_advisory_state
                    SET
                        advised_locality_keys = CASE
                            WHEN NOT (:key = ANY(COALESCE(advised_locality_keys, '{}'::text[])))
                             AND COALESCE(array_length(COALESCE(advised_locality_keys, '{}'::text[]), 1), 0)
                                  < :max_localities
                            THEN array_append(COALESCE(advised_locality_keys, '{}'::text[]), :key)
                            ELSE COALESCE(advised_locality_keys, '{}'::text[])
                        END,
                        advised_poi_place_ids = (
                            SELECT ARRAY(
                                SELECT DISTINCT unnest(
                                    COALESCE(advised_poi_place_ids, '{}'::text[])
                                    || CAST(:new_pois AS text[])
                                )
                            )
                        ),
                        no_pick_attempts = COALESCE(no_pick_attempts, '{}'::jsonb) - :key,
                        recent_categories = CAST(:new_recent AS jsonb),
                        last_cycle_at = now(),
                        next_eligible_at = now()
                            + make_interval(secs => :cadence),
                        updated_at = now()
                    WHERE trip_id = :trip_id
                    """
                ),
                {
                    "trip_id": str(trip_id),
                    "key": locality_key,
                    "new_pois": "{" + ",".join(new_pois) + "}",
                    "cadence": cadence,
                    "max_localities": settings.MAX_ADVISED_LOCALITIES_PER_TRIP,
                    "new_recent": json.dumps(
                        self._bump_categories(
                            dict(brain.recent_categories or {}),
                            categories_delivered or [],
                        )
                    ),
                },
            )

        elif outcome == "no_pick":
            if not locality_key:
                raise ValueError("no_pick outcome requires target.locality_key")
            budget = settings.ADVISORY_NO_PICK_RETRY_BUDGET
            current_attempt = self.db.execute(
                text(
                    """
                    SELECT COALESCE(
                        (COALESCE(no_pick_attempts, '{}'::jsonb)->>:key)::int,
                        0
                    ) AS attempts
                    FROM trip_advisory_state
                    WHERE trip_id = :trip_id
                    FOR UPDATE
                    """
                ),
                {"trip_id": str(trip_id), "key": locality_key},
            ).scalar_one()
            next_attempt = int(current_attempt) + 1
            self.db.execute(
                text(
                    """
                    UPDATE trip_advisory_state
                    SET
                        no_pick_attempts = jsonb_set(
                            COALESCE(no_pick_attempts, '{}'::jsonb),
                            ARRAY[:key],
                            to_jsonb(:next_attempt),
                            true
                        ),
                        advised_locality_keys = CASE
                            WHEN :next_attempt >= :budget
                             AND NOT (:key = ANY(COALESCE(advised_locality_keys, '{}'::text[])))
                            THEN array_append(COALESCE(advised_locality_keys, '{}'::text[]), :key)
                            ELSE COALESCE(advised_locality_keys, '{}'::text[])
                        END,
                        last_cycle_at = now(),
                        next_eligible_at = now()
                            + make_interval(secs => :cadence),
                        updated_at = now()
                    WHERE trip_id = :trip_id
                    """
                ),
                {
                    "trip_id": str(trip_id),
                    "key": locality_key,
                    "next_attempt": next_attempt,
                    "budget": budget,
                    "cadence": cadence,
                },
            )

        else:  # failed | no_target | off_route — retry backoff, no memory flip
            self.db.execute(
                text(
                    """
                    UPDATE trip_advisory_state
                    SET last_cycle_at = now(),
                        next_eligible_at = now()
                            + make_interval(secs => :backoff),
                        updated_at = now()
                    WHERE trip_id = :trip_id
                    """
                ),
                {
                    "trip_id": str(trip_id),
                    "backoff": settings.ADVISORY_RETRY_BACKOFF_SECONDS,
                },
            )

        # Critical: commit the outer transaction. Without this, callers that
        # use a session context manager (`with SessionLocal() as db:`) get
        # the entire transaction rolled back at scope exit — which is exactly
        # what was producing the every-2-min cycle churn.
        self.db.commit()
        await advisory_cache.invalidate_brain(str(trip_id))
        return (
            self.db.query(TripAdvisoryState)
            .filter(TripAdvisoryState.trip_id == trip_id)
            .one()
        )

    @staticmethod
    def _bump_categories(current: dict, added: Iterable[str]) -> dict:
        out = dict(current)
        for cat in added:
            if not cat:
                continue
            out[cat] = int(out.get(cat, 0)) + 1
        # Keep a rolling window of 10 entries max to bound JSON size.
        if len(out) > 10:
            trimmed = sorted(out.items(), key=lambda kv: kv[1], reverse=True)[:10]
            out = dict(trimmed)
        return out

    # ------------------------------------------------------------------
    # BrightData atomic counter — called by advisory_worker before GMaps
    # ------------------------------------------------------------------
    def try_increment_brightdata(
        self, trip_id: UUID, n: int = 1
    ) -> Optional[int]:
        """Atomically check and increment brightdata_call_count.

        Returns the new counter value on success, or None if cap breached.
        Callers must avoid dispatching BrightData requests on None.
        """
        cap = settings.BRIGHTDATA_MAX_CALLS_PER_TRIP
        row = self.db.execute(
            text(
                """
                UPDATE trip_advisory_state
                SET brightdata_call_count = brightdata_call_count + :n,
                    updated_at = now()
                WHERE trip_id = :trip_id
                  AND brightdata_call_count + :n <= :cap
                RETURNING brightdata_call_count
                """
            ),
            {"trip_id": str(trip_id), "n": n, "cap": cap},
        ).fetchone()
        self.db.commit()
        if row is None:
            return None
        return int(row[0])

    # ------------------------------------------------------------------
    # lifecycle transitions
    # ------------------------------------------------------------------
    def pause(self, trip_id: UUID, *, reason: str) -> TripAdvisoryState:
        if reason not in {"inactivity", "user", "error", "trip_ended"}:
            raise ValueError(f"invalid pause reason: {reason}")
        with _safe_tx(self.db):
            self.db.execute(
                text(
                    """
                    UPDATE trip_advisory_state
                    SET lifecycle_state = 'paused',
                        paused_reason = :reason,
                        paused_at = now(),
                        updated_at = now()
                    WHERE trip_id = :trip_id
                    """
                ),
                {"trip_id": str(trip_id), "reason": reason},
            )
        return (
            self.db.query(TripAdvisoryState)
            .filter(TripAdvisoryState.trip_id == trip_id)
            .one()
        )

    def resume(
        self, trip_id: UUID, *, explicit_user_action: bool = False
    ) -> TripAdvisoryState:
        """Resume a paused brain.

        If the brain was paused with reason='user', resume requires
        explicit_user_action=True (the /advisory/resume endpoint sets this).
        """
        brain = (
            self.db.query(TripAdvisoryState)
            .filter(TripAdvisoryState.trip_id == trip_id)
            .one_or_none()
        )
        if brain is None:
            raise ValueError(f"resume: no brain for trip {trip_id}")
        if brain.lifecycle_state != "paused":
            return brain
        if brain.paused_reason == "user" and not explicit_user_action:
            return brain

        with _safe_tx(self.db):
            self.db.execute(
                text(
                    """
                    UPDATE trip_advisory_state
                    SET lifecycle_state = 'active',
                        paused_reason = NULL,
                        paused_at = NULL,
                        ignore_streak = 0,
                        next_eligible_at = now(),
                        updated_at = now()
                    WHERE trip_id = :trip_id
                    """
                ),
                {"trip_id": str(trip_id)},
            )
        return (
            self.db.query(TripAdvisoryState)
            .filter(TripAdvisoryState.trip_id == trip_id)
            .one()
        )

    def complete(self, trip_id: UUID) -> TripAdvisoryState:
        with _safe_tx(self.db):
            self.db.execute(
                text(
                    """
                    UPDATE trip_advisory_state
                    SET lifecycle_state = 'completed',
                        next_eligible_at = NULL,
                        updated_at = now()
                    WHERE trip_id = :trip_id
                    """
                ),
                {"trip_id": str(trip_id)},
            )
        return (
            self.db.query(TripAdvisoryState)
            .filter(TripAdvisoryState.trip_id == trip_id)
            .one()
        )
