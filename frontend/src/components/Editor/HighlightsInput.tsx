import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

const DEFAULT_HIGHLIGHTS = ['waterfall', 'viewpoint', 'temple', 'cafe'];

interface HighlightsInputProps {
  value: string[];
  onChange: (highlights: string[]) => void;
}

export function HighlightsInput({ value, onChange }: HighlightsInputProps) {
  const [input, setInput] = useState('');

  const addHighlight = (highlight: string) => {
    const normalized = highlight.trim().toLowerCase();
    if (!normalized) return;
    if (normalized.length > 50) return;
    if (value.includes(normalized)) {
      setInput('');
      return;
    }
    onChange([...value, normalized]);
    setInput('');
  };

  const removeHighlight = (highlight: string) => {
    onChange(value.filter((item) => item !== highlight));
  };

  return (
    <div className="space-y-2">
      <div className="flex gap-2">
        <Input
          value={input}
          placeholder="Add highlight"
          onChange={(event) => setInput(event.target.value)}
          onKeyDown={(event) => {
            if (event.key === 'Enter') {
              event.preventDefault();
              addHighlight(input);
            }
          }}
        />
        <Button type="button" onClick={() => addHighlight(input)} disabled={!input.trim()}>
          Add
        </Button>
      </div>

      <div className="flex flex-wrap gap-2">
        {value.map((tag) => (
          <Button
            key={tag}
            type="button"
            size="sm"
            variant="secondary"
            className="rounded-full"
            onClick={() => removeHighlight(tag)}
          >
            {tag}
          </Button>
        ))}
      </div>

      <div className="flex flex-wrap gap-2 text-xs text-white/50">
        {DEFAULT_HIGHLIGHTS.map((suggestion) => (
          <button
            key={suggestion}
            type="button"
            className="rounded-full border border-white/10 px-2 py-1 hover:border-emerald-400/50"
            onClick={() => addHighlight(suggestion)}
          >
            {suggestion}
          </button>
        ))}
      </div>
    </div>
  );
}
