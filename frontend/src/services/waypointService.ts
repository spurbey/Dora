import { api } from '@/services/api';
import type { Waypoint, WaypointCreate, WaypointUpdate } from '@/types/waypoint';

export const waypointService = {
  async getWaypoints(routeId: string): Promise<Waypoint[]> {
    const response = await api.get<{ waypoints: Waypoint[] }>(`/routes/${routeId}/waypoints`);
    return response.waypoints || [];
  },

  async createWaypoint(routeId: string, data: WaypointCreate): Promise<Waypoint> {
    return api.post<Waypoint, WaypointCreate>(`/routes/${routeId}/waypoints`, data);
  },

  async updateWaypoint(waypointId: string, data: WaypointUpdate): Promise<Waypoint> {
    return api.patch<Waypoint, WaypointUpdate>(`/waypoints/${waypointId}`, data);
  },

  async deleteWaypoint(waypointId: string): Promise<void> {
    await api.delete(`/waypoints/${waypointId}`);
  },
};
