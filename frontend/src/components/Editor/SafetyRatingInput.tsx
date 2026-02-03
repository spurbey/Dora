import { Star } from 'lucide-react';

interface SafetyRatingInputProps {
  value: number;
  onChange: (value: number) => void;
  label?: string;
}

export function SafetyRatingInput({ value, onChange, label = 'How safe is this route?' }: SafetyRatingInputProps) {
  return (
    <div className="space-y-2">
      {label ? <p className="text-xs text-white/60">{label}</p> : null}
      <div className="flex items-center gap-1">
        {Array.from({ length: 5 }).map((_, index) => {
          const rating = index + 1;
          return (
            <button
              key={rating}
              type="button"
              className="rounded-full p-1"
              onClick={() => onChange(rating)}
            >
              <Star
                className={`h-5 w-5 ${rating <= value ? 'text-yellow-400' : 'text-white/30'}`}
                fill={rating <= value ? 'currentColor' : 'none'}
              />
            </button>
          );
        })}
      </div>
    </div>
  );
}
