import { ArrowLeft, Calendar, Edit2, Trash2, Share2, Eye, Lock, Globe } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';
import type { Trip } from '@/types/trip';

interface TripHeaderProps {
  trip: Trip;
  onEdit: () => void;
  onDelete: () => void;
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
      weekday: 'short',
      month: 'long',
      day: 'numeric',
      year: 'numeric',
    });
  };

  if (start && end) {
    return `${formatDate(start)} - ${formatDate(end)}`;
  }
  if (start) {
    return `Starting ${formatDate(start)}`;
  }
  return `Until ${formatDate(end!)}`;
}

export function TripHeader({ trip, onEdit, onDelete }: TripHeaderProps) {
  const navigate = useNavigate();
  const dateRange = formatDateRange(trip.start_date, trip.end_date);
  const visibility = visibilityConfig[trip.visibility];
  const VisibilityIcon = visibility.icon;

  return (
    <div className="mb-6">
      {/* Back button */}
      <button
        onClick={() => navigate('/dashboard')}
        className="mb-4 flex items-center gap-2 text-sm text-white/60 transition-colors hover:text-white"
      >
        <ArrowLeft className="h-4 w-4" />
        Back to Dashboard
      </button>

      {/* Header content */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div className="flex-1">
          <div className="mb-2 flex flex-wrap items-center gap-3">
            <h1 className="text-2xl font-bold text-white sm:text-3xl">{trip.title}</h1>
            <div
              className={cn(
                'flex items-center gap-1 rounded-full px-2 py-1 text-xs font-medium',
                visibility.className
              )}
            >
              <VisibilityIcon className="h-3 w-3" />
              {visibility.label}
            </div>
          </div>

          {trip.description && (
            <p className="mb-3 text-white/60">{trip.description}</p>
          )}

          {dateRange && (
            <div className="flex items-center gap-2 text-sm text-white/50">
              <Calendar className="h-4 w-4" />
              {dateRange}
            </div>
          )}
        </div>

        {/* Actions */}
        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            size="sm"
            className="text-white/70 hover:bg-white/10 hover:text-white"
            disabled
            title="Share (coming in Phase 5)"
          >
            <Share2 className="mr-2 h-4 w-4" />
            Share
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={onEdit}
            className="text-white/70 hover:bg-white/10 hover:text-white"
          >
            <Edit2 className="mr-2 h-4 w-4" />
            Edit
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={onDelete}
            className="text-red-400 hover:bg-red-500/10 hover:text-red-300"
          >
            <Trash2 className="mr-2 h-4 w-4" />
            Delete
          </Button>
        </div>
      </div>
    </div>
  );
}
