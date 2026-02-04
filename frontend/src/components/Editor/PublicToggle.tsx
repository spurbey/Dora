import { cn } from '@/lib/utils';

interface PublicToggleProps {
  checked: boolean;
  disabled?: boolean;
  label: string;
  description?: string;
  onChange: (next: boolean) => void;
}

export function PublicToggle({ checked, disabled, label, description, onChange }: PublicToggleProps) {
  return (
    <button
      type="button"
      className={cn(
        'flex w-full items-center justify-between rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-left text-sm text-white/80 transition',
        disabled && 'cursor-not-allowed opacity-60'
      )}
      onClick={() => {
        if (disabled) return;
        onChange(!checked);
      }}
    >
      <div>
        <p className="font-semibold">{label}</p>
        {description && <p className="text-xs text-white/50">{description}</p>}
      </div>
      <span
        className={cn(
          'h-6 w-10 rounded-full border border-white/10 p-1',
          checked ? 'bg-emerald-500/40' : 'bg-white/10'
        )}
      >
        <span
          className={cn(
            'block h-4 w-4 rounded-full bg-white/80 transition',
            checked ? 'translate-x-4' : 'translate-x-0'
          )}
        />
      </span>
    </button>
  );
}
