import { MapPin, Image as ImageIcon, MoreVertical } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { cn } from '@/lib/utils';
import type { Place } from '@/types/place';

interface PlaceCardProps {
  place: Place;
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

export function PlaceCard({ place, onEdit, onDelete, onClick }: PlaceCardProps) {
  const photoCount = place.photos?.length || 0;
  const placeTypeLabel = place.place_type
    ? place.place_type.charAt(0).toUpperCase() + place.place_type.slice(1)
    : 'Place';
  const emoji = PLACE_TYPE_EMOJI[place.place_type || 'other'] || '📍';

  const handleMenuClick = (e: React.MouseEvent) => {
    e.stopPropagation();
  };

  return (
    <Card
      className={cn(
        'group border-white/10 bg-white/5 transition-all hover:border-emerald-500/30 hover:bg-white/10',
        onClick && 'cursor-pointer'
      )}
      onClick={onClick}
    >
      <CardContent className="p-4">
        <div className="flex items-start justify-between gap-3">
          <div className="flex-1 min-w-0">
            {/* Place Name */}
            <div className="flex items-center gap-2 mb-1">
              <span className="text-xl">{emoji}</span>
              <h3 className="font-semibold text-white truncate group-hover:text-emerald-400">
                {place.name}
              </h3>
            </div>

            {/* Place Type Badge */}
            <div className="flex items-center gap-2 mb-2">
              <span className="inline-flex items-center gap-1 rounded-full bg-teal-500/20 px-2 py-0.5 text-xs font-medium text-teal-300">
                <MapPin className="h-3 w-3" />
                {placeTypeLabel}
              </span>
              {photoCount > 0 && (
                <span className="flex items-center gap-1 text-xs text-white/50">
                  <ImageIcon className="h-3 w-3" />
                  {photoCount}
                </span>
              )}
            </div>

            {/* Notes Preview */}
            {place.user_notes && (
              <p className="line-clamp-2 text-sm text-white/60">{place.user_notes}</p>
            )}

            {/* Coordinates */}
            <p className="mt-2 text-xs text-white/40">
              {place.lat.toFixed(4)}, {place.lng.toFixed(4)}
            </p>
          </div>

          {/* Action Menu */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild onClick={handleMenuClick}>
              <Button
                variant="ghost"
                size="icon"
                className="h-8 w-8 text-white/60 hover:text-white hover:bg-white/10"
              >
                <MoreVertical className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="bg-slate-900 border-white/10">
              <DropdownMenuItem
                onClick={(e) => {
                  e.stopPropagation();
                  onEdit();
                }}
                className="text-white"
              >
                Edit
              </DropdownMenuItem>
              <DropdownMenuItem
                onClick={(e) => {
                  e.stopPropagation();
                  onDelete();
                }}
                className="text-red-500 focus:text-red-500"
              >
                Delete
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </CardContent>
    </Card>
  );
}
