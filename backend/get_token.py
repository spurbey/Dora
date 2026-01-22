"""
Get Supabase JWT token for testing.

Run this to get a token, then use it to test /auth/me endpoint.
"""

from supabase import create_client
from app.config import settings

supabase = create_client(settings.SUPABASE_URL, settings.SUPABASE_ANON_KEY)

# Sign in
email = "test1@example.com"
password = "Test@123"

try:
    response = supabase.auth.sign_in_with_password({
        "email": email,
        "password": password
    })
    
    token = response.session.access_token
    user_id = response.user.id
    
    print("✅ Login successful!")
    print(f"\nUser ID: {user_id}")
    print(f"\nAccess Token:\n{token}")
    print(f"\n\nTest the endpoint:")
    print(f'curl -H "Authorization: Bearer {token}" http://localhost:8000/api/v1/auth/me')
    
except Exception as e:
    print(f"❌ Login failed: {e}")
    print("\nMake sure:")
    print("1. User exists in Supabase Auth")
    print("2. Email confirmation is disabled (for testing)")
    print("3. Credentials are correct")