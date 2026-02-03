import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useToast } from '@/components/ui/use-toast';
import { routeService } from '@/services/routeService';
import type { RouteCreate } from '@/types/route';

export function useCreateRoute(tripId: string) {
  const queryClient = useQueryClient();
  const { toast } = useToast();

  return useMutation({
    mutationFn: (data: RouteCreate) => routeService.createRoute(tripId, data),
    onSuccess: (newRoute) => {
      queryClient.invalidateQueries({ queryKey: ['editor-components', tripId] });
      queryClient.invalidateQueries({ queryKey: ['routes', tripId] });

      toast({
        title: 'Route saved',
        description: newRoute.distance_km
          ? `${newRoute.distance_km.toFixed(1)} km route added`
          : 'Route added to your trip',
      });
    },
    onError: (error: Error) => {
      toast({
        title: 'Failed to save route',
        description: error.message || 'Unknown error',
        variant: 'destructive',
      });
    },
  });
}
