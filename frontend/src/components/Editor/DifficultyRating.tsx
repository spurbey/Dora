import { cn } from '@/lib/utils';

interface DifficultyRatingProps {
  value?: number;
  onChange: (value: number) => void;
}

export function DifficultyRating({ value = 0, onChange }: DifficultyRatingProps) {
  return (
    <div className="flex gap-2">
      {[1, 2, 3, 4, 5].map((rating) => (
        <button
          key={rating}
          type="button"
          className={cn(
            'h-8 w-8 rounded-full border border-white/10 text-sm text-white/70 transition',
            value >= rating ? 'bg-emerald-500/40 text-white' : 'bg-white/5'
          )}
          onClick={() => onChange(rating)}
        >
          {rating}
        </button>
      ))}
    </div>
  );
}
