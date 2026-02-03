import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { routeMetadataService } from '@/services/routeMetadataService';
import type { RouteMetadataCreate } from '@/types/routeMetadata';
import { useToast } from '@/components/ui/use-toast';

export function useRouteMetadata(routeId: string) {
  return useQuery({
    queryKey: ['route-metadata', routeId],
    queryFn: () => routeMetadataService.getMetadata(routeId),
    enabled: !!routeId,
  });
}

export function useCreateRouteMetadata(routeId: string) {
  const queryClient = useQueryClient();
  const { toast } = useToast();

  return useMutation({
    mutationFn: (data: RouteMetadataCreate) => routeMetadataService.createMetadata(routeId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['route-metadata', routeId] });
      toast({ title: 'Metadata saved' });
    },
    onError: (error: Error) => {
      toast({
        title: 'Failed to save metadata',
        description: error.message || 'Unknown error',
        variant: 'destructive',
      });
    },
  });
}

export function useUpdateRouteMetadata(routeId: string) {
  const queryClient = useQueryClient();
  const { toast } = useToast();

  return useMutation({
    mutationFn: (data: RouteMetadataCreate) => routeMetadataService.updateMetadata(routeId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['route-metadata', routeId] });
      toast({ title: 'Metadata updated' });
    },
    onError: (error: Error) => {
      toast({
        title: 'Failed to update metadata',
        description: error.message || 'Unknown error',
        variant: 'destructive',
      });
    },
  });
}

export function useDeleteRouteMetadata(routeId: string) {
  const queryClient = useQueryClient();
  const { toast } = useToast();

  return useMutation({
    mutationFn: () => routeMetadataService.deleteMetadata(routeId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['route-metadata', routeId] });
      toast({ title: 'Metadata removed' });
    },
  });
}
