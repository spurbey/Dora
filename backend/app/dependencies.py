"""
Authentication dependencies for FastAPI routes.

Provides:
    - get_current_user: Validates Supabase JWT via JWKS (ES256)
    - get_current_active_user: Additional user status checks

Important:
    - Supabase uses ES256 (asymmetric encryption), not HS256
    - JWT verification via JWKS (public key), not shared secret
    - Backend only VERIFIES tokens, never creates them
"""

from fastapi import Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
from jose import jwt, JWTError
import httpx
from typing import Optional

from app.database import get_db
from app.models.user import User
from app.config import settings


async def get_jwks():
    """
    Fetch Supabase's public keys (JWKS) for JWT verification.
    
    Returns:
        dict: JWKS containing public keys
        
    Raises:
        HTTPException: If JWKS endpoint is unreachable
        
    Note:
        Supabase rotates keys periodically. Always fetch fresh JWKS.
        In production, consider caching with short TTL (5-10 min).
    """
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{settings.SUPABASE_URL}/auth/v1/.well-known/jwks.json",
                timeout=5.0
            )
            response.raise_for_status()
            return response.json()
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Unable to fetch JWKS: {str(e)}"
        )


async def get_current_user(
    authorization: str = Header(..., description="Bearer token from Supabase Auth"),
    db: Session = Depends(get_db)
) -> User:
    """
    Validate Supabase JWT token and return current user.
    
    Args:
        authorization: Authorization header with Bearer token
        db: Database session
        
    Returns:
        User: Authenticated user object
        
    Raises:
        HTTPException 401: Invalid/expired token or user not found
        HTTPException 503: JWKS endpoint unreachable
        
    Flow:
        1. Extract token from Authorization header
        2. Fetch Supabase's public keys (JWKS)
        3. Verify JWT signature using ES256 algorithm
        4. Extract user_id from token payload
        5. Query user from database
        
    Security:
        - Uses asymmetric verification (ES256)
        - Public key fetched from JWKS endpoint
        - No shared secret stored in backend
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        # Extract token from header
        if not authorization.startswith("Bearer "):
            raise credentials_exception
        
        token = authorization.replace("Bearer ", "")
        
        # Fetch JWKS (public keys)
        jwks = await get_jwks()
        
        # Decode and verify JWT using JWKS
        # python-jose automatically finds correct key by 'kid' header
        payload = jwt.decode(
            token,
            jwks,
            algorithms=["ES256"],  # Supabase uses ES256, not HS256
            audience="authenticated",  # Supabase audience claim
            options={
                "verify_aud": True,
                "verify_exp": True,
            }
        )
        
        # Extract user ID from 'sub' claim
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
            
    except JWTError as e:
        # Log for debugging (remove in production or use proper logging)
        print(f"JWT validation error: {e}")
        raise credentials_exception
    except Exception as e:
        print(f"Unexpected error during auth: {e}")
        raise credentials_exception
    
    # Get user from database
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )
    
    return user


async def get_current_active_user(
    current_user: User = Depends(get_current_user)
) -> User:
    """
    Check if user is active and not banned.
    
    Args:
        current_user: User from get_current_user dependency
        
    Returns:
        User: Active user object
        
    Raises:
        HTTPException 403: User is banned or deactivated
        
    Business Rules:
        - Add is_active field check when implemented
        - Add is_banned field check when implemented
        - Currently just passes through (all users active)
    """
    # Future: Add checks for banned/deactivated users
    # if not current_user.is_active:
    #     raise HTTPException(status_code=403, detail="User account is deactivated")
    
    return current_user