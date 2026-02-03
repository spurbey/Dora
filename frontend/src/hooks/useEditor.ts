import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '@/services/api';
import type { Trip } from '@/types/trip';
import type { TripComponentListResponse } from '@/types/component';
import type { TripUpdate } from '@/types/trip';

export function useEditorTrip(tripId: string) {
  return useQuery({
    queryKey: ['editor-trip', tripId],
    queryFn: () => api.get<Trip>(`/trips/${tripId}`),
    enabled: Boolean(tripId),
  });
}

export function useEditorComponents(tripId: string) {
  return useQuery({
    queryKey: ['editor-components', tripId],
    queryFn: () => api.get<TripComponentListResponse>(`/trips/${tripId}/components`),
    enabled: Boolean(tripId),
  });
}

export function useSaveTrip() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: { id: string; payload: TripUpdate }) =>
      api.patch<Trip>(`/trips/${data.id}`, data.payload),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['editor-trip', variables.id] });
    },
  });
}
