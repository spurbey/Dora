import { Clock, MapPin, Route, Plus } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useEditorStore } from '@/store/editorStore';

interface TimelineHeaderProps {
  count: number;
}

export function TimelineHeader({ count }: TimelineHeaderProps) {
  const { setEditMode } = useEditorStore();

  return (
    <div className="mb-4 space-y-3">
      <div className="flex items-center gap-2 text-white">
        <Clock className="h-4 w-4 text-emerald-300" />
        <span className="text-sm font-semibold">
          Timeline {count ? `(${count})` : ''}
        </span>
      </div>
      <div className="flex flex-wrap gap-2">
        <Button
          size="sm"
          variant="outline"
          className="border-white/10 bg-white/5 text-xs text-emerald-100 hover:bg-emerald-500/10"
          onClick={() => setEditMode('add-place')}
        >
          <Plus className="mr-1 h-3 w-3" />
          <MapPin className="mr-1 h-3 w-3" />
          Add Place
        </Button>
        <Button
          size="sm"
          variant="outline"
          className="border-white/10 bg-white/5 text-xs text-emerald-100 hover:bg-emerald-500/10"
          onClick={() => setEditMode('draw-route')}
        >
          <Plus className="mr-1 h-3 w-3" />
          <Route className="mr-1 h-3 w-3" />
          Add Route
        </Button>
      </div>
    </div>
  );
}
