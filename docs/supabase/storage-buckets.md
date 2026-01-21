# Supabase Storage Configuration

## Buckets

### photos
- Purpose: User-uploaded photos
- Public: Yes
- Max file size: 10MB (free tier), 100MB (premium)
- Allowed types: image/jpeg, image/png, image/webp

### videos (Phase 2)
- Purpose: User-uploaded videos
- Public: Yes
- Max file size: 100MB (premium only)
- Allowed types: video/mp4, video/quicktime

## Folder Structure
```
photos/
├── {user_id}/
│   ├── {uuid}.jpg
│   ├── {uuid}.png
│   └── ...
```

Each user has their own folder (user_id)
Files named with UUID to avoid conflicts

## Image Transformations

Supabase provides on-the-fly transformations:

### Thumbnail (200x200)
```
https://xxxxx.supabase.co/storage/v1/object/public/photos/user_123/photo.jpg?width=200&height=200
```

### Medium (800x800)
```
https://xxxxx.supabase.co/storage/v1/object/public/photos/user_123/photo.jpg?width=800&height=800
```

### Quality
```
https://xxxxx.supabase.co/storage/v1/object/public/photos/user_123/photo.jpg?quality=80
```

## Upload Pattern (FastAPI)
```python
from supabase import create_client
from uuid import uuid4

supabase = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)

async def upload_photo(file: UploadFile, user_id: UUID):
    # Generate unique filename
    ext = file.filename.split('.')[-1]
    filename = f"{user_id}/{uuid4()}.{ext}"
    
    # Read file
    contents = await file.read()
    
    # Upload
    supabase.storage.from_("photos").upload(
        path=filename,
        file=contents,
        file_options={
            "content-type": file.content_type,
            "cache-control": "3600"
        }
    )
    
    # Get public URL
    url = supabase.storage.from_("photos").get_public_url(filename)
    
    return url
```

## Frontend Upload (React)
```typescript
import { supabase } from '@/lib/supabase';

async function uploadPhoto(file: File, userId: string) {
  const ext = file.name.split('.').pop();
  const filename = `${userId}/${crypto.randomUUID()}.${ext}`;
  
  const { data, error } = await supabase.storage
    .from('photos')
    .upload(filename, file);
  
  if (error) throw error;
  
  const { data: { publicUrl } } = supabase.storage
    .from('photos')
    .getPublicUrl(filename);
  
  return publicUrl;
}
```

## Delete Pattern
```python
def delete_photo(file_url: str):
    # Extract path from URL
    # https://xxxxx.supabase.co/storage/v1/object/public/photos/user_123/photo.jpg
    # → photos/user_123/photo.jpg
    path = file_url.split('/storage/v1/object/public/')[1]
    
    supabase.storage.from_("photos").remove([path])
```

## Best Practices
- Always validate file type before upload
- Check file size limits based on user tier
- Store file metadata in database (for search, management)
- Use transformations for thumbnails (don't store multiple sizes)
- Delete from storage when deleting database record