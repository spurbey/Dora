# Phase 1A: Authentication Integration

Duration: 2 sessions, Week 2
Goal: Supabase Auth working with FastAPI JWT validation

## Session 3: Supabase Auth Integration

### Objective
Integrate Supabase Auth, validate JWTs in FastAPI, protect endpoints.

### Tasks
1. Install dependencies
```bash
   pip install python-jose[cryptography] passlib[bcrypt]
```
   
2. Create auth dependencies
   File: backend/app/dependencies.py
   - get_current_user function
   - Validates JWT from Authorization header
   - Decodes token using Supabase JWT secret
   - Fetches user from database
   - Returns User object or raises 401
   
3. Create auth schemas
   File: backend/app/schemas/auth.py
   - Token (access_token, token_type)
   - UserResponse (id, email, username, is_premium)
   
4. Test protected endpoint
```python
   @router.get("/me", response_model=UserResponse)
   def get_me(current_user: User = Depends(get_current_user)):
       return current_user
```
   
5. Frontend: Configure Supabase client
   - Install: `npm install @supabase/supabase-js`
   - Create lib/supabase.ts
   - Configure with VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY
   
6. Frontend: Test auth flow
   - Sign up via Supabase client
   - Get JWT token
   - Call backend /me endpoint with token
   - Verify user data returned

### Success Criteria
- Can sign up via Supabase
- JWT token returned
- FastAPI validates token correctly
- /me endpoint returns user data
- Invalid token returns 401

### Files Created
- backend/app/dependencies.py
- backend/app/schemas/auth.py
- backend/app/api/v1/auth.py (optional, for /me endpoint)

---

## Session 4: User Profile Endpoints

### Objective
CRUD endpoints for user profile management.

### Tasks
1. Create user schema
   File: backend/app/schemas/user.py
   - UserBase (email, username, full_name, bio)
   - UserUpdate (all fields optional)
   - UserResponse (includes id, created_at, is_premium)
   
2. Create user service
   File: backend/app/services/user_service.py
   - get_user_by_id
   - update_user
   - get_user_stats (trip_count, place_count)
   
3. Create user routes
   File: backend/app/api/v1/users.py
   - GET /users/me (current user)
   - PATCH /users/me (update profile)
   - GET /users/me/stats
   
4. Write tests
   File: backend/tests/test_users.py
   - test_get_current_user
   - test_update_profile
   - test_get_stats
   
5. Run tests
```bash
   pytest tests/test_users.py -v
```

### Success Criteria
- GET /users/me returns user data
- PATCH /users/me updates profile
- GET /users/me/stats returns counts
- Tests pass with >80% coverage
- Auth required for all endpoints

### Files Created
- backend/app/schemas/user.py
- backend/app/services/user_service.py
- backend/app/api/v1/users.py
- backend/tests/test_users.py

---

## Phase Completion Checklist
- [ ] Supabase Auth configured
- [ ] JWT validation works in FastAPI
- [ ] Protected endpoints require auth
- [ ] User profile endpoints work
- [ ] Tests pass
- [ ] Frontend can authenticate