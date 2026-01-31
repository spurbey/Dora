import { api } from '@/services/api';
import { API_ENDPOINTS } from '@/utils/constants';
import type { MediaFile, MediaUploadData } from '@/types/media';

// POST /media/upload (multipart/form-data)
export async function uploadMedia(data: MediaUploadData): Promise<MediaFile> {
  const formData = new FormData();
  formData.append('file', data.file);
  formData.append('trip_place_id', data.trip_place_id);
  if (data.caption) formData.append('caption', data.caption);
  if (data.taken_at) formData.append('taken_at', data.taken_at);

  return api.post<MediaFile, FormData>(API_ENDPOINTS.MEDIA.UPLOAD, formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
}

// GET /media/{id}
export async function getMedia(id: string): Promise<MediaFile> {
  return api.get<MediaFile>(API_ENDPOINTS.MEDIA.DETAIL(id));
}

// DELETE /media/{id}
export async function deleteMedia(id: string): Promise<void> {
  await api.delete(API_ENDPOINTS.MEDIA.DELETE(id));
}
