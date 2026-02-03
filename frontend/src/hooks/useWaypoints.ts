import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { waypointService } from '@/services/waypointService';
import type { WaypointCreate, WaypointUpdate } from '@/types/waypoint';
import { useToast } from '@/components/ui/use-toast';

export function useWaypoints(routeId: string) {
  return useQuery({
    queryKey: ['waypoints', routeId],
    queryFn: () => waypointService.getWaypoints(routeId),
    enabled: !!routeId,
  });
}

export function useCreateWaypoint(routeId: string) {
  const queryClient = useQueryClient();
  const { toast } = useToast();

  return useMutation({
    mutationFn: (data: WaypointCreate) => waypointService.createWaypoint(routeId, data),
    onSuccess: (newWaypoint) => {
      queryClient.invalidateQueries({ queryKey: ['waypoints', routeId] });
      toast({
        title: 'Waypoint added',
        description: `${newWaypoint.name} added to route`,
      });
    },
    onError: (error: Error) => {
      toast({
        title: 'Failed to add waypoint',
        description: error.message || 'Unknown error',
        variant: 'destructive',
      });
    },
  });
}

export function useUpdateWaypoint(routeId: string) {
  const queryClient = useQueryClient();
  const { toast } = useToast();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: WaypointUpdate }) =>
      waypointService.updateWaypoint(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['waypoints', routeId] });
      toast({ title: 'Waypoint updated' });
    },
  });
}

export function useDeleteWaypoint(routeId: string) {
  const queryClient = useQueryClient();
  const { toast } = useToast();

  return useMutation({
    mutationFn: (waypointId: string) => waypointService.deleteWaypoint(waypointId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['waypoints', routeId] });
      toast({ title: 'Waypoint removed' });
    },
  });
}
