import { cn } from '@/lib/utils';

interface QualityScoreBadgeProps {
  score: number;
  title?: string;
  onClick?: () => void;
}

function getColor(score: number) {
  if (score >= 0.8) return 'bg-emerald-500/30 text-emerald-100';
  if (score >= 0.6) return 'bg-emerald-400/20 text-emerald-100';
  if (score >= 0.3) return 'bg-yellow-500/20 text-yellow-100';
  return 'bg-rose-500/20 text-rose-100';
}

export function QualityScoreBadge({ score, title, onClick }: QualityScoreBadgeProps) {
  const percent = Math.round(score * 100);

  return (
    <button
      type="button"
      className={cn(
        'flex items-center gap-2 rounded-full border border-white/10 px-3 py-1 text-xs font-semibold',
        getColor(score)
      )}
      onClick={onClick}
      title={title}
    >
      <span>{percent}%</span>
      <span className="text-[10px] font-normal uppercase tracking-[0.2em] text-white/60">
        Quality
      </span>
    </button>
  );
}
