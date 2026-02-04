import { Button } from '@/components/ui/button';

const OPTIONS = ['solo', 'couple', 'family', 'group'];

interface TravelerTypeSelectorProps {
  value: string[];
  onChange: (next: string[]) => void;
}

export function TravelerTypeSelector({ value, onChange }: TravelerTypeSelectorProps) {
  const toggle = (tag: string) => {
    if (value.includes(tag)) {
      onChange(value.filter((item) => item !== tag));
    } else {
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
