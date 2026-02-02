"""
Pytest configuration and shared fixtures.

This module provides reusable fixtures for backend tests, including:

- PostgreSQL test database session
- FastAPI application instance
- HTTP test client
- Pre-created test user

Purpose:
---------
Ensures that all tests run in isolation using transactions
and do not affect production data.

Each test is executed inside a database transaction
that is rolled back after completion.
"""

import os
import pytest
from uuid import uuid4

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from fastapi.testclient import TestClient

from app.database import get_db
from app.main import app
from app.models.user import User
from app.config import settings




#: Test database URL (defaults to production DB if not set explicitly)
TEST_DATABASE_URL = os.getenv(
    "TEST_DATABASE_URL",
    settings.SUPABASE_DB_URL
)

#: SQLAlchemy engine for test database
engine = create_engine(TEST_DATABASE_URL)

#: Session factory for test database
TestingSessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)



@pytest.fixture(scope="session", autouse=True)
def setup_test_views():
    """
    Create database views needed for tests (runs once per session).

    Phase A3: Creates trip_components_view for unified timeline.
    """
    from sqlalchemy import text

    connection = engine.connect()
    try:
        connection.execute(text("""
            CREATE OR REPLACE VIEW trip_components_view AS
            SELECT
                id,
                trip_id,
                user_id,
                'place'::text as component_type,
                name,
                order_in_trip,
                created_at,
                updated_at,
                'trip_places'::text as source_table,
                id as source_id
            FROM trip_places
            UNION ALL
            SELECT
                id,
                trip_id,
                user_id,
                'route'::text as component_type,
                COALESCE(name, 'Route'::text) as name,
                order_in_trip,
                created_at,
                updated_at,
                'routes'::text as source_table,
                id as source_id
            FROM routes;
        """))
        connection.commit()
    except Exception:
        # View might already exist, ignore
        pass
    finally:
        connection.close()


@pytest.fixture(scope="function")
def db():
    """
    Provide a transactional database session for each test.

    This fixture creates a new database connection and starts
    a transaction before each test.

    After the test finishes, the transaction is rolled back,
    ensuring no data is permanently stored.

    Yields:
    -------
    sqlalchemy.orm.Session
        Active database session bound to a transaction.
    """
    connection = engine.connect()
    transaction = connection.begin()
    session = TestingSessionLocal(bind=connection)

    try:
        yield session
    finally:
        session.close()
        transaction.rollback()
        connection.close()


@pytest.fixture(scope="function")
def fastapi_app():
    """
    Provide the FastAPI application instance for testing.

    This fixture ensures that all dependency overrides
    are cleared after each test.

    Yields:
    -------
    fastapi.FastAPI
        Application instance.
    """
    yield app
    app.dependency_overrides.clear()


@pytest.fixture(scope="function")
def client(db, fastapi_app):
    """
    Provide a FastAPI test client with injected test database.

    Overrides the `get_db` dependency so that API routes
    use the transactional test session.

    Parameters:
    ----------
    db : sqlalchemy.orm.Session
        Test database session.

    fastapi_app : fastapi.FastAPI
        Application instance.

    Yields:
    -------
    fastapi.testclient.TestClient
        HTTP client for testing API endpoints.
    """

    def override_get_db():
        """
        Override dependency for database session.

        Yields:
        -------
        sqlalchemy.orm.Session
            Test database session.
        """
        yield db

    fastapi_app.dependency_overrides[get_db] = override_get_db

    with TestClient(fastapi_app) as test_client:
        yield test_client

    fastapi_app.dependency_overrides.clear()


@pytest.fixture
def test_user(db):
    """
    Create and persist a test user.

    Generates a user with unique email and username
    to avoid conflicts with database constraints.

    Parameters:
    ----------
    db : sqlalchemy.orm.Session
        Test database session.

    Returns:
    -------
    app.models.user.User
        Persisted user model instance.
    """
    unique_id = str(uuid4())[:8]

    user = User(
        id=uuid4(),
        email=f"test_{unique_id}@example.com",
        username=f"testuser_{unique_id}",
        hashed_password="hashed",
        is_premium=False,
        is_verified=True
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return user


@pytest.fixture
def premium_user(db):
    """
    Create premium test user.

    Parameters:
    ----------
    db : Session
        Test database session.

    Returns:
    -------
    User
        Premium user instance.
    """
    unique_id = str(uuid4())[:8]

    user = User(
        id=uuid4(),
        email=f"premium_{unique_id}@example.com",
        username=f"premium_{unique_id}",
        hashed_password="hashed",
        is_premium=True,  # Premium status
        is_verified=True
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return user


@pytest.fixture
def other_user(db):
    """
    Create another test user (for testing non-owner scenarios).

    Parameters:
    ----------
    db : Session
        Test database session.

    Returns:
    -------
    User
        Another user instance.
    """
    unique_id = str(uuid4())[:8]

    user = User(
        id=uuid4(),
        email=f"other_{unique_id}@example.com",
        username=f"other_{unique_id}",
        hashed_password="hashed",
        is_premium=False,
        is_verified=True
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return user


@pytest.fixture
def auth_as(fastapi_app):
    """
    Mock authentication by overriding get_current_user dependency.

    Usage:
        auth_as(test_user)  # All requests will be authenticated as test_user

    Parameters:
    ----------
    fastapi_app : FastAPI
        Application instance.

    Yields:
    -------
    callable
        Function to set the authenticated user.
    """
    from app.dependencies import get_current_user

    def _set(user):
        def _override():
            return user
        fastapi_app.dependency_overrides[get_current_user] = _override

    yield _set
    fastapi_app.dependency_overrides.clear()
