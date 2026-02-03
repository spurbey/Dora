import { Check, X, Undo } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useEditorStore } from '@/store/editorStore';
import { useRouteDrawing } from '@/hooks/useRouteDrawing';
import { useCreateRoute } from '@/hooks/useCreateRoute';
import type { RouteCreate } from '@/types/route';

interface RoutePreviewPanelProps {
  tripId: string;
}

export function RoutePreviewPanel({ tripId }: RoutePreviewPanelProps) {
  const { editMode, setEditMode, drawingTransportMode, routes, timeline, addRoute } =
    useEditorStore();
  const { tempRoute, clearRoute, undoLastPoint } = useRouteDrawing();
  const createRoute = useCreateRoute(tripId);

  if (editMode !== 'draw-route' || !tempRoute) return null;

  const handleSave = async () => {
    if (!tempRoute.preview) return;

    const routeData: RouteCreate = {
      route_geojson: tempRoute.preview.geojson,
      transport_mode: drawingTransportMode,
      route_category: 'ground',
      distance_km: tempRoute.preview.distance_km,
      duration_mins: tempRoute.preview.duration_mins,
      order_in_trip: timeline.length || routes.length,
    };

    const newRoute = await createRoute.mutateAsync(routeData);
    addRoute(newRoute);
    clearRoute();
    setEditMode('view');
  };

  return (
    <div className="absolute bottom-20 left-1/2 z-10 w-[320px] -translate-x-1/2 rounded-2xl border border-white/10 bg-slate-950/90 p-4 text-white shadow-xl backdrop-blur">
      <h3 className="text-sm font-semibold">Route Preview</h3>

      {tempRoute.preview ? (
        <>
          <div className="mt-3 space-y-2 text-xs text-white/70">
            <div className="flex items-center justify-between">
              <span>Distance</span>
              <span className="font-medium text-white">
                {tempRoute.preview.distance_km.toFixed(1)} km
              </span>
            </div>
            <div className="flex items-center justify-between">
              <span>Duration</span>
              <span className="font-medium text-white">{tempRoute.preview.duration_mins} mins</span>
            </div>
            <div className="flex items-center justify-between">
              <span>Mode</span>
              <span className="font-medium capitalize text-white">{drawingTransportMode}</span>
            </div>
          </div>

          <div className="mt-4 flex items-center gap-2">
            <Button
              size="sm"
              className="flex-1"
              onClick={handleSave}
              disabled={createRoute.isPending}
            >
              <Check className="mr-1 h-4 w-4" />
              Save Route
            </Button>
            <Button size="sm" variant="outline" onClick={() => void undoLastPoint()}>
              <Undo className="h-4 w-4" />
            </Button>
            <Button
              size="sm"
              variant="destructive"
              onClick={() => {
                clearRoute();
                setEditMode('view');
              }}
            >
              <X className="h-4 w-4" />
            </Button>
          </div>
        </>
      ) : (
        <p className="mt-3 text-xs text-white/60">
          Click {Math.max(0, 2 - tempRoute.points.length)} more point(s) to preview a
          route.
        </p>
      )}
    </div>
  );
}
