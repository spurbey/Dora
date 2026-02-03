import { api } from '@/services/api';
import type { RouteMetadata, RouteMetadataCreate } from '@/types/routeMetadata';

export const routeMetadataService = {
  async getMetadata(routeId: string): Promise<RouteMetadata | null> {
    try {
      return await api.get<RouteMetadata>(`/routes/${routeId}/metadata`);
    } catch {
      return null;
    }
  },

  async createMetadata(routeId: string, data: RouteMetadataCreate): Promise<RouteMetadata> {
    return api.post<RouteMetadata, RouteMetadataCreate>(`/routes/${routeId}/metadata`, data);
  },

  async updateMetadata(routeId: string, data: RouteMetadataCreate): Promise<RouteMetadata> {
    return api.patch<RouteMetadata, RouteMetadataCreate>(`/routes/${routeId}/metadata`, data);
  },

  async deleteMetadata(routeId: string): Promise<void> {
    await api.delete(`/routes/${routeId}/metadata`);
  },
};
