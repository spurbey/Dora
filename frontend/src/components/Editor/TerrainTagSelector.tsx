import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

const DEFAULT_TERRAIN_TAGS = ['scenic', 'mountainous', 'bumpy', 'smooth', 'winding'];

interface TerrainTagSelectorProps {
  value: string[];
  onChange: (tags: string[]) => void;
  maxTags?: number;
}

export function TerrainTagSelector({ value, onChange, maxTags = 10 }: TerrainTagSelectorProps) {
  const [customTag, setCustomTag] = useState('');

  const toggleTag = (tag: string) => {
    if (value.includes(tag)) {
      onChange(value.filter((item) => item !== tag));
      return;
    }
    if (value.length >= maxTags) return;
    onChange([...value, tag]);
  };

  const addCustomTag = () => {
    const normalized = customTag.trim().toLowerCase();
    if (!normalized) return;
    if (value.includes(normalized)) {
      setCustomTag('');
      return;
    }
    if (value.length >= maxTags) return;
    onChange([...value, normalized]);
    setCustomTag('');
  };

  return (
    <div className="space-y-2">
      <div className="flex flex-wrap gap-2">
        {DEFAULT_TERRAIN_TAGS.map((tag) => (
          <Button
            key={tag}
            type="button"
            size="sm"
            variant={value.includes(tag) ? 'default' : 'outline'}
            className="rounded-full"
            onClick={() => toggleTag(tag)}
          >
            {tag}
          </Button>
        ))}
      </div>

      <div className="flex gap-2">
        <Input
          value={customTag}
          placeholder="Add custom tag"
          onChange={(event) => setCustomTag(event.target.value)}
          onKeyDown={(event) => {
            if (event.key === 'Enter') {
              event.preventDefault();
              addCustomTag();
            }
          }}
        />
        <Button type="button" onClick={addCustomTag} disabled={!customTag.trim()}>
          Add
        </Button>
      </div>
    </div>
  );
}
