import 'package:test/test.dart';
import 'package:dora_api/dora_api.dart';


/// tests for MediaApi
void main() {
  final instance = DoraApi().getMediaApi();

  group(MediaApi, () {
    // Delete Media
    //
    // Delete media.  **Authentication:** Required  **Permissions:** Only owner can delete  **Path Parameters:** - media_id: Media UUID  **Returns:** 204 No Content on success  **Errors:** - 401: Not authenticated - 403: User does not own media - 404: Media not found  **Business Logic:** - Ownership check prevents unauthorized deletion - Deletes file from Supabase Storage - Deletes metadata from database - Permanent deletion (no soft delete)  **Warning:** - This action is irreversible - File will be deleted from storage
    //
    //Future deleteMediaApiV1MediaMediaIdDelete(String mediaId, String authorization) async
    test('test deleteMediaApiV1MediaMediaIdDelete', () async {
      // TODO
    });

    // Get Media
    //
    // Get media detail by ID.          **Authentication:** Required          **Permissions:**     - Owner can always view     - Non-owner can view if trip is public/unlisted          **Path Parameters:**     - media_id: Media UUID          **Returns:**     Media details with file URLs          **Response Example:** ```json     {         \"id\": \"123e4567-e89b-12d3-a456-426614174000\",         \"user_id\": \"987e6543-e21b-12d3-a456-426614174000\",         \"trip_place_id\": \"456e7890-e12b-12d3-a456-426614174000\",         \"file_url\": \"https://xxx.supabase.co/storage/v1/object/public/photos/user_id/file.jpg\",         \"thumbnail_url\": \"https://xxx.supabase.co/.../file.jpg?width=200&height=200\",         \"caption\": \"Beautiful sunset\",         \"created_at\": \"2025-01-26T10:00:00Z\"     } ```          **Errors:**     - 401: Not authenticated     - 403: Trip is private and user is not owner     - 404: Media not found          **Business Logic:**     - Access control based on parent trip's visibility     - Private trip media only visible to owner     - Public/unlisted trip media visible to anyone
    //
    //Future<MediaResponse> getMediaApiV1MediaMediaIdGet(String mediaId, String authorization) async
    test('test getMediaApiV1MediaMediaIdGet', () async {
      // TODO
    });

    // Upload Media
    //
    // Upload photo to a place.          **Authentication:** Required          **Permissions:** User must own the place (via trip ownership)          **Request:**     - Content-Type: multipart/form-data     - file: Image file (required)     - trip_place_id: UUID of place (required)     - caption: Photo caption (optional, max 500 chars)     - taken_at: When photo was taken (optional, ISO datetime)          **Returns:**     Created media with file URLs          **Response Example:** ```json     {         \"id\": \"123e4567-e89b-12d3-a456-426614174000\",         \"user_id\": \"987e6543-e21b-12d3-a456-426614174000\",         \"trip_place_id\": \"456e7890-e12b-12d3-a456-426614174000\",         \"file_url\": \"https://xxx.supabase.co/storage/v1/object/public/photos/user_id/file.jpg\",         \"file_type\": \"photo\",         \"file_size_bytes\": 245678,         \"mime_type\": \"image/jpeg\",         \"width\": 1920,         \"height\": 1080,         \"thumbnail_url\": \"https://xxx.supabase.co/.../file.jpg?width=200&height=200\",         \"caption\": \"Beautiful sunset at Eiffel Tower\",         \"taken_at\": \"2025-06-15T18:30:00Z\",         \"created_at\": \"2025-01-26T10:00:00Z\"     } ```          **Errors:**     - 400: Invalid file type or size     - 401: Not authenticated     - 403: User does not own place     - 404: Place not found          **Business Logic:**     - File stored in Supabase Storage: photos/{user_id}/{uuid}.{ext}     - Thumbnail auto-generated via Supabase transformations     - Image dimensions extracted via PIL     - Free tier: max 10MB per photo     - Premium tier: max 100MB per photo     - Allowed types: image/jpeg, image/png, image/webp
    //
    //Future<MediaResponse> uploadMediaApiV1MediaUploadPost(String authorization, MultipartFile file, String tripPlaceId, { String caption, DateTime takenAt }) async
    test('test uploadMediaApiV1MediaUploadPost', () async {
      // TODO
    });

  });
}
