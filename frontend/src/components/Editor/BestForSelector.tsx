import { Button } from '@/components/ui/button';

const OPTIONS = [
  'solo-travelers',
  'couples',
  'families',
  'photographers',
  'foodies',
  'adventurers',
  'budget-travelers',
  'luxury-travelers',
];

interface BestForSelectorProps {
  value: string[];
  onChange: (next: string[]) => void;
}

export function BestForSelector({ value, onChange }: BestForSelectorProps) {
  const toggle = (tag: string) => {
    if (value.includes(tag)) {
      onChange(value.filter((item) => item !== tag));
    } else if (value.length < 5) {
      onChange([...value, tag]);
    }
  };

  return (
    <div className="flex flex-wrap gap-2">
      {OPTIONS.map((tag) => (
        <Button
          key={tag}
          type="button"
          variant={value.includes(tag) ? 'default' : 'outline'}
          size="sm"
          className="border-white/10 bg-white/5 text-xs text-white/70 hover:bg-emerald-500/10"
          onClick={() => toggle(tag)}
        >
          {tag}
        </Button>
      ))}
    </div>
  );
}
