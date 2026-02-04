import { useMemo, useRef } from 'react';
import {
  DndContext,
  KeyboardSensor,
  PointerSensor,
  closestCenter,
  useSensor,
  useSensors,
  type DragEndEvent,
} from '@dnd-kit/core';
import { SortableContext, arrayMove, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { useEditorStore, type TimelineItem as TimelineEntry } from '@/store/editorStore';
import { TimelineHeader } from '@/components/Editor/TimelineHeader';
import { TimelineItem } from '@/components/Editor/TimelineItem';
import { TimelinePlaceItem } from '@/components/Editor/TimelinePlaceItem';
import { TimelineRouteItem } from '@/components/Editor/TimelineRouteItem';
import { useTimelineSync } from '@/hooks/useTimelineSync';
import { useReorderComponents } from '@/hooks/useReorderComponents';
import { buildTimelineId, parseTimelineId } from '@/utils/timelineHelpers';

export function LeftTimeline() {
  const {
    trip,
    timeline,
    places,
    routes,
    waypoints,
    routeMetadata,
    selectedItem,
    highlightedItem,
    setSelectedItem,
    setHighlightedItem,
    setTimeline,
  } = useEditorStore();

  useTimelineSync();

  const tripId = trip?.id ?? '';
  const reorderMutation = useReorderComponents(tripId);
  const previousTimeline = useRef(timeline);

  const sensors = useSensors(useSensor(PointerSensor), useSensor(KeyboardSensor));

  const sortedTimeline = useMemo((): TimelineEntry[] => {
    return timeline.slice().sort((a, b) => a.order - b.order);
  }, [timeline]);

  const timelineIds = useMemo(
    () => sortedTimeline.map((item) => buildTimelineId(item)),
    [sortedTimeline]
  );

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;
    if (!over || active.id === over.id) return;

    const activeParsed = parseTimelineId(String(active.id));
    const overParsed = parseTimelineId(String(over.id));
    if (!activeParsed || !overParsed) return;

    const oldIndex = sortedTimeline.findIndex(
      (item) => item.id === activeParsed.id && item.type === activeParsed.type
    );
    const newIndex = sortedTimeline.findIndex(
      (item) => item.id === overParsed.id && item.type === overParsed.type
    );
    if (oldIndex < 0 || newIndex < 0) return;

    previousTimeline.current = sortedTimeline;
    const reordered = (arrayMove(sortedTimeline, oldIndex, newIndex) as TimelineEntry[]).map(
      (item, index) => ({
        ...item,
        order: index,
      })
    );
    setTimeline(reordered);

    reorderMutation.mutate(reordered, {
      onError: () => {
        setTimeline(previousTimeline.current);
      },
    });
  };

  return (
    <aside className="flex w-full flex-col rounded-2xl border border-white/10 bg-white/5 p-4 max-xl:order-2 xl:w-72">
      <TimelineHeader count={timeline.length} />

      <div className="flex flex-1 flex-col gap-3 overflow-hidden">
        {sortedTimeline.length === 0 ? (
          <div className="rounded-xl border border-dashed border-white/15 bg-white/5 p-4 text-xs text-white/60">
            Drag components here to build your journey timeline.
          </div>
        ) : (
          <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
            <SortableContext items={timelineIds} strategy={verticalListSortingStrategy}>
              <div className="flex flex-1 flex-col gap-3 overflow-y-auto pr-1">
                {sortedTimeline.map((item, index) => {
                  const isSelected =
                    selectedItem?.id === item.id && selectedItem.type === item.type;
                  const isHighlighted =
                    highlightedItem?.id === item.id && highlightedItem.type === item.type;
                  const place = item.type === 'place'
                    ? places.find((entry) => entry.id === item.id)
                    : null;
                  const route = item.type === 'route'
                    ? routes.find((entry) => entry.id === item.id)
                    : null;
                  const waypointCount = route ? waypoints[route.id]?.length ?? 0 : 0;

                  return (
                    <div key={buildTimelineId(item)} className="relative">
                      {index !== sortedTimeline.length - 1 && (
                        <div className="absolute left-4 top-11 h-6 w-px border-l border-dashed border-emerald-400/40" />
                      )}
                      <TimelineItem
                        id={buildTimelineId(item)}
                        isSelected={isSelected}
                        isHighlighted={isHighlighted}
                        onClick={() => setSelectedItem({ type: item.type, id: item.id }, 'timeline')}
                        onHover={() => setHighlightedItem({ type: item.type, id: item.id })}
                        onHoverOut={() => setHighlightedItem(null)}
                      >
                        <div className="flex items-start gap-3">
                          <div className="mt-1 flex h-6 w-6 items-center justify-center rounded-full border border-emerald-400/40 bg-emerald-500/20 text-[11px] font-semibold text-emerald-100">
                            {index + 1}
                          </div>
                          <div className="flex-1">
                            {item.type === 'place' && place ? (
                              <TimelinePlaceItem place={place} time={place.created_at} />
                            ) : item.type === 'route' && route ? (
                              <TimelineRouteItem
                                route={route}
                                waypointsCount={waypointCount}
                                metadata={routeMetadata[route.id]}
                              />
                            ) : (
                              <div className="text-xs text-white/60">Loading details...</div>
                            )}
                          </div>
                        </div>
                      </TimelineItem>
                    </div>
                  );
                })}
              </div>
            </SortableContext>
          </DndContext>
        )}
      </div>
    </aside>
  );
}
