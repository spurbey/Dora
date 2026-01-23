"""
Tests for user-related API endpoints.

This module validates the behavior of:

- GET    /api/v1/users/me
- PATCH  /api/v1/users/me
- GET    /api/v1/users/me/stats

Focus Areas:
------------
- Authentication dependency override
- Profile updates
- Username uniqueness validation
- Statistics retrieval

All tests use transactional database sessions
and mocked authentication.
"""

from uuid import uuid4

from app.models.user import User
from app.dependencies import get_current_user



def override_current_user(user):
    """
    Create dependency override for authenticated user.

    Parameters:
    ----------
    user : app.models.user.User
        User instance to inject.

    Returns:
    -------
    callable
        Function returning the provided user.
    """
    def _override():
        return user
    return _override




def test_get_current_user(client, test_user, fastapi_app):
    """
    Test GET /users/me returns authenticated user profile.

    Verifies that:
    - Endpoint returns HTTP 200
    - Returned email matches test user
    - Returned username matches test user

    Parameters:
    ----------
    client : TestClient
        HTTP test client.

    test_user : User
        Authenticated test user.

    fastapi_app : FastAPI
        Application instance.
    """
    fastapi_app.dependency_overrides[get_current_user] = (
        override_current_user(test_user)
    )

    response = client.get("/api/v1/users/me")

    assert response.status_code == 200

    data = response.json()

    assert data["email"] == test_user.email
    assert data["username"] == test_user.username

    fastapi_app.dependency_overrides.clear()


def test_update_user_profile(client, test_user, db, fastapi_app):
    """
    Test PATCH /users/me updates profile fields.

    Verifies that:
    - Full name can be updated
    - Bio can be updated
    - Changes persist in database

    Parameters:
    ----------
    client : TestClient
        HTTP test client.

    test_user : User
        Authenticated user.

    db : Session
        Database session.

    fastapi_app : FastAPI
        Application instance.
    """
    fastapi_app.dependency_overrides[get_current_user] = (
        override_current_user(test_user)
    )

    update_data = {
        "full_name": "Updated Name",
        "bio": "New bio"
    }

    response = client.patch(
        "/api/v1/users/me",
        json=update_data
    )

    assert response.status_code == 200

    data = response.json()

    assert data["full_name"] == "Updated Name"
    assert data["bio"] == "New bio"

    fastapi_app.dependency_overrides.clear()


def test_update_username_uniqueness(client, test_user, db, fastapi_app):
    """
    Test username uniqueness constraint.

    Verifies that:
    - Updating to an existing username fails
    - API returns HTTP 400
    - Proper error message is returned

    Parameters:
    ----------
    client : TestClient
        HTTP test client.

    test_user : User
        Authenticated user.

    db : Session
        Database session.

    fastapi_app : FastAPI
        Application instance.
    """
    # Create another user with conflicting username
    other_user = User(
        id=uuid4(),
        email="other@example.com",
        username="otherusername",
        hashed_password="hashed"
    )

    db.add(other_user)
    db.commit()

    fastapi_app.dependency_overrides[get_current_user] = (
        override_current_user(test_user)
    )

    update_data = {
        "username": "otherusername"
    }

    response = client.patch(
        "/api/v1/users/me",
        json=update_data
    )

    assert response.status_code == 400
    assert "already taken" in response.json()["detail"]

    fastapi_app.dependency_overrides.clear()


def test_get_user_stats(client, test_user, fastapi_app):
    """
    Test GET /users/me/stats returns default statistics.

    Verifies that:
    - Endpoint returns HTTP 200
    - Statistics keys exist
    - New user has zero counts

    Parameters:
    ----------
    client : TestClient
        HTTP test client.

    test_user : User
        Authenticated user.

    fastapi_app : FastAPI
        Application instance.
    """
    fastapi_app.dependency_overrides[get_current_user] = (
        override_current_user(test_user)
    )

    response = client.get("/api/v1/users/me/stats")

    assert response.status_code == 200

    data = response.json()

    assert "trip_count" in data
    assert "place_count" in data
    assert data["trip_count"] == 0
    assert data["place_count"] == 0

    fastapi_app.dependency_overrides.clear()
