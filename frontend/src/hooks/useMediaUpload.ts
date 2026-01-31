import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import * as mediaService from '@/services/mediaService';
import type { MediaUploadData } from '@/types/media';

export function useMediaUpload() {
  const [uploadProgress, setUploadProgress] = useState(0);
  const queryClient = useQueryClient();

  const uploadMutation = useMutation({
    mutationFn: mediaService.uploadMedia,
    onSuccess: (data) => {
      // Invalidate place detail query
      queryClient.invalidateQueries({ queryKey: ['place', data.trip_place_id] });
      // Invalidate places LIST query with trip_id (CRITICAL FIX)
      queryClient.invalidateQueries({ queryKey: ['places', data.trip_id] });
      setUploadProgress(0);
    },
  });

  const uploadWithProgress = async (uploadData: MediaUploadData) => {
    setUploadProgress(0);
    // Note: Upload progress tracking would require axios onUploadProgress
    // For now, just show loading state
    return uploadMutation.mutateAsync(uploadData);
  };

  return {
    uploadWithProgress,
    uploadProgress,
    isUploading: uploadMutation.isPending,
    error: uploadMutation.error,
  };
}

export function useDeleteMedia() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id }: { id: string; placeId: string; tripId: string }) =>
      mediaService.deleteMedia(id),
    onSuccess: (_, { placeId, tripId }) => {
      // Invalidate place detail query
      queryClient.invalidateQueries({ queryKey: ['place', placeId] });
      // Invalidate places LIST query with trip_id (CRITICAL FIX)
      queryClient.invalidateQueries({ queryKey: ['places', tripId] });
    },
  });
}
