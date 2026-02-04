import { useMemo, useState } from 'react';
import { Dialog, DialogContent } from '@/components/ui/dialog';
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
import { TravelerTypeSelector } from '@/components/Editor/TravelerTypeSelector';
import { ActivityFocusSelector } from '@/components/Editor/ActivityFocusSelector';
import { PublicToggle } from '@/components/Editor/PublicToggle';
import { QualityScoreBadge } from '@/components/Editor/QualityScoreBadge';
import { useTripMetadata } from '@/hooks/useTripMetadata';
import { useQualityScore } from '@/hooks/useQualityScore';
import { useEditorStore } from '@/store/editorStore';
import { updateTrip } from '@/services/tripService';

interface TripProfileModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

const STYLE_OPTIONS = ['adventure', 'luxury', 'budget', 'cultural', 'relaxed'];

export function TripProfileModal({ open, onOpenChange }: TripProfileModalProps) {
  const { trip, setTrip, tripMetadata } = useEditorStore();
  const tripId = trip?.id ?? '';
  const { data: metadataData, saveMetadata, isSaving } = useTripMetadata(tripId);
  const { score, breakdown } = useQualityScore();

  const metadata = metadataData ?? tripMetadata;
  const metadataKey = metadata?.updated_at ?? metadata?.created_at ?? 'new';

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-3xl">
        <TripProfileContent
          key={metadataKey}
          trip={trip}
          setTrip={setTrip}
          metadata={metadata}
          score={score}
          breakdown={breakdown}
          isSaving={isSaving}
          saveMetadata={saveMetadata}
          onOpenChange={onOpenChange}
        />
      </DialogContent>
    </Dialog>
  );
}

interface TripProfileContentProps {
  trip: ReturnType<typeof useEditorStore>['trip'];
  setTrip: ReturnType<typeof useEditorStore>['setTrip'];
  metadata: ReturnType<typeof useTripMetadata>['data'] | null | undefined;
  score: number;
  breakdown: {
    tripMetadataScore: number;
    componentMetadataScore: number;
    mediaScore: number;
    timelineScore: number;
  };
  isSaving: boolean;
  saveMetadata: (payload: Parameters<ReturnType<typeof useTripMetadata>['saveMetadata']>[0]) => Promise<unknown>;
  onOpenChange: (open: boolean) => void;
}

