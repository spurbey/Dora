import { useEffect } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { tripMetadataService } from '@/services/tripMetadataService';
import type { TripMetadataCreate } from '@/types/tripMetadata';
import { useEditorStore } from '@/store/editorStore';

export function useTripMetadata(tripId: string) {
  const queryClient = useQueryClient();
  const { setTripMetadata } = useEditorStore();

  const query = useQuery({
    queryKey: ['trip-metadata', tripId],
    queryFn: () => tripMetadataService.get(tripId),
    enabled: Boolean(tripId),
    retry: false,
  });

  useEffect(() => {
    if (query.data) {
      setTripMetadata(query.data);
    }
  }, [query.data, setTripMetadata]);

  const saveMutation = useMutation({
    mutationFn: async (data: TripMetadataCreate) => {
      if (query.data) {
        return tripMetadataService.update(tripId, data);
      }
      return tripMetadataService.create(tripId, data);
    },
    onSuccess: (metadata) => {
      setTripMetadata(metadata);
      queryClient.invalidateQueries({ queryKey: ['trip-metadata', tripId] });
    },
  });

  return {
    ...query,
    saveMetadata: saveMutation.mutateAsync,
    isSaving: saveMutation.isPending,
  };
}
