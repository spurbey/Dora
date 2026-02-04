import { useEffect } from 'react';
import { useEditorStore } from '@/store/editorStore';
import { buildTimelineId } from '@/utils/timelineHelpers';

export function useTimelineSync() {
  const { selectedItem, selectedItemSource } = useEditorStore();

  useEffect(() => {
    if (!selectedItem) return;
    if (selectedItem.type !== 'place' && selectedItem.type !== 'route') return;
    if (selectedItemSource !== 'map') return;

    const timelineItem = {
      type: selectedItem.type,
      id: selectedItem.id,
    } as { type: 'place' | 'route'; id: string };

    const element = document.getElementById(
      `timeline-item-${buildTimelineId(timelineItem)}`
    );
    element?.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }, [selectedItem, selectedItemSource]);
}
