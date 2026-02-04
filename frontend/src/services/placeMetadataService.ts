import { api } from '@/services/api';
import type { PlaceMetadata, PlaceMetadataCreate, PlaceMetadataUpdate } from '@/types/placeMetadata';

export const placeMetadataService = {
  get: (placeId: string) => api.get<PlaceMetadata>(`/places/${placeId}/metadata`),
  create: (placeId: string, data: PlaceMetadataCreate) =>
    api.post<PlaceMetadata, PlaceMetadataCreate>(`/places/${placeId}/metadata`, data),
  update: (placeId: string, data: PlaceMetadataUpdate) =>
    api.patch<PlaceMetadata, PlaceMetadataUpdate>(`/places/${placeId}/metadata`, data),
};
