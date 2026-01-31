import { ZoomIn, ZoomOut, Maximize2, Navigation } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface MapControlsProps {
  onZoomIn: () => void;
  onZoomOut: () => void;
  onResetView: () => void;
  onGeolocate: () => void;
}

export function MapControls({
  onZoomIn,
  onZoomOut,
  onResetView,
  onGeolocate,
}: MapControlsProps) {
  return (
    <div className="absolute right-4 top-4 flex flex-col gap-2">
      <Button
        variant="secondary"
        size="icon"
        onClick={onZoomIn}
        className="bg-slate-900/90 border-white/10 hover:bg-slate-800"
        title="Zoom in"
      >
        <ZoomIn className="h-4 w-4 text-white" />
      </Button>
      <Button
        variant="secondary"
        size="icon"
        onClick={onZoomOut}
        className="bg-slate-900/90 border-white/10 hover:bg-slate-800"
        title="Zoom out"
      >
        <ZoomOut className="h-4 w-4 text-white" />
      </Button>
      <Button
        variant="secondary"
        size="icon"
        onClick={onResetView}
        className="bg-slate-900/90 border-white/10 hover:bg-slate-800"
        title="Reset view"
      >
        <Maximize2 className="h-4 w-4 text-white" />
      </Button>
      <Button
        variant="secondary"
        size="icon"
        onClick={onGeolocate}
        className="bg-slate-900/90 border-white/10 hover:bg-slate-800"
        title="Go to my location"
      >
        <Navigation className="h-4 w-4 text-white" />
      </Button>
    </div>
  );
}
