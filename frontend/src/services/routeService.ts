import { api } from '@/services/api';
import { API_ENDPOINTS } from '@/utils/constants';
import type { Route, RouteListResponse } from '@/types/route';

export async function getRoutes(tripId: string): Promise<Route[]> {
  const response = await api.get<RouteListResponse>(API_ENDPOINTS.ROUTES.LIST(tripId));
  return response.routes;
}
