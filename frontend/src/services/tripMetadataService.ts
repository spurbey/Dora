import { api } from '@/services/api';
import type { TripMetadata, TripMetadataCreate, TripMetadataUpdate } from '@/types/tripMetadata';

export const tripMetadataService = {
  get: (tripId: string) => api.get<TripMetadata>(`/trips/${tripId}/metadata`),
  create: (tripId: string, data: TripMetadataCreate) =>
    api.post<TripMetadata, TripMetadataCreate>(`/trips/${tripId}/metadata`, data),
  update: (tripId: string, data: TripMetadataUpdate) =>
    api.patch<TripMetadata, TripMetadataUpdate>(`/trips/${tripId}/metadata`, data),
};
