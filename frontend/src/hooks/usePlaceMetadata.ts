import { useEffect } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { placeMetadataService } from '@/services/placeMetadataService';
import type { PlaceMetadataCreate } from '@/types/placeMetadata';
import { useEditorStore } from '@/store/editorStore';

export function usePlaceMetadata(placeId: string) {
  const queryClient = useQueryClient();
  const { setPlaceMetadata } = useEditorStore();

  const query = useQuery({
    queryKey: ['place-metadata', placeId],
    queryFn: () => placeMetadataService.get(placeId),
    enabled: Boolean(placeId),
    retry: false,
  });

  useEffect(() => {
    if (query.data) {
      setPlaceMetadata(placeId, query.data);
    }
  }, [placeId, query.data, setPlaceMetadata]);

  const saveMutation = useMutation({
    mutationFn: async (data: PlaceMetadataCreate) => {
      if (query.data) {
        return placeMetadataService.update(placeId, data);
      }
      return placeMetadataService.create(placeId, data);
    },
    onSuccess: (metadata) => {
      setPlaceMetadata(placeId, metadata);
      queryClient.invalidateQueries({ queryKey: ['place-metadata', placeId] });
    },
  });

  return {
    ...query,
    saveMetadata: saveMutation.mutateAsync,
    isSaving: saveMutation.isPending,
  };
}
