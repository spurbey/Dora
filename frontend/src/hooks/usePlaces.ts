import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import * as placeService from '@/services/placeService';
import type { PlaceUpdate } from '@/types/place';

// List places for trip
export function usePlaces(tripId: string) {
  return useQuery({
    queryKey: ['places', tripId],
    queryFn: async () => {
      const response = await placeService.getPlaces(tripId);
      return response.places;
    },
    enabled: !!tripId,
  });
}

// Get single place
export function usePlace(id: string) {
  return useQuery({
    queryKey: ['place', id],
    queryFn: () => placeService.getPlace(id),
    enabled: !!id,
  });
}

// Create place
export function useCreatePlace() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: placeService.createPlace,
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['places', data.trip_id] });
    },
  });
}

// Update place
export function useUpdatePlace() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: PlaceUpdate }) =>
      placeService.updatePlace(id, data),
    onSuccess: (data, variables) => {
      queryClient.invalidateQueries({ queryKey: ['places', data.trip_id] });
      queryClient.invalidateQueries({ queryKey: ['place', variables.id] });
    },
  });
}

// Delete place
export function useDeletePlace() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id }: { id: string; tripId: string }) =>
      placeService.deletePlace(id),
    onSuccess: (_, { tripId }) => {
      queryClient.invalidateQueries({ queryKey: ['places', tripId] });
    },
  });
}
