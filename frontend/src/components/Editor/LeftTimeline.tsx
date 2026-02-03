import { Clock, Plus } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useEditorStore } from '@/store/editorStore';

export function LeftTimeline() {
  const { timeline } = useEditorStore();

  return (
    <aside className="flex w-full flex-col rounded-2xl border border-white/10 bg-white/5 p-4 max-xl:order-2 xl:w-72">
      <div className="mb-4 flex items-center justify-between">
        <div className="flex items-center gap-2 text-white">
          <Clock className="h-4 w-4 text-emerald-300" />
          <span className="text-sm font-semibold">
            Timeline {timeline.length ? `(${timeline.length})` : ''}
          </span>
        </div>
        <Button size="sm" variant="ghost" className="text-emerald-200 hover:bg-emerald-500/10">
          <Plus className="mr-1 h-3 w-3" />
          Add
        </Button>
      </div>

      <div className="flex flex-1 flex-col gap-3">
        {timeline.length === 0 ? (
          <div className="rounded-xl border border-dashed border-white/15 bg-white/5 p-4 text-xs text-white/60">
            Drag components here to build your journey timeline.
          </div>
        ) : (
          timeline.map((item) => (
            <div key={item.id} className="rounded-xl border border-white/10 bg-white/5 p-3">
              <p className="text-xs text-emerald-200">{item.name ?? 'Untitled'}</p>
              <p className="text-[11px] text-white/50">
                {item.type === 'place' ? 'Place' : 'Route'} • Order {item.order}
              </p>
            </div>
          ))
        )}
      </div>
    </aside>
  );
}
