import { useNavigate } from 'react-router-dom';
import { Calendar, MapPin, MoreVertical, Eye, Lock, Globe } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { cn } from '@/lib/utils';
import type { Trip } from '@/types/trip';

interface TripCardProps {
  trip: Trip;
  onEdit: (trip: Trip) => void;
  onDelete: (id: string) => void;
}

const visibilityConfig = {
  private: { icon: Lock, label: 'Private', className: 'bg-slate-500/20 text-slate-300' },
  unlisted: { icon: Eye, label: 'Unlisted', className: 'bg-yellow-500/20 text-yellow-300' },
  public: { icon: Globe, label: 'Public', className: 'bg-emerald-500/20 text-emerald-300' },
};

function formatDateRange(start?: string | null, end?: string | null): string | null {
  if (!start && !end) return null;

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
  };

  if (start && end) {
    return `${formatDate(start)} - ${formatDate(end)}`;
  }
  if (start) {
    return `From ${formatDate(start)}`;
  }
  return `Until ${formatDate(end!)}`;
}

export function TripCard({ trip, onEdit, onDelete }: TripCardProps) {
  const navigate = useNavigate();
  const dateRange = formatDateRange(trip.start_date, trip.end_date);
  const visibility = visibilityConfig[trip.visibility];
  const VisibilityIcon = visibility.icon;

  const handleClick = () => {
    navigate(`/trips/${trip.id}`);
  };

  const handleMenuClick = (e: React.MouseEvent) => {
    e.stopPropagation();
  };

  return (
    <Card
      className="group cursor-pointer overflow-hidden border-white/10 bg-white/5 transition-all hover:border-emerald-500/30 hover:bg-white/10"
      onClick={handleClick}
    >
      {/* Cover Photo or Gradient */}
      <div
        className={cn(
          'relative h-40 bg-gradient-to-br from-emerald-600 via-teal-600 to-cyan-600',
          trip.cover_photo_url && 'bg-cover bg-center'
        )}
        style={
          trip.cover_photo_url
            ? { backgroundImage: `url(${trip.cover_photo_url})` }
            : undefined
        }
      >
        {/* Visibility Badge */}
        <div
          className={cn(
            'absolute left-3 top-3 flex items-center gap-1 rounded-full px-2 py-1 text-xs font-medium',
            visibility.className
          )}
        >
          <VisibilityIcon className="h-3 w-3" />
          {visibility.label}
        </div>

        {/* Action Menu */}
        <div className="absolute right-3 top-3">
          <DropdownMenu>
            <DropdownMenuTrigger asChild onClick={handleMenuClick}>
              <Button
                variant="ghost"
                size="icon"
                className="h-8 w-8 bg-black/30 text-white hover:bg-black/50"
              >
                <MoreVertical className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem
                onClick={(e) => {
                  e.stopPropagation();
                  onEdit(trip);
                }}
              >
                Edit
              </DropdownMenuItem>
              <DropdownMenuItem
                onClick={(e) => {
                  e.stopPropagation();
                  onDelete(trip.id);
                }}
                className="text-red-500 focus:text-red-500"
              >
                Delete
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>

      <CardContent className="p-4">
        <h3 className="mb-2 line-clamp-1 text-lg font-semibold text-white group-hover:text-emerald-400">
          {trip.title}
        </h3>

        {trip.description && (
          <p className="mb-3 line-clamp-2 text-sm text-white/60">{trip.description}</p>
        )}

        <div className="flex flex-wrap items-center gap-3 text-xs text-white/50">
          {dateRange && (
            <div className="flex items-center gap-1">
              <Calendar className="h-3.5 w-3.5" />
              {dateRange}
            </div>
          )}
          <div className="flex items-center gap-1">
            <MapPin className="h-3.5 w-3.5" />
            {trip.views_count ?? 0} places
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
