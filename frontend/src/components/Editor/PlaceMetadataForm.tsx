import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { ExperienceTagSelector } from '@/components/Editor/ExperienceTagSelector';
import { BestForSelector } from '@/components/Editor/BestForSelector';
import { DifficultyRating } from '@/components/Editor/DifficultyRating';
import { PublicToggle } from '@/components/Editor/PublicToggle';
import type { PlaceMetadata, PlaceMetadataCreate } from '@/types/placeMetadata';

interface PlaceMetadataFormProps {
  metadata: PlaceMetadata | null;
  isSaving: boolean;
  tripIsPublic: boolean;
  onSave: (payload: PlaceMetadataCreate) => Promise<void>;
  onCancel: () => void;
}

export function PlaceMetadataForm({
  metadata,
  isSaving,
  tripIsPublic,
  onSave,
  onCancel,
}: PlaceMetadataFormProps) {
  const [componentType, setComponentType] = useState<PlaceMetadata['component_type']>(
    metadata?.component_type ?? 'place'
  );
  const [experienceTags, setExperienceTags] = useState<string[]>(metadata?.experience_tags ?? []);
  const [bestFor, setBestFor] = useState<string[]>(metadata?.best_for ?? []);
  const [budget, setBudget] = useState(metadata?.budget_per_person?.toString() ?? '');
  const [duration, setDuration] = useState(metadata?.duration_hours?.toString() ?? '');
  const [difficulty, setDifficulty] = useState(metadata?.difficulty_rating ?? 0);
  const [physicalDemand, setPhysicalDemand] = useState<PlaceMetadata['physical_demand']>(
    metadata?.physical_demand ?? 'low'
  );
  const [bestTime, setBestTime] = useState<PlaceMetadata['best_time']>(
    metadata?.best_time ?? 'anytime'
  );
  const [isPublic, setIsPublic] = useState(metadata?.is_public ?? false);

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();

    const payload: PlaceMetadataCreate = {
      component_type: componentType,
      experience_tags: experienceTags.length ? experienceTags : undefined,
      best_for: bestFor.length ? bestFor : undefined,
      budget_per_person: budget ? Number(budget) : undefined,
      duration_hours: duration ? Number(duration) : undefined,
      difficulty_rating: difficulty || undefined,
      physical_demand: physicalDemand || undefined,
      best_time: bestTime || undefined,
      is_public: tripIsPublic ? isPublic : false,
    };

    await onSave(payload);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <section className="grid gap-3 md:grid-cols-2">
        <div>
          <Label>Component Type</Label>
          <Select value={componentType} onValueChange={(value) => setComponentType(value as PlaceMetadata['component_type'])}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {['city', 'place', 'activity', 'accommodation', 'food', 'transport'].map((option) => (
                <SelectItem key={option} value={option}>
                  {option}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        <div>
          <Label>Best Time</Label>
          <Select value={bestTime ?? 'anytime'} onValueChange={(value) => setBestTime(value as PlaceMetadata['best_time'])}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {['sunrise', 'morning', 'afternoon', 'sunset', 'night', 'anytime'].map((option) => (
                <SelectItem key={option} value={option}>
                  {option}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </section>

      <section className="space-y-3">
        <Label>Experience Tags</Label>
        <ExperienceTagSelector value={experienceTags} onChange={setExperienceTags} />
      </section>

      <section className="space-y-3">
        <Label>Best For</Label>
        <BestForSelector value={bestFor} onChange={setBestFor} />
      </section>

      <section className="grid gap-3 md:grid-cols-2">
        <div>
          <Label>Budget per Person (USD)</Label>
          <Input value={budget} onChange={(event) => setBudget(event.target.value)} type="number" />
        </div>
        <div>
          <Label>Duration (hours)</Label>
          <Input value={duration} onChange={(event) => setDuration(event.target.value)} type="number" step="0.5" />
        </div>
      </section>

      <section className="space-y-3">
        <Label>Difficulty</Label>
        <DifficultyRating value={difficulty} onChange={setDifficulty} />
        <div>
          <Label>Physical Demand</Label>
          <Select value={physicalDemand ?? 'low'} onValueChange={(value) => setPhysicalDemand(value as PlaceMetadata['physical_demand'])}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {['low', 'medium', 'high'].map((option) => (
                <SelectItem key={option} value={option}>
                  {option}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </section>

      <section className="space-y-3">
        <PublicToggle
          checked={tripIsPublic ? isPublic : false}
          disabled={!tripIsPublic}
          label="Allow others to discover this place"
          description={tripIsPublic ? 'Visible in discovery when trip is public' : 'Trip must be public to enable'}
          onChange={setIsPublic}
        />
        {metadata?.contribution_score !== undefined && (
          <p className="text-xs text-white/60">
            Contribution score: {(metadata.contribution_score * 100).toFixed(0)}%
          </p>
        )}
      </section>

      <div className="flex items-center gap-2">
        <Button type="submit" disabled={isSaving}>
          Save Metadata
        </Button>
        <Button type="button" variant="outline" onClick={onCancel}>
          Cancel
        </Button>
      </div>
    </form>
  );
}
