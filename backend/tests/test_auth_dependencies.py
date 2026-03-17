import pytest
from fastapi import HTTPException, status
from sqlalchemy.exc import IntegrityError

from app.dependencies import get_current_user, get_jwks
from app.models.user import User
import app.dependencies as auth_dependencies


@pytest.fixture
def reset_jwks_cache(monkeypatch):
    monkeypatch.setattr(auth_dependencies, "_JWKS_CACHE", None)
    monkeypatch.setattr(auth_dependencies, "_JWKS_CACHE_EXPIRES_AT", 0.0)


@pytest.mark.asyncio
async def test_get_current_user_preserves_http_exception_from_jwks(monkeypatch, reset_jwks_cache):
    async def _fail_jwks():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="JWKS temporarily unavailable",
        )

    monkeypatch.setattr(auth_dependencies, "get_jwks", _fail_jwks)

    with pytest.raises(HTTPException) as exc:
        await get_current_user(authorization="Bearer token", db=None)

    assert exc.value.status_code == status.HTTP_503_SERVICE_UNAVAILABLE
    assert "JWKS temporarily unavailable" in exc.value.detail


@pytest.mark.asyncio
async def test_get_current_user_unexpected_auth_error_returns_503(monkeypatch, reset_jwks_cache):
    async def _jwks():
        return {"keys": []}

    def _decode(*_args, **_kwargs):
        raise RuntimeError("unexpected decode failure")

    monkeypatch.setattr(auth_dependencies, "get_jwks", _jwks)
    monkeypatch.setattr(auth_dependencies.jwt, "decode", _decode)

    with pytest.raises(HTTPException) as exc:
        await get_current_user(authorization="Bearer token", db=None)

    assert exc.value.status_code == status.HTTP_503_SERVICE_UNAVAILABLE
    assert exc.value.detail == "Authentication service unavailable"


class _FakeQuery:
    def __init__(self, session):
        self._session = session

    def filter(self, *_args, **_kwargs):
        return self

    def first(self):
        self._session.first_calls += 1
        # 1: initial lookup by id -> missing
        # 2: username uniqueness check -> missing
        # 3: post-IntegrityError lookup by id -> found
        if self._session.first_calls >= 3:
            return self._session.existing_user
        return None


class _FakeSession:
    def __init__(self, existing_user):
        self.existing_user = existing_user
        self.first_calls = 0
        self.commit_calls = 0
        self.rollback_called = False

    def query(self, _model):
        return _FakeQuery(self)

    def add(self, _obj):
        return None

    def commit(self):
        self.commit_calls += 1
        raise IntegrityError("INSERT INTO users ...", {}, Exception("duplicate key"))

    def rollback(self):
        self.rollback_called = True

    def refresh(self, _obj):
        return None


@pytest.mark.asyncio
async def test_get_current_user_recovers_from_integrity_error_race(monkeypatch, reset_jwks_cache):
    user_id = "24fa8c3f-b57b-4fa7-9d71-a99cd546d9e9"
    existing = User(
        id=user_id,
        email="race@example.com",
        username="race_user",
        hashed_password="supabase_auth",
        is_verified=True,
    )
    fake_db = _FakeSession(existing_user=existing)

    async def _jwks():
        return {"keys": []}

    def _decode(*_args, **_kwargs):
        return {
            "sub": user_id,
            "email": "race@example.com",
            "user_metadata": {"username": "race_user"},
            "email_verified": True,
        }

    monkeypatch.setattr(auth_dependencies, "get_jwks", _jwks)
    monkeypatch.setattr(auth_dependencies.jwt, "decode", _decode)

    user = await get_current_user(authorization="Bearer token", db=fake_db)

    assert user is existing
    assert fake_db.commit_calls == 1
    assert fake_db.rollback_called is True


@pytest.mark.asyncio
async def test_get_jwks_uses_cache_between_requests(monkeypatch, reset_jwks_cache):
    class _FakeResponse:
        def raise_for_status(self):
            return None

        def json(self):
            return {"keys": [{"kid": "abc"}]}

    class _FakeAsyncClient:
        calls = 0

        async def __aenter__(self):
            return self

        async def __aexit__(self, _exc_type, _exc, _tb):
            return False

        async def get(self, *_args, **_kwargs):
            _FakeAsyncClient.calls += 1
            return _FakeResponse()

    class _FakeHttpxModule:
        AsyncClient = _FakeAsyncClient

    monkeypatch.setattr(auth_dependencies, "httpx", _FakeHttpxModule())

    first = await get_jwks()
    second = await get_jwks()

    assert first == second
    assert _FakeAsyncClient.calls == 1
