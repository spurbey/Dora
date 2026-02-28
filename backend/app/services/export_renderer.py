"""
Renderer adapter interfaces for export worker integration.

6A ships a mock renderer only. Local/Lambda adapters plug into the same interface.
"""

from abc import ABC, abstractmethod
from typing import Dict, Literal, Optional
from uuid import UUID, uuid4

from pydantic import BaseModel, Field


class RenderManifest(BaseModel):
    job_id: UUID
    template: str
    aspect_ratio: str
    quality: str
    duration_sec: int
    fps: int
    snapshot: dict


class RenderStatus(BaseModel):
    render_id: str
    status: Literal["queued", "rendering", "completed", "failed", "canceled"]
    progress: float = Field(ge=0.0, le=1.0)
    output_path: Optional[str] = None
    error: Optional[str] = None


class AbstractRemotionRenderer(ABC):
    @abstractmethod
    async def render(self, manifest: RenderManifest) -> str:
        """Start rendering and return renderer-side render_id."""

    @abstractmethod
    async def get_status(self, render_id: str) -> RenderStatus:
        """Return current render status and progress."""

    @abstractmethod
    async def cancel(self, render_id: str) -> None:
        """Request cancellation of an in-flight render."""


class MockRemotionRenderer(AbstractRemotionRenderer):
    """
    Deterministic mock renderer for 6A control-plane and worker tests.
    """

    def __init__(self) -> None:
        self._states: Dict[str, dict] = {}

    async def render(self, manifest: RenderManifest) -> str:
        render_id = str(uuid4())
        self._states[render_id] = {
            "step": 0,
            "status": "queued",
            "output_path": None,
            "error": None,
        }
        return render_id

    async def get_status(self, render_id: str) -> RenderStatus:
        state = self._states.get(render_id)
        if not state:
            return RenderStatus(
                render_id=render_id,
                status="failed",
                progress=1.0,
                error="render_not_found",
            )

        if state["status"] in {"completed", "failed", "canceled"}:
            return RenderStatus(
                render_id=render_id,
                status=state["status"],
                progress=1.0 if state["status"] == "completed" else 0.0,
                output_path=state["output_path"],
                error=state["error"],
            )

        state["step"] += 1
        if state["step"] == 1:
            state["status"] = "rendering"
            progress = 0.35
        elif state["step"] == 2:
            state["status"] = "rendering"
            progress = 0.7
        else:
            state["status"] = "completed"
            state["output_path"] = f"/tmp/{render_id}.mp4"
            progress = 1.0

        return RenderStatus(
            render_id=render_id,
            status=state["status"],
            progress=progress,
            output_path=state["output_path"],
            error=state["error"],
        )

    async def cancel(self, render_id: str) -> None:
        state = self._states.get(render_id)
        if not state:
            return
        state["status"] = "canceled"
        state["error"] = "canceled_by_user"
