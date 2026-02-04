import {
  Car,
  Bike,
  Footprints,
  Plane,
  Bus,
  Train,
  Route as RouteIcon,
  Globe,
  Lock,
} from 'lucide-react';
import type { Route } from '@/types/route';
import type { RouteMetadata } from '@/types/routeMetadata';

const iconMap = {
  car: Car,
  bike: Bike,
  foot: Footprints,
  air: Plane,
  bus: Bus,
  train: Train,
};

interface TimelineRouteItemProps {
  route: Route;
  waypointsCount: number;
  metadata?: RouteMetadata | null;
  isPublic?: boolean;
}

export function TimelineRouteItem({
  route,
  waypointsCount,
  metadata,
  isPublic = false,
}: TimelineRouteItemProps) {
  const Icon = iconMap[route.transport_mode] ?? RouteIcon;
  const VisibilityIcon = isPublic ? Globe : Lock;
  const distance = route.distance_km ? `${route.distance_km.toFixed(1)} km` : 'Distance N/A';
  const duration = route.duration_mins ? `${route.duration_mins} mins` : 'Duration N/A';
  const routeName = route.name ?? 'Route';

  return (
    <div className="space-y-1">
      <div className="flex items-center gap-2 text-sm text-white">
        <Icon className="h-4 w-4 text-emerald-300" />
        <span className="font-semibold">{routeName}</span>
        <VisibilityIcon className="ml-auto h-3.5 w-3.5 text-white/50" />
      </div>
      <div className="flex flex-wrap items-center gap-3 text-[11px] text-white/60">
        <span>
          {distance} · {duration}
        </span>
        <span>{waypointsCount} waypoints</span>
        {metadata?.highlights?.length ? (
          <span>{metadata.highlights.slice(0, 2).join(', ')}</span>
        ) : null}
      </div>
    </div>
  );
}
