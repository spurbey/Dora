import { useQuery } from '@tanstack/react-query';
import * as routeService from '@/services/routeService';

export function useRoutes(tripId: string) {
  return useQuery({
    queryKey: ['routes', tripId],
    queryFn: () => routeService.getRoutes(tripId),
    enabled: !!tripId,
  });
}
