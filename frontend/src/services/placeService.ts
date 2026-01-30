import { api } from '@/services/api';
import { API_ENDPOINTS } from '@/utils/constants';
import type { Place, PlaceCreate, PlaceUpdate, PlaceListResponse } from '@/types/place';

// GET /places?trip_id={id}
export async function getPlaces(tripId: string): Promise<PlaceListResponse> {
  return api.get<PlaceListResponse>(`${API_ENDPOINTS.PLACES.LIST}?trip_id=${tripId}`);
}

// POST /places
export async function createPlace(data: PlaceCreate): Promise<Place> {
  return api.post<Place, PlaceCreate>(API_ENDPOINTS.PLACES.CREATE, data);
}

// GET /places/{id}
export async function getPlace(id: string): Promise<Place> {
  return api.get<Place>(API_ENDPOINTS.PLACES.DETAIL(id));
}

// PATCH /places/{id}
export async function updatePlace(id: string, data: PlaceUpdate): Promise<Place> {
  return api.patch<Place, PlaceUpdate>(API_ENDPOINTS.PLACES.UPDATE(id), data);
}

// DELETE /places/{id}
export async function deletePlace(id: string): Promise<void> {
  await api.delete(API_ENDPOINTS.PLACES.DELETE(id));
}
