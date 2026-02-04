import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

const OPTIONS = [
  'hiking',
  'food',
  'photography',
  'nightlife',
  'beaches',
  'culture',
  'history',
  'wildlife',
  'shopping',
  'adventure-sports',
  'relaxation',
  'spirituality',
];

interface ActivityFocusSelectorProps {
  value: string[];
  onChange: (next: string[]) => void;
}

export function ActivityFocusSelector({ value, onChange }: ActivityFocusSelectorProps) {
  const [custom, setCustom] = useState('');

  const toggle = (tag: string) => {
    if (value.includes(tag)) {
      onChange(value.filter((item) => item !== tag));
    } else if (value.length < 5) {
      onChange([...value, tag]);
    }
  };

  const addCustom = () => {
    const cleaned = custom.trim().toLowerCase();
    if (!cleaned || value.includes(cleaned)) return;
    if (value.length >= 5) return;
    onChange([...value, cleaned]);
    setCustom('');
  };

  return (
    <div className="space-y-3">
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
      <div className="flex gap-2">
        <Input
          placeholder="Add activity"
          value={custom}
          onChange={(event) => setCustom(event.target.value)}
          className="border-white/10 bg-white/5 text-white"
        />
        <Button type="button" onClick={addCustom}>
          Add
        </Button>
      </div>
    </div>
  );
}
