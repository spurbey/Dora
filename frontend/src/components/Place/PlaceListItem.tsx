import { MapPin, Edit, Trash2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';
import type { Place } from '@/types/place';

interface PlaceListItemProps {
  place: Place;
  index: number;
  onEdit: () => void;
  onDelete: () => void;
  onClick?: () => void;
}

const PLACE_TYPE_EMOJI: Record<string, string> = {
  restaurant: '🍽️',
  hotel: '🏨',
  attraction: '🎭',
  cafe: '☕',
  bar: '🍺',
  museum: '🏛️',
  park: '🌳',
  shop: '🛍️',
  other: '📍',
};

export function PlaceListItem({ place, index, onEdit, onDelete, onClick }: PlaceListItemProps) {
  const emoji = PLACE_TYPE_EMOJI[place.place_type || 'other'] || '📍';
  const placeTypeLabel = place.place_type
    ? place.place_type.charAt(0).toUpperCase() + place.place_type.slice(1)
    : null;

  return (
    <div className="flex gap-4">
      {/* Timeline Number Badge */}
      <div className="flex flex-col items-center">
        <div className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-emerald-600 to-teal-600 text-sm font-semibold text-white">
          {index + 1}
        </div>
        {/* Connecting Line (except for last item, handled by parent) */}
        <div className="mt-2 h-full w-px bg-white/10" />
      </div>

      {/* Place Content */}
      <div
        className={cn(
          'flex-1 rounded-lg border border-white/10 bg-white/5 p-4 transition-colors hover:border-emerald-500/30 hover:bg-white/10',
          onClick && 'cursor-pointer'
        )}
        onClick={onClick}
      >
        <div className="flex items-start justify-between gap-3">
          <div className="flex-1 min-w-0">
            {/* Place Name */}
            <div className="flex items-center gap-2 mb-1">
              <span className="text-xl">{emoji}</span>
              <h4 className="font-semibold text-white">{place.name}</h4>
            </div>

            {/* Place Type */}
            {placeTypeLabel && (
              <div className="mb-2 flex items-center gap-1 text-xs text-white/50">
                <MapPin className="h-3 w-3" />
                {placeTypeLabel}
              </div>
            )}

            {/* Notes */}
            {place.user_notes && (
              <p className="text-sm text-white/70 line-clamp-2">{place.user_notes}</p>
            )}
          </div>

          {/* Action Buttons */}
          <div className="flex gap-1">
            <Button
              variant="ghost"
              size="icon"
              onClick={(e) => {
                e.stopPropagation();
                onEdit();
              }}
              className="h-8 w-8 text-white/60 hover:text-white hover:bg-white/10"
            >
              <Edit className="h-4 w-4" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              onClick={(e) => {
                e.stopPropagation();
                onDelete();
              }}
              className="h-8 w-8 text-red-500/60 hover:text-red-500 hover:bg-red-500/10"
            >
              <Trash2 className="h-4 w-4" />
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
