"""
Test Supabase Auth integration.

This script helps you test JWT validation.

Instructions:
    1. Go to Supabase Dashboard → Authentication → Users
    2. Create a test user via email signup
    3. Copy the JWT token from the response
    4. Paste it below and run this script
"""

import httpx
import asyncio


async def test_auth():
    """Test /auth/me endpoint with Supabase token."""
    
    # STEP 1: Get a token from Supabase
    # Go to your Supabase Dashboard and create a user
    # Or use Supabase client to sign in and get token
    
    # For now, let's test if the endpoint is accessible
    base_url = "http://localhost:8000"
    
    # Test without token (should fail)
    print("Testing without token...")
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{base_url}/api/v1/auth/me")
            print(f"Status: {response.status_code}")
            print(f"Response: {response.json()}")
    except Exception as e:
        print(f"Expected error (no token): {e}")
    
    # Test with token (you need to provide a real token)
    print("\nTo test with token:")
    print("1. Sign up a user in Supabase")
    print("2. Get the access_token from response")
    print("3. Run:")
    print('   curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8000/api/v1/auth/me')


if __name__ == "__main__":
    asyncio.run(test_auth())