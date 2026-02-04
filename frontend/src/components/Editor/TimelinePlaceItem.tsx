import { MapPin, UtensilsCrossed, Hotel, Landmark, Camera } from 'lucide-react';
import type { Place } from '@/types/place';
import { formatTime } from '@/utils/timelineHelpers';

const iconMap: Record<string, typeof MapPin> = {
  restaurant: UtensilsCrossed,
  cafe: UtensilsCrossed,
  hotel: Hotel,
  attraction: Landmark,
  photo: Camera,
};

interface TimelinePlaceItemProps {
  place: Place;
  time?: string | null;
}

export function TimelinePlaceItem({ place, time }: TimelinePlaceItemProps) {
  const Icon = place.place_type ? iconMap[place.place_type] || MapPin : MapPin;
  const photoCount = place.photos?.length ?? 0;

  return (
    <div className="space-y-1">
      <div className="flex items-center gap-2 text-sm text-white">
        <Icon className="h-4 w-4 text-emerald-300" />
        <span className="font-semibold">{place.name}</span>
      </div>
      <div className="flex items-center gap-3 text-[11px] text-white/60">
        {time && <span>{formatTime(time)}</span>}
        <span>{place.place_type ?? 'Place'}</span>
        {photoCount > 0 && <span>{photoCount} photos</span>}
      </div>
    </div>
  );
}
