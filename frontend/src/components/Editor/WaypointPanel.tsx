import { X, Edit, Trash } from 'lucide-react';
import { Button } from '@/components/ui/button';
import type { Waypoint } from '@/types/waypoint';

interface WaypointPanelProps {
  waypoint: Waypoint;
  onEdit: () => void;
  onDelete: () => void;
  onClose: () => void;
}

export function WaypointPanel({ waypoint, onEdit, onDelete, onClose }: WaypointPanelProps) {
  return (
    <div className="absolute right-4 top-20 z-10 w-80 rounded-2xl border border-white/10 bg-slate-950/90 p-4 text-white shadow-xl">
      <div className="mb-3 flex items-start justify-between">
        <div>
          <h3 className="text-lg font-semibold">{waypoint.name}</h3>
          <p className="text-xs capitalize text-white/60">{waypoint.waypoint_type}</p>
        </div>
        <Button variant="ghost" size="icon" onClick={onClose}>
          <X className="h-4 w-4" />
        </Button>
      </div>

      {waypoint.notes && (
        <div className="mb-4 text-sm text-white/80">{waypoint.notes}</div>
      )}

      <div className="mb-4 text-xs text-white/50">
        <div>Lat: {waypoint.lat.toFixed(6)}</div>
        <div>Lng: {waypoint.lng.toFixed(6)}</div>
      </div>

      <div className="flex gap-2">
        <Button size="sm" variant="outline" onClick={onEdit} className="flex-1">
          <Edit className="mr-1 h-3 w-3" />
          Edit
        </Button>
        <Button size="sm" variant="destructive" onClick={onDelete}>
          <Trash className="mr-1 h-3 w-3" />
          Delete
        </Button>
      </div>
    </div>
  );
}
