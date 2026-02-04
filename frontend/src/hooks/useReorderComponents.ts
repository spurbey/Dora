import { useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/services/api';
import type { TimelineItem } from '@/store/editorStore';

interface ReorderPayloadItem {
  id: string;
  component_type: 'place' | 'route';
  new_order: number;
}

export function useReorderComponents(tripId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (items: TimelineItem[]) => {
      const payload = items.map<ReorderPayloadItem>((item, index) => ({
        id: item.id,
        component_type: item.type,
        new_order: index,
      }));

      return api.patch(`/trips/${tripId}/components/reorder`, { items: payload });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['editor-components', tripId] });
    },
  });
}

