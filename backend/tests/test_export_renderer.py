"""
Tests for renderer adapter selection and local HTTP adapter behavior.
"""

import asyncio
from uuid import uuid4

import httpx
import pytest

from app.services.export_renderer import (
    LocalRemotionRenderer,
    MockRemotionRenderer,
    RenderManifest,
    create_renderer_from_env,
)


def _build_manifest() -> RenderManifest:
    return RenderManifest(
        job_id=uuid4(),
        template="classic",
        aspect_ratio="9:16",
        quality="720p",
        duration_sec=15,
        fps=30,
        snapshot={"trip": {"id": "trip-1"}, "timeline": []},
    )


def test_create_renderer_defaults_to_mock(monkeypatch):
    monkeypatch.delenv("RENDER_BACKEND", raising=False)
    renderer = create_renderer_from_env()
    assert isinstance(renderer, MockRemotionRenderer)


def test_create_renderer_local_backend(monkeypatch):
    monkeypatch.setenv("RENDER_BACKEND", "local")
    monkeypatch.setenv("RENDERER_SHARED_SECRET", "test-renderer-secret")
    renderer = create_renderer_from_env()
    assert isinstance(renderer, LocalRemotionRenderer)
    asyncio.run(renderer.aclose())


def test_local_renderer_render_and_status_success():
    def handler(request: httpx.Request) -> httpx.Response:
        assert request.headers.get("X-Renderer-Version") == "1"
        assert request.headers.get("X-Renderer-Secret") == "test-renderer-secret"
        if request.method == "POST" and request.url.path == "/api/v1/render":
            return httpx.Response(202, json={"render_id": "render-1", "status": "queued"})
        if request.method == "GET" and request.url.path == "/api/v1/render/render-1":
            return httpx.Response(
                200,
                json={
                    "render_id": "render-1",
                    "status": "completed",
                    "progress": 1.0,
                    "output_path": "/render_artifacts/render-1.mp4",
                    "error": None,
                },
            )
        return httpx.Response(500, json={"error": "unexpected"})

    client = httpx.AsyncClient(
        base_url="http://renderer.test",
        transport=httpx.MockTransport(handler),
        headers={"X-Renderer-Version": "1"},
    )
    renderer = LocalRemotionRenderer(
        base_url="http://renderer.test",
        client=client,
        renderer_shared_secret="test-renderer-secret",
    )

    render_id = asyncio.run(renderer.render(_build_manifest()))
    assert render_id == "render-1"

    status = asyncio.run(renderer.get_status(render_id))
    assert status.status == "completed"
    assert status.output_path == "/render_artifacts/render-1.mp4"
    asyncio.run(client.aclose())


def test_local_renderer_cancel_allows_not_found():
    def handler(request: httpx.Request) -> httpx.Response:
        assert request.headers.get("X-Renderer-Secret") == "test-renderer-secret"
        if request.method == "DELETE":
            return httpx.Response(404, json={"error": "not_found"})
        return httpx.Response(500, json={"error": "unexpected"})

    client = httpx.AsyncClient(
        base_url="http://renderer.test",
        transport=httpx.MockTransport(handler),
        headers={"X-Renderer-Version": "1"},
    )
    renderer = LocalRemotionRenderer(
        base_url="http://renderer.test",
        client=client,
        renderer_shared_secret="test-renderer-secret",
    )

    asyncio.run(renderer.cancel("render-missing"))
    asyncio.run(client.aclose())


def test_local_renderer_aclose_releases_client():
    """aclose() must close the underlying httpx client without error."""
    renderer = LocalRemotionRenderer(
        base_url="http://renderer.test",
        renderer_shared_secret="test-renderer-secret",
    )
    asyncio.run(renderer.aclose())
    assert renderer._client.is_closed


def test_local_renderer_requires_shared_secret(monkeypatch):
    monkeypatch.delenv("RENDERER_SHARED_SECRET", raising=False)
    with pytest.raises(RuntimeError) as exc_info:
        LocalRemotionRenderer(base_url="http://renderer.test")
    assert "renderer_auth_missing" in str(exc_info.value)


def test_mock_renderer_aclose_is_noop():
    """aclose() on MockRemotionRenderer must not raise."""
    from app.services.export_renderer import MockRemotionRenderer
    renderer = MockRemotionRenderer()
    asyncio.run(renderer.aclose())  # must complete without error