function TripProfileContent({
  trip,
  setTrip,
  metadata,
  score,
  breakdown,
  isSaving,
  saveMetadata,
  onOpenChange,
}: TripProfileContentProps) {

  const [travelerType, setTravelerType] = useState<string[]>(metadata?.traveler_type ?? []);
  const [ageGroup, setAgeGroup] = useState(metadata?.age_group ?? 'millennial');
  const [travelStyle, setTravelStyle] = useState<string[]>(metadata?.travel_style ?? []);
  const [difficulty, setDifficulty] = useState(metadata?.difficulty_level ?? 'moderate');
  const [budget, setBudget] = useState(metadata?.budget_category ?? 'mid-range');
  const [activityFocus, setActivityFocus] = useState<string[]>(metadata?.activity_focus ?? []);
  const [tags, setTags] = useState<string[]>(metadata?.tags ?? []);
  const [customTag, setCustomTag] = useState('');
  const [isDiscoverable, setIsDiscoverable] = useState(metadata?.is_discoverable ?? false);

  const canPublish = score >= 0.5;
  const canSave = !(isDiscoverable && score < 0.3);
  const visibility = trip?.visibility ?? 'private';
  const nextVisibility = isDiscoverable ? 'public' : visibility === 'public' ? 'unlisted' : visibility;

  const toggleStyle = (style: string) => {
    if (travelStyle.includes(style)) {
      setTravelStyle(travelStyle.filter((item) => item !== style));
    } else if (travelStyle.length < 3) {
      setTravelStyle([...travelStyle, style]);
    }
  };

  const addTag = () => {
    const cleaned = customTag.trim().toLowerCase();
    if (!cleaned || tags.includes(cleaned) || tags.length >= 10) return;
    setTags([...tags, cleaned]);
    setCustomTag('');
  };

  const removeTag = (tag: string) => {
    setTags(tags.filter((item) => item !== tag));
  };

  const handleSave = async () => {
    if (!trip) return;

    if (isDiscoverable && !canPublish) {
      const proceed = window.confirm(
        'Quality score is below 50%. This trip may not be discoverable. Continue?'
      );
      if (!proceed) return;
    }

    await saveMetadata({
      traveler_type: travelerType,
      age_group: ageGroup,
      travel_style: travelStyle,
      difficulty_level: difficulty,
      budget_category: budget,
      activity_focus: activityFocus,
      is_discoverable: isDiscoverable,
      tags,
    });

    if (trip.visibility !== nextVisibility) {
      const updatedTrip = await updateTrip(trip.id, { visibility: nextVisibility });
      setTrip(updatedTrip);
    }

    onOpenChange(false);
  };

  const handleDiscoverableChange = (next: boolean) => {
    if (next && !canPublish) {
      const proceed = window.confirm(
        'Quality score is below 50%. This trip may not be discoverable. Continue?'
      );
      if (!proceed) return;
    }
    setIsDiscoverable(next);
  };

  const qualityLabel = useMemo(() => {
    if (score >= 0.8) return 'Excellent';
    if (score >= 0.6) return 'Good';
    if (score >= 0.3) return 'Fair';
    return 'Needs work';
  }, [score]);

  const scoreTooltip = `Trip metadata: ${Math.round(
    breakdown.tripMetadataScore * 100
  )}% | Components: ${Math.round(breakdown.componentMetadataScore * 100)}% | Media: ${Math.round(
    breakdown.mediaScore * 100
  )}% | Timeline: ${Math.round(breakdown.timelineScore * 100)}%`;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-xs uppercase tracking-[0.2em] text-emerald-300/70">Trip Profile</p>
          <h2 className="text-xl font-semibold text-white">Semantic tagging</h2>
        </div>
        <div className="flex items-center gap-2">
          <QualityScoreBadge score={score} title={scoreTooltip} />
          <span className="text-xs text-white/60">{qualityLabel}</span>
        </div>
      </div>

          <section className="space-y-3">
            <Label>Traveler Type</Label>
            <TravelerTypeSelector value={travelerType} onChange={setTravelerType} />
          </section>

          <section className="grid gap-4 md:grid-cols-2">
            <div>
              <Label>Age Group</Label>
              <Select value={ageGroup} onValueChange={(value) => setAgeGroup(value as typeof ageGroup)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {['gen-z', 'millennial', 'gen-x', 'boomer'].map((option) => (
                    <SelectItem key={option} value={option}>
                      {option}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label>Difficulty</Label>
              <Select value={difficulty} onValueChange={(value) => setDifficulty(value as typeof difficulty)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {['easy', 'moderate', 'challenging', 'extreme'].map((option) => (
                    <SelectItem key={option} value={option}>
                      {option}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </section>

          <section className="space-y-3">
            <Label>Travel Style (up to 3)</Label>
            <div className="flex flex-wrap gap-2">
              {STYLE_OPTIONS.map((style) => (
                <Button
                  key={style}
                  type="button"
                  variant={travelStyle.includes(style) ? 'default' : 'outline'}
                  size="sm"
                  className="border-white/10 bg-white/5 text-xs text-white/70 hover:bg-emerald-500/10"
                  onClick={() => toggleStyle(style)}
                >
                  {style}
                </Button>
              ))}
            </div>
          </section>

          <section className="grid gap-4 md:grid-cols-2">
            <div>
              <Label>Budget Category</Label>
              <Select value={budget} onValueChange={(value) => setBudget(value as typeof budget)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {['budget', 'mid-range', 'luxury'].map((option) => (
                    <SelectItem key={option} value={option}>
                      {option}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label>Activity Focus (up to 5)</Label>
              <ActivityFocusSelector value={activityFocus} onChange={setActivityFocus} />
            </div>
          </section>

          <section className="space-y-2">
            <Label>Custom Tags</Label>
            <div className="flex flex-wrap gap-2">
              {tags.map((tag) => (
                <Button
                  key={tag}
                  type="button"
                  variant="outline"
                  size="sm"
                  className="border-white/10 bg-white/5 text-xs text-white/70"
                  onClick={() => removeTag(tag)}
                >
                  {tag} ✕
                </Button>
              ))}
            </div>
            <div className="flex gap-2">
              <Input
                placeholder="Add tag"
                value={customTag}
                onChange={(event) => setCustomTag(event.target.value)}
                className="border-white/10 bg-white/5 text-white"
              />
              <Button type="button" onClick={addTag}>
                Add
              </Button>
            </div>
          </section>

          <PublicToggle
            checked={isDiscoverable}
            onChange={handleDiscoverableChange}
            label="Make this trip discoverable"
            description="Allows others to find this trip in discovery"
          />
          {!canSave && (
            <p className="text-xs text-rose-200">
              Add more details before making this trip discoverable.
            </p>
          )}

      <div className="flex items-center justify-end gap-2">
        <Button variant="outline" onClick={() => onOpenChange(false)}>
          Cancel
        </Button>
        <Button onClick={handleSave} disabled={isSaving || !canSave}>
          Save Profile
        </Button>
      </div>
    </div>
  );
}
