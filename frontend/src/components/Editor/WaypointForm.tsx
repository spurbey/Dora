import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import type { WaypointCreate } from '@/types/waypoint';

interface WaypointFormProps {
  initialData?: Partial<WaypointCreate>;
  onSubmit: (data: WaypointCreate) => void;
  onCancel: () => void;
  isLoading?: boolean;
}

export function WaypointForm({
  initialData = {},
  onSubmit,
  onCancel,
  isLoading = false,
}: WaypointFormProps) {
  const [formData, setFormData] = useState<WaypointCreate>({
    lat: initialData.lat ?? 0,
    lng: initialData.lng ?? 0,
    name: initialData.name ?? '',
    waypoint_type: initialData.waypoint_type ?? 'stop',
    notes: initialData.notes ?? '',
    order_in_route: initialData.order_in_route ?? 0,
    stopped_at: initialData.stopped_at ?? undefined,
  });

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();
    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <Label htmlFor="waypoint-name">Waypoint Name</Label>
        <Input
          id="waypoint-name"
          value={formData.name}
          onChange={(event) => setFormData({ ...formData, name: event.target.value })}
          placeholder="e.g., Gas station, Viewpoint"
          required
        />
      </div>

      <div>
        <Label htmlFor="waypoint-type">Type</Label>
        <Select
          value={formData.waypoint_type}
          onValueChange={(value) =>
            setFormData({ ...formData, waypoint_type: value as WaypointCreate['waypoint_type'] })
          }
        >
          <SelectTrigger id="waypoint-type">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="stop">Stop</SelectItem>
            <SelectItem value="photo">Photo Spot</SelectItem>
            <SelectItem value="note">Note</SelectItem>
            <SelectItem value="poi">Point of Interest</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <div>
        <Label htmlFor="waypoint-notes">Notes (Optional)</Label>
        <Textarea
          id="waypoint-notes"
          value={formData.notes}
          onChange={(event) => setFormData({ ...formData, notes: event.target.value })}
          placeholder="Add any notes about this waypoint..."
          rows={3}
        />
      </div>

      <div className="flex gap-2">
        <Button type="submit" disabled={isLoading} className="flex-1">
          {isLoading ? 'Saving...' : 'Save Waypoint'}
        </Button>
        <Button type="button" variant="outline" onClick={onCancel}>
          Cancel
        </Button>
      </div>
    </form>
  );
}
