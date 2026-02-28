"""
Renderer adapter interfaces for export worker integration.

6A ships a mock renderer only. 6B introduces local HTTP renderer adapter.
"""

import os
from abc import ABC, abstractmethod
from typing import Dict, Literal, Optional
from uuid import UUID, uuid4

import httpx
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


class LocalRemotionRenderer(AbstractRemotionRenderer):
    """
    HTTP adapter for local `video-renderer` service (Phase 6B).
    """

    def __init__(
        self,
        base_url: Optional[str] = None,
        renderer_version: str = "1",
        timeout_seconds: float = 10.0,
        client: Optional[httpx.AsyncClient] = None,
    ) -> None:
        self._base_url = (base_url or os.getenv("RENDERER_URL", "http://localhost:3100")).rstrip("/")
        self._renderer_version = renderer_version
        self._client = client or httpx.AsyncClient(
            base_url=self._base_url,
            timeout=httpx.Timeout(timeout_seconds),
            headers={"X-Renderer-Version": self._renderer_version},
        )

    async def render(self, manifest: RenderManifest) -> str:
        response = await self._client.post(
            "/api/v1/render",
            json=manifest.model_dump(mode="json"),
        )
        if response.status_code != 202:
            raise RuntimeError(f"renderer_render_failed:{response.status_code}:{response.text}")

        payload = response.json()
        render_id = payload.get("render_id")
        if not render_id:
            raise RuntimeError("renderer_render_failed:missing_render_id")
        return str(render_id)

    async def get_status(self, render_id: str) -> RenderStatus:
        response = await self._client.get(f"/api/v1/render/{render_id}")
        if response.status_code == 404:
            return RenderStatus(
                render_id=render_id,
                status="failed",
                progress=1.0,
                error="render_not_found",
            )
        if response.status_code != 200:
            raise RuntimeError(f"renderer_status_failed:{response.status_code}:{response.text}")

        payload = response.json()
        status_value = str(payload.get("status", "failed"))
        if status_value not in {"queued", "rendering", "completed", "failed"}:
            raise RuntimeError(f"renderer_status_invalid:{status_value}")

        output_path_value = payload.get("output_path")
        output_path = str(output_path_value) if output_path_value else None
        error_value = payload.get("error")
        error = str(error_value) if error_value else None

        return RenderStatus(
            render_id=str(payload.get("render_id", render_id)),
            status=status_value,
            progress=float(payload.get("progress", 0.0)),
            output_path=output_path,
            error=error,
        )

    async def cancel(self, render_id: str) -> None:
        response = await self._client.delete(f"/api/v1/render/{render_id}")
        if response.status_code in {200, 404}:
            return
        raise RuntimeError(f"renderer_cancel_failed:{response.status_code}:{response.text}")


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


def create_renderer_from_env() -> AbstractRemotionRenderer:
    """
    Build renderer implementation from environment.

    Supported values:
    - mock (default): deterministic in-memory renderer
    - local: HTTP adapter to local video-renderer service
    """
    backend = os.getenv("RENDER_BACKEND", "mock").strip().lower()
    if backend == "local":
        return LocalRemotionRenderer()
    return MockRemotionRenderer()
