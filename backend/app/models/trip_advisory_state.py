"""
TripAdvisoryState — the per-trip "brain" that drives the advisory pipeline.

Durable 1:1 record with trips. Owns all runtime state for the cycle engine:
lifecycle, cadence, mode, route samples, feedback streak, dedupe arrays,
pending reseed reasons, BrightData cost counter. Redis caches hot reads.

All mutations go through trip_brain_service using the
prepare-outside-transaction / SELECT FOR UPDATE / single-UPDATE pattern.
"""

from sqlalchemy import (
    CheckConstraint,
    Column,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    String,
)
from sqlalchemy.dialects.postgresql import ARRAY, JSONB, UUID, TEXT
from sqlalchemy.sql import func, text

from app.database import Base


class TripAdvisoryState(Base):
    """Per-trip advisory runtime state ("brain").

    Lifecycle:
        seeded → active → paused → completed
        seeded → active → errored
    """

    __tablename__ = "trip_advisory_state"

    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        primary_key=True,
        comment="Owner trip",
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="Denormalized owner for query paths",
    )

    lifecycle_state = Column(
        String(20),
        nullable=False,
        server_default=text("'seeded'"),
        comment="seeded|active|paused|completed|errored",
    )
    trip_class = Column(
        String(30),
        nullable=False,
        server_default=text("'unclassified'"),
        comment="long_road|short_road|intra_city|day_trip|"
        "multi_day_leisure|unclassified",
    )
    cadence_seconds = Column(
        Integer,
        nullable=False,
        server_default=text("3600"),
        comment="Resolved cadence in seconds (rule table, overridable)",
    )
    mode = Column(
        String(10),
        nullable=False,
        server_default=text("'route'"),
        comment="route|radius",
    )

    trip_metadata_snapshot = Column(
        JSONB,
        nullable=False,
        server_default=text("'{}'::jsonb"),
        comment="Frozen TripMetadata copy at seed time",
    )
    user_metadata_snapshot = Column(
        JSONB,
        nullable=False,
        server_default=text("'{}'::jsonb"),
        comment="Frozen UserMetadata copy at seed time",
    )
    route_samples = Column(
        JSONB,
        nullable=False,
        server_default=text("'{}'::jsonb"),
        comment="Route sampling state: {samples:[...], polyline_version, sample_count}",
    )
    baseline_findings = Column(
        JSONB,
        nullable=False,
        server_default=text("'{}'::jsonb"),
        comment="Aggregated Reddit seed findings; persistent LLM context",
    )
    recent_categories = Column(
        JSONB,
        nullable=False,
        server_default=text("'{}'::jsonb"),
        comment="Rolling category counter {food:3, hotel:1, warning:2}",
    )

    last_seed_at = Column(
        DateTime(timezone=True),
        nullable=True,
        comment="When Reddit seed + sampling last ran",
    )
    last_seed_reason = Column(
        String(30),
        nullable=True,
        comment="initial|route_changed|metadata_changed|manual",
    )
    last_cycle_at = Column(
        DateTime(timezone=True),
        nullable=True,
        comment="Most recent advisory cycle run",
    )
    next_eligible_at = Column(
        DateTime(timezone=True),
        nullable=True,
        comment="When cycle worker may fire next",
    )

    ignore_streak = Column(
        Integer,
        nullable=False,
        server_default=text("0"),
        comment="Consecutive no-action count (3 ⇒ pause)",
    )

    advised_locality_keys = Column(
        ARRAY(TEXT()),
        nullable=False,
        server_default=text("'{}'::text[]"),
        comment="country:region:locality slugs covered — forever-for-trip",
    )
    advised_poi_place_ids = Column(
        ARRAY(TEXT()),
        nullable=False,
        server_default=text("'{}'::text[]"),
        comment="GMaps place_ids delivered — forever-for-trip",
    )
    pending_reseed_reasons = Column(
        ARRAY(TEXT()),
        nullable=False,
        server_default=text("'{}'::text[]"),
        comment="Reasons queued during reseed debounce; flushed as a union",
    )
    no_pick_attempts = Column(
        JSONB,
        nullable=False,
        server_default=text("'{}'::jsonb"),
        comment="{locality_key: count}; locality covered only after budget reached",
    )

    brightdata_call_count = Column(
        Integer,
        nullable=False,
        server_default=text("0"),
        comment="BrightData calls accumulated for this trip",
    )

    paused_reason = Column(
        String(30),
        nullable=True,
        comment="inactivity|user|error|trip_ended when lifecycle=paused. "
        "Only 'inactivity' permits implicit resume on explicit action.",
    )
    paused_at = Column(
        DateTime(timezone=True),
        nullable=True,
    )

    # Mode A/B phase machine. Distinct from lifecycle_state — phase is about
    # which content sources/cadences apply, lifecycle is about whether the
    # cycle worker should run at all.
    #   planning        → trip created, no live session yet. Mode A
    #                     (Reddit primary, GMaps off, slow cadence).
    #   live_companion  → V2 session started. Mode B (GMaps primary, fast
    #                     event-driven cadence).
    #   paused          → catch-all for "don't fire even on triggers"
    #                     (e.g., user manually paused).
    phase = Column(
        String(20),
        nullable=False,
        server_default=text("'planning'"),
        comment="planning|live_companion|paused — drives which stage path "
        "the advisory worker runs.",
    )
    locality_confidence = Column(
        JSONB,
        nullable=False,
        server_default=text("'{}'::jsonb"),
        comment="Per-(locality, intent) cached signal strength used by "
        "clarify_intent. Shape: {'khandala': {'food_tip': 0.85, "
        "'_signals': {'reddit': 7, 'gmaps': 4}}, ...}",
    )
    last_phase_change_at = Column(
        DateTime(timezone=True),
        nullable=True,
    )

    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )

    __table_args__ = (
        CheckConstraint(
            "lifecycle_state IN "
            "('seeded', 'active', 'paused', 'completed', 'errored')",
            name="check_trip_advisory_state_lifecycle",
        ),
        CheckConstraint(
            "mode IN ('route', 'radius')",
            name="check_trip_advisory_state_mode",
        ),
        CheckConstraint(
            "trip_class IN ('long_road', 'short_road', 'intra_city', "
            "'day_trip', 'multi_day_leisure', 'unclassified')",
            name="check_trip_advisory_state_trip_class",
        ),
        CheckConstraint(
            "paused_reason IS NULL OR paused_reason IN "
            "('inactivity', 'user', 'error', 'trip_ended')",
            name="check_trip_advisory_state_paused_reason",
        ),
        CheckConstraint(
            "ignore_streak >= 0",
            name="check_trip_advisory_state_ignore_streak_nonneg",
        ),
        CheckConstraint(
            "cadence_seconds > 0",
            name="check_trip_advisory_state_cadence_positive",
        ),
        CheckConstraint(
            "brightdata_call_count >= 0",
            name="check_trip_advisory_state_brightdata_nonneg",
        ),
        CheckConstraint(
            "phase IN ('planning', 'live_companion', 'paused')",
            name="ck_trip_advisory_state_phase",
        ),
        # Cycle worker scan path — filter by lifecycle, order by due time.
        Index(
            "idx_trip_advisory_state_active_due",
            "lifecycle_state",
            "next_eligible_at",
        ),
        Index("idx_trip_advisory_state_user", "user_id"),
        Index(
            "idx_trip_advisory_state_advised_localities",
            "advised_locality_keys",
            postgresql_using="gin",
        ),
        Index(
            "idx_trip_advisory_state_advised_pois",
            "advised_poi_place_ids",
            postgresql_using="gin",
        ),
    )

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return (
            f"<TripAdvisoryState(trip_id={self.trip_id}, "
            f"lifecycle={self.lifecycle_state}, mode={self.mode})>"
        )
