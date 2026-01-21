# Phase 2A: Media Upload

Duration: 3 sessions, Week 5-6
Goal: Photo upload to Supabase Storage

## Session 11: Supabase Storage Setup

### Objective
Configure Supabase Storage bucket and test uploads.

### Tasks
1. Create storage bucket in Supabase
   - Dashboard → Storage → New Bucket
   - Name: "photos"
   - Public: Yes
   
2. Configure RLS policy (optional)
```sql
   CREATE POLICY "Users can upload to own folder"
   ON storage.objects FOR INSERT
   WITH CHECK (
       bucket_id = 'photos' AND
       auth.uid()::text = (storage.foldername(name))[1]
   );
```
   
3. Install Supabase Python client
```bash
   pip install supabase
```
   
4. Create storage service
   File: backend/app/services/storage_service.py
   - upload_file method
   - delete_file method
   - get_public_url method
   
5. Test upload manually
```python
   from supabase import create_client
   supabase = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)
   
   with open("test.jpg", "rb") as f:
       supabase.storage.from_("photos").upload(
           "test/test.jpg",
           f,
           {"content-type": "image/jpeg"}
       )
   
   url = supabase.storage.from_("photos").get_public_url("test/test.jpg")
   print(url)
```
   
6. Verify file appears in Supabase Storage dashboard

### Success Criteria
- Storage bucket created
- Can upload file programmatically
- Public URL works
- File visible in dashboard

### Files Created
- backend/app/services/storage_service.py

---

## Session 12: Photo Upload Endpoint

### Objective
API endpoint for uploading photos to places.

### Tasks
1. Create MediaFile model
   File: backend/app/models/media.py
```python
   class MediaFile(Base):
       __tablename__ = "media_files"
       id = Column(UUID, primary_key=True)
       user_id = Column(UUID, ForeignKey("users.id"))
       trip_place_id = Column(UUID, ForeignKey("trip_places.id"))
       file_url = Column(Text, nullable=False)
       file_type = Column(String(20))
       width = Column(Integer)
       height = Column(Integer)
       thumbnail_url = Column(Text)
       caption = Column(Text)
       created_at = Column(DateTime, server_default=func.now())
```
   
2. Create migration
```bash
   alembic revision --autogenerate -m "create media_files table"
   alembic upgrade head
```
   
3. Create media schemas
   File: backend/app/schemas/media.py
   - MediaCreate (trip_place_id, caption)
   - MediaResponse (includes urls, dimensions)
   
4. Create media service
   File: backend/app/services/media_service.py
   - upload_photo (validate, upload to Supabase, save metadata)
   - delete_media (delete from Supabase + DB)
   - get_media_by_id
   
5. Create media routes
   File: backend/app/api/v1/media.py
   - POST /media/upload (multipart/form-data)
   - GET /media/{id}
   - DELETE /media/{id}
   
6. Implement upload endpoint
```python
   @router.post("/upload", response_model=MediaResponse)
   async def upload_media(
       file: UploadFile = File(...),
       trip_place_id: UUID = Form(...),
       caption: str = Form(None),
       current_user = Depends(get_current_user),
       db = Depends(get_db)
   ):
       # Validate file type
       if file.content_type not in ["image/jpeg", "image/png", "image/webp"]:
           raise HTTPException(400, "Invalid file type")
       
       # Validate file size (10MB for free tier)
       contents = await file.read()
       if len(contents) > 10 * 1024 * 1024:
           raise HTTPException(400, "File too large")
       
       # Check user owns the place
       place = db.query(TripPlace).filter(TripPlace.id == trip_place_id).first()
       if not place or place.user_id != current_user.id:
           raise HTTPException(403)
       
       # Upload to Supabase
       service = MediaService(db)
       media = await service.upload_photo(
           file=file,
           user_id=current_user.id,
           trip_place_id=trip_place_id,
           caption=caption
       )
       
       return media
```
   
7. Register router

### Success Criteria
- Can upload photo via API
- File stored in Supabase Storage
- Metadata saved in database
- Thumbnail URL generated (Supabase transformation)
- Ownership validation works

### Files Created
- backend/app/models/media.py
- backend/app/schemas/media.py
- backend/app/services/media_service.py
- backend/app/api/v1/media.py

---

## Session 13: Media Management

### Objective
Complete media CRUD and integrate with places.

### Tasks
1. Add GET /media/{id}
   - Return media with signed URL if private
   - Check permissions
   
2. Add DELETE /media/{id}
   - Check ownership
   - Delete from Supabase Storage
   - Delete from database
   
3. Update TripPlace
   - Add photos JSONB array to store media IDs
   - Update when media uploaded
   
4. Update GET /places/{id}
   - Include photos array with full media objects
   - Include thumbnail URLs
   
5. Create test
   File: backend/tests/test_media.py
   - test_upload_photo
   - test_upload_invalid_file_type
   - test_upload_file_too_large
   - test_delete_media
   - test_delete_media_not_owner
   - test_place_includes_photos
   
6. Run tests

### Success Criteria
- Media CRUD works
- Photos attached to places
- Thumbnails generated
- Tests pass
- File size limits enforced

### Files Modified
- backend/app/api/v1/media.py
- backend/app/api/v1/places.py
- backend/app/models/place.py

### Files Created
- backend/tests/test_media.py

---

## Phase Completion Checklist
- [ ] Supabase Storage configured
- [ ] Can upload photos via API
- [ ] Photos stored in correct bucket/folder
- [ ] Thumbnails generated
- [ ] Metadata in database
- [ ] Photos attached to places
- [ ] Tests pass
- [ ] File validation works