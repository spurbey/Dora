import { useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { api } from '@/services/api';
import type { TripComponentListResponse } from '@/types/component';
import { useEditorStore } from '@/store/editorStore';
import { normalizeTimeline } from '@/utils/timelineHelpers';

export function useTimeline(tripId: string) {
  const { setTimeline } = useEditorStore();

  const query = useQuery({
    queryKey: ['editor-components', tripId],
    queryFn: () => api.get<TripComponentListResponse>(`/trips/${tripId}/components`),
    enabled: Boolean(tripId),
  });

  useEffect(() => {
    if (query.data) {
      setTimeline(normalizeTimeline(query.data.components));
    }
  }, [query.data, setTimeline]);

  return query;
}
