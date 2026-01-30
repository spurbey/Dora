import { api } from '@/services/api';
import { API_ENDPOINTS } from '@/utils/constants';
import type { Trip, TripCreate, TripUpdate, TripListResponse } from '@/types/trip';

export async function getTrips(): Promise<Trip[]> {
  const response = await api.get<TripListResponse>(API_ENDPOINTS.TRIPS.LIST);
  return response.trips;
}

export async function createTrip(data: TripCreate): Promise<Trip> {
  return api.post<Trip, TripCreate>(API_ENDPOINTS.TRIPS.CREATE, data);
}

export async function getTrip(id: string): Promise<Trip> {
  return api.get<Trip>(API_ENDPOINTS.TRIPS.DETAIL(id));
}

export async function updateTrip(id: string, data: TripUpdate): Promise<Trip> {
  return api.patch<Trip, TripUpdate>(API_ENDPOINTS.TRIPS.UPDATE(id), data);
}

export async function deleteTrip(id: string): Promise<void> {
  await api.delete(API_ENDPOINTS.TRIPS.DELETE(id));
}
