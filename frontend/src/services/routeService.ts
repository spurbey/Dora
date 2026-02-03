import { api } from '@/services/api';
import { API_ENDPOINTS } from '@/utils/constants';
import type { Route, RouteCreate, RouteListResponse } from '@/types/route';

export async function getRoutes(tripId: string): Promise<Route[]> {
  const response = await api.get<RouteListResponse>(API_ENDPOINTS.ROUTES.LIST(tripId));
  return response.routes;
}

export async function createRoute(tripId: string, data: RouteCreate): Promise<Route> {
  return api.post<Route, RouteCreate>(API_ENDPOINTS.ROUTES.CREATE(tripId), data);
}

export async function updateRoute(routeId: string, data: Partial<RouteCreate>): Promise<Route> {
  return api.patch<Route, Partial<RouteCreate>>(API_ENDPOINTS.ROUTES.DETAIL(routeId), data);
}

export async function deleteRoute(routeId: string): Promise<void> {
  await api.delete(API_ENDPOINTS.ROUTES.DETAIL(routeId));
}

export const routeService = {
  getRoutes,
  createRoute,
  updateRoute,
  deleteRoute,
};
