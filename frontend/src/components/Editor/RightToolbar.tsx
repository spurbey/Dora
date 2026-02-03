import { Building2, MapPin, Route, PenLine, Layers, Navigation, Car, Bike, User } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useEditorStore } from '@/store/editorStore';

export function RightToolbar() {
  const {
    editMode,
    setEditMode,
    drawingTransportMode,
    setDrawingTransportMode,
    setTempRoute,
    selectedRoute,
  } = useEditorStore();
  const isDrawing = editMode === 'draw-route';
  const isWaypointMode = editMode === 'add-waypoint';

  return (
    <aside className="flex w-full flex-row gap-2 rounded-2xl border border-white/10 bg-white/5 p-3 max-xl:order-3 xl:w-20 xl:flex-col">
      <Button
        variant="ghost"
        className="h-12 w-full flex-1 rounded-xl border border-white/10 bg-white/5 text-white/70 hover:bg-emerald-500/15 hover:text-emerald-100 xl:h-12 xl:w-12 xl:flex-none"
        title="Add City"
      >
        <Building2 className="h-5 w-5" />
      </Button>

      <Button
        variant="ghost"
        className="h-12 w-full flex-1 rounded-xl border border-white/10 bg-white/5 text-white/70 hover:bg-emerald-500/15 hover:text-emerald-100 xl:h-12 xl:w-12 xl:flex-none"
        title="Add Place"
      >
        <MapPin className="h-5 w-5" />
      </Button>

      <div className="flex flex-col items-center gap-2">
        <Button
          variant={isDrawing ? 'default' : 'ghost'}
          className="h-12 w-full flex-1 rounded-xl border border-white/10 bg-white/5 text-white/70 hover:bg-emerald-500/15 hover:text-emerald-100 xl:h-12 xl:w-12 xl:flex-none"
          title="Draw Route"
          onClick={() => {
            if (isDrawing) {
              setTempRoute(null);
              setEditMode('view');
            } else {
              setEditMode('draw-route');
            }
          }}
        >
          <Route className="h-5 w-5" />
        </Button>

        {isDrawing && (
          <div className="flex w-full flex-row gap-2 xl:flex-col">
            <Button
              variant={drawingTransportMode === 'car' ? 'default' : 'ghost'}
              size="icon"
              className="h-9 w-9 rounded-lg border border-white/10 bg-white/5 text-white/70 hover:bg-emerald-500/15 hover:text-emerald-100"
              title="Car"
              onClick={() => setDrawingTransportMode('car')}
            >
              <Car className="h-4 w-4" />
            </Button>
            <Button
              variant={drawingTransportMode === 'bike' ? 'default' : 'ghost'}
              size="icon"
              className="h-9 w-9 rounded-lg border border-white/10 bg-white/5 text-white/70 hover:bg-emerald-500/15 hover:text-emerald-100"
              title="Bike"
              onClick={() => setDrawingTransportMode('bike')}
            >
              <Bike className="h-4 w-4" />
            </Button>
            <Button
              variant={drawingTransportMode === 'foot' ? 'default' : 'ghost'}
              size="icon"
              className="h-9 w-9 rounded-lg border border-white/10 bg-white/5 text-white/70 hover:bg-emerald-500/15 hover:text-emerald-100"
              title="Walk"
              onClick={() => setDrawingTransportMode('foot')}
            >
              <User className="h-4 w-4" />
            </Button>
          </div>
        )}
      </div>

      {selectedRoute && (
        <Button
          variant={isWaypointMode ? 'default' : 'ghost'}
          className="h-12 w-full flex-1 rounded-xl border border-white/10 bg-white/5 text-white/70 hover:bg-emerald-500/15 hover:text-emerald-100 xl:h-12 xl:w-12 xl:flex-none"
          title="Add Waypoint"
          onClick={() => setEditMode(isWaypointMode ? 'view' : 'add-waypoint')}
        >
          <MapPin className="h-5 w-5" />
        </Button>
      )}

      <Button
        variant="ghost"
        className="h-12 w-full flex-1 rounded-xl border border-white/10 bg-white/5 text-white/70 hover:bg-emerald-500/15 hover:text-emerald-100 xl:h-12 xl:w-12 xl:flex-none"
        title="Annotate"
      >
        <PenLine className="h-5 w-5" />
      </Button>

      <Button
        variant="ghost"
        className="h-12 w-full flex-1 rounded-xl border border-white/10 bg-white/5 text-white/70 hover:bg-emerald-500/15 hover:text-emerald-100 xl:h-12 xl:w-12 xl:flex-none"
        title="Layers"
      >
        <Layers className="h-5 w-5" />
      </Button>

      <Button
        variant="ghost"
        className="h-12 w-full flex-1 rounded-xl border border-white/10 bg-white/5 text-white/70 hover:bg-emerald-500/15 hover:text-emerald-100 xl:h-12 xl:w-12 xl:flex-none"
        title="Navigate"
      >
        <Navigation className="h-5 w-5" />
      </Button>
    </aside>
  );
}
