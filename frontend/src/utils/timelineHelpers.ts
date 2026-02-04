import type { TripComponent } from '@/types/component';
import type { TimelineItem } from '@/store/editorStore';

export const buildTimelineId = (item: Pick<TimelineItem, 'id' | 'type'>) =>
  `${item.type}:${item.id}`;

export const parseTimelineId = (value: string) => {
  const [type, id] = value.split(':');
  if (!type || !id) return null;
  if (type !== 'place' && type !== 'route') return null;
  return { type, id } as const;
};

export const normalizeTimeline = (components: TripComponent[]): TimelineItem[] =>
  components
    .slice()
    .sort((a, b) => a.order_in_trip - b.order_in_trip)
    .map((component) => ({
      type: component.component_type,
      id: component.id,
      order: component.order_in_trip,
      name: component.name,
    }));

export const formatTime = (value?: string | null) => {
  if (!value) return null;
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return null;
  return date.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' });
};

