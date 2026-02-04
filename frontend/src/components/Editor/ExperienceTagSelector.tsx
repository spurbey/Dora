import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

const DEFAULT_TAGS = [
  'romantic',
  'adventurous',
  'peaceful',
  'crowded',
  'instagram-worthy',
  'hidden-gem',
  'touristy',
  'authentic',
  'spiritual',
  'scenic',
];

interface ExperienceTagSelectorProps {
  value: string[];
  onChange: (next: string[]) => void;
}

export function ExperienceTagSelector({ value, onChange }: ExperienceTagSelectorProps) {
  const [customTag, setCustomTag] = useState('');

  const toggleTag = (tag: string) => {
    if (value.includes(tag)) {
      onChange(value.filter((item) => item !== tag));
    } else {
      onChange([...value, tag]);
    }
  };

  const addCustom = () => {
    const cleaned = customTag.trim().toLowerCase();
    if (!cleaned || value.includes(cleaned)) return;
    onChange([...value, cleaned]);
    setCustomTag('');
  };

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-2">
        {DEFAULT_TAGS.map((tag) => (
          <Button
            key={tag}
            type="button"
            variant={value.includes(tag) ? 'default' : 'outline'}
            size="sm"
            className="border-white/10 bg-white/5 text-xs text-white/70 hover:bg-emerald-500/10"
            onClick={() => toggleTag(tag)}
          >
            {tag}
          </Button>
        ))}
      </div>
      <div className="flex gap-2">
        <Input
          placeholder="Add custom tag"
          value={customTag}
          onChange={(event) => setCustomTag(event.target.value)}
          className="border-white/10 bg-white/5 text-white"
        />
        <Button type="button" onClick={addCustom}>
          Add
        </Button>
      </div>
    </div>
  );
}
