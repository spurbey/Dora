import { api } from '@/services/api';
import { API_ENDPOINTS } from '@/utils/constants';
import type { SearchResponse } from '@/types/search';

export interface SearchParams {
  query: string;
  lat: number;
  lng: number;
  radius_km?: number;
  limit?: number;
}

// GET /search/places?query={q}&lat={lat}&lng={lng}&radius_km={r}&limit={n}
export async function searchPlaces(params: SearchParams): Promise<SearchResponse> {
  const queryParams = new URLSearchParams({
    query: params.query,
    lat: params.lat.toString(),
    lng: params.lng.toString(),
    ...(params.radius_km && { radius_km: params.radius_km.toString() }),
    ...(params.limit && { limit: params.limit.toString() }),
  });

  return api.get<SearchResponse>(`${API_ENDPOINTS.SEARCH.PLACES}?${queryParams}`);
}
