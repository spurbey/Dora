import { useMemo, useState } from 'react';
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
import { TerrainTagSelector } from '@/components/Editor/TerrainTagSelector';
import { SafetyRatingInput } from '@/components/Editor/SafetyRatingInput';
import { HighlightsInput } from '@/components/Editor/HighlightsInput';
import { useCreateRouteMetadata, useUpdateRouteMetadata } from '@/hooks/useRouteMetadata';
import { routeService } from '@/services/routeService';
import { useEditorStore } from '@/store/editorStore';
import type { Route } from '@/types/route';
import type { RouteMetadata, RouteMetadataCreate } from '@/types/routeMetadata';

const QUALITY_OPTIONS: Array<RouteMetadata['route_quality']> = ['scenic', 'fastest', 'offbeat'];
const ROAD_OPTIONS: Array<RouteMetadata['road_condition']> = [
  'excellent',
  'good',
  'poor',
  'offroad',
];

interface RouteMetadataFormProps {
  route: Route;
  metadata: RouteMetadata | null;
  onSaved: (metadata: RouteMetadata) => void;
  onCancel: () => void;
}

export function RouteMetadataForm({ route, metadata, onSaved, onCancel }: RouteMetadataFormProps) {
  const [transportMode, setTransportMode] = useState(route.transport_mode);
  const [routeQuality, setRouteQuality] = useState<RouteMetadata['route_quality']>(
    metadata?.route_quality
  );
  const [roadCondition, setRoadCondition] = useState<RouteMetadata['road_condition']>(
    metadata?.road_condition
  );
  const [scenicRating, setScenicRating] = useState<number | undefined>(metadata?.scenic_rating);
  const [safetyRating, setSafetyRating] = useState<number>(metadata?.safety_rating ?? 3);
  const [soloSafe, setSoloSafe] = useState(metadata?.solo_safe ?? false);
  const [fuelCost, setFuelCost] = useState(metadata?.fuel_cost?.toString() ?? '');
  const [tollCost, setTollCost] = useState(metadata?.toll_cost?.toString() ?? '');
  const [terrainTags, setTerrainTags] = useState<string[]>([]);
  const [highlights, setHighlights] = useState<string[]>(metadata?.highlights ?? []);
  const [isPublic, setIsPublic] = useState(metadata?.is_public ?? false);

  const updateMetadata = useUpdateRouteMetadata(route.id);
  const createMetadata = useCreateRouteMetadata(route.id);
  const { updateItem } = useEditorStore();

  const combinedHighlights = useMemo(() => {
    const merged = [...terrainTags, ...highlights];
    return Array.from(new Set(merged.map((tag) => tag.trim().toLowerCase()).filter(Boolean)));
  }, [terrainTags, highlights]);

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();

    if (!safetyRating || safetyRating < 1 || safetyRating > 5) return;

    if (transportMode !== route.transport_mode) {
      const updatedRoute = await routeService.updateRoute(route.id, {
        transport_mode: transportMode,
      });
      updateItem('route', route.id, updatedRoute);
    }

    const payload: RouteMetadataCreate = {
      route_quality: routeQuality,
      road_condition: roadCondition,
      scenic_rating: scenicRating && scenicRating > 0 ? scenicRating : undefined,
      safety_rating: safetyRating,
      solo_safe: soloSafe,
      fuel_cost: fuelCost ? Number(fuelCost) : undefined,
      toll_cost: tollCost ? Number(tollCost) : undefined,
      highlights: combinedHighlights.length ? combinedHighlights : undefined,
      is_public: isPublic,
    };

    const result = metadata
      ? await updateMetadata.mutateAsync(payload)
      : await createMetadata.mutateAsync(payload);

    onSaved(result);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <section className="space-y-3">
        <div>
          <Label>Transport Mode</Label>
          <Select value={transportMode} onValueChange={(value) => setTransportMode(value as Route['transport_mode'])}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {['car', 'bike', 'foot', 'air', 'bus', 'train'].map((mode) => (
                <SelectItem key={mode} value={mode}>
                  {mode}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="grid gap-3 md:grid-cols-2">
          <div>
            <Label>Route Quality</Label>
            <Select
              value={routeQuality ?? 'none'}
              onValueChange={(value) =>
                setRouteQuality(value === 'none' ? undefined : (value as RouteMetadata['route_quality']))
              }
            >
              <SelectTrigger>
                <SelectValue placeholder="Select quality" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="none">Unspecified</SelectItem>
                {QUALITY_OPTIONS.map((option) => (
                  <SelectItem key={option} value={option ?? ''}>
                    {option}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div>
            <Label>Road Condition</Label>
            <Select
              value={roadCondition ?? 'none'}
              onValueChange={(value) =>
                setRoadCondition(value === 'none' ? undefined : (value as RouteMetadata['road_condition']))
              }
            >
              <SelectTrigger>
                <SelectValue placeholder="Select condition" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="none">Unspecified</SelectItem>
                {ROAD_OPTIONS.map((option) => (
                  <SelectItem key={option} value={option ?? ''}>
                    {option}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>
      </section>

      <section className="space-y-3">
        <div className="grid gap-4 md:grid-cols-2">
          <div>
            <Label>Scenic Rating (optional)</Label>
            <SafetyRatingInput
              value={scenicRating ?? 0}
              onChange={setScenicRating}
              label=""
            />
          </div>
          <div>
            <Label>Safety Rating (required)</Label>
            <SafetyRatingInput value={safetyRating} onChange={setSafetyRating} />
          </div>
        </div>

        <label className="flex items-center gap-2 text-sm text-white/70">
          <input
            type="checkbox"
            checked={soloSafe}
            onChange={(event) => setSoloSafe(event.target.checked)}
          />
          Solo-friendly route
        </label>
      </section>

      <section className="grid gap-3 md:grid-cols-2">
        <div>
          <Label>Fuel Cost (USD)</Label>
          <Input value={fuelCost} onChange={(event) => setFuelCost(event.target.value)} type="number" />
        </div>
        <div>
          <Label>Toll Cost (USD)</Label>
          <Input value={tollCost} onChange={(event) => setTollCost(event.target.value)} type="number" />
        </div>
      </section>

      <section className="space-y-3">
        <Label>Terrain Tags</Label>
        <TerrainTagSelector value={terrainTags} onChange={setTerrainTags} />
      </section>

      <section className="space-y-3">
        <Label>Highlights</Label>
        <HighlightsInput value={highlights} onChange={setHighlights} />
      </section>

      <section className="space-y-2">
        <Label>Visibility</Label>
        <label className="flex items-center gap-2 text-sm text-white/70">
          <input
            type="checkbox"
            checked={isPublic}
            onChange={(event) => setIsPublic(event.target.checked)}
          />
          Allow others to discover this route
        </label>
      </section>

      <div className="flex items-center gap-2">
        <Button type="submit" disabled={createMetadata.isPending || updateMetadata.isPending}>
          Save Metadata
        </Button>
        <Button type="button" variant="outline" onClick={onCancel}>
          Cancel
        </Button>
      </div>
    </form>
  );
}
