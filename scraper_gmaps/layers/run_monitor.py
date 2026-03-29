"""
run_monitor.py — Layer 9: Outcome-based monitoring and schema drift detection

KEY INSIGHT: Don't just catch exceptions.
Alert when: captured_count vs extracted_count diverge by > threshold.
This is the only reliable signal that proto field tags have shifted.
"""
import os, json, asyncio
from dataclasses import dataclass, field, asdict
from datetime import datetime
from typing import List, Optional
from loguru import logger
from playwright.async_api import Page

from .models import RunResult


DIVERGENCE_THRESHOLD = float(os.getenv("ALERT_DIVERGENCE_THRESHOLD", "0.05"))
SNAPSHOT_ENABLED = os.getenv("SNAPSHOT_ENABLED", "true").lower() == "true"


@dataclass
class RunMetrics:
    place_id: str
    run_id: str
    started_at: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    finished_at: Optional[str] = None

    # Counts at each layer
    network_captured: int = 0       # responses intercepted by sniffer
    proto_extracted: int = 0        # reviews from proto decoder
    dom_extracted: int = 0          # reviews from DOM fallback
    total_extracted: int = 0        # after merge
    stored: int = 0                 # after dedupe upsert
    ui_total: Optional[int] = None  # total shown in Maps UI

    # Signals
    challenge_detected: bool = False
    challenge_type: str = ""
    session_rotated: bool = False
    proto_field_drift: bool = False  # True if extraction << capture
    errors: List[str] = field(default_factory=list)

    duration_seconds: float = 0.0


class RunMonitor:
    def __init__(self, snapshots_dir: str = "data/snapshots"):
        self._snapshots_dir = snapshots_dir
        self._screenshots_dir = "data/screenshots"
        os.makedirs(snapshots_dir, exist_ok=True)
        os.makedirs(self._screenshots_dir, exist_ok=True)
        self._metrics: Optional[RunMetrics] = None

    def start_run(self, place_id: str) -> RunMetrics:
        import uuid
        self._metrics = RunMetrics(
            place_id=place_id,
            run_id=str(uuid.uuid4())[:8],
        )
        logger.info(f"[monitor] Run started: {self._metrics.run_id} for {place_id}")
        return self._metrics

    def finish_run(self, metrics: RunMetrics) -> RunResult:
        metrics.finished_at = datetime.utcnow().isoformat()
        started = datetime.fromisoformat(metrics.started_at)
        finished = datetime.fromisoformat(metrics.finished_at)
        metrics.duration_seconds = (finished - started).total_seconds()

        # Schema drift detection
        if metrics.network_captured > 0 and metrics.proto_extracted == 0:
            metrics.proto_field_drift = True
            logger.warning(
                f"[monitor] PROTO FIELD DRIFT: captured {metrics.network_captured} "
                f"responses but extracted 0 reviews. Run proto_decoder.py --probe "
                f"on saved raw bytes and update FIELD_MAP."
            )

        if metrics.ui_total and metrics.total_extracted > 0:
            extraction_rate = metrics.total_extracted / metrics.ui_total
            if extraction_rate < (1 - DIVERGENCE_THRESHOLD):
                logger.warning(
                    f"[monitor] LOW EXTRACTION RATE: got {metrics.total_extracted} "
                    f"of {metrics.ui_total} UI reviews ({extraction_rate:.0%}). "
                    f"Check scroll engine and proto field map."
                )

        self._save_metrics(metrics)

        result = RunResult(
            place_id=metrics.place_id,
            success=len(metrics.errors) == 0,
            captured_count=metrics.network_captured,
            extracted_count=metrics.total_extracted,
            stored_count=metrics.stored,
            errors=metrics.errors,
            session_rotated=metrics.session_rotated,
            duration_seconds=metrics.duration_seconds,
        )

        logger.info(
            f"[monitor] Run finished: {metrics.run_id} | "
            f"captured={metrics.network_captured} proto={metrics.proto_extracted} "
            f"dom={metrics.dom_extracted} stored={metrics.stored} "
            f"duration={metrics.duration_seconds:.1f}s"
        )
        return result

    async def take_snapshot(self, page: Page, label: str = ""):
        """Save HTML snapshot and screenshot for debugging."""
        if not SNAPSHOT_ENABLED:
            return
        ts = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
        tag = f"{self._metrics.place_id}_{ts}_{label}" if self._metrics else ts

        try:
            html = await page.content()
            snap_path = os.path.join(self._snapshots_dir, f"{tag}.html")
            with open(snap_path, "w", encoding="utf-8") as f:
                f.write(html)
            logger.debug(f"[monitor] Snapshot saved: {snap_path}")
        except Exception as e:
            logger.debug(f"[monitor] Snapshot failed: {e}")

        try:
            ss_path = os.path.join(self._screenshots_dir, f"{tag}.png")
            await page.screenshot(path=ss_path, full_page=False)
            logger.debug(f"[monitor] Screenshot saved: {ss_path}")
        except Exception as e:
            logger.debug(f"[monitor] Screenshot failed: {e}")

    def log_error(self, msg: str):
        if self._metrics:
            self._metrics.errors.append(msg)
        logger.error(f"[monitor] {msg}")

    def _save_metrics(self, metrics: RunMetrics):
        fname = os.path.join(
            self._snapshots_dir,
            f"metrics_{metrics.place_id}_{metrics.run_id}.json"
        )
        try:
            with open(fname, "w") as f:
                json.dump(asdict(metrics), f, indent=2)
        except Exception as e:
            logger.debug(f"[monitor] Could not save metrics: {e}")