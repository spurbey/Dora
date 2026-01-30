import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
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
import type { Place, PlaceCreate, PlaceUpdate } from '@/types/place';
import type { SearchResult } from '@/types/search';

interface PlaceFormProps {
  tripId: string;
  place?: Place;
  initialData?: SearchResult;
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: PlaceCreate | PlaceUpdate) => void;
  isLoading?: boolean;
}

type FormData = {
  name: string;
  lat: string;
  lng: string;
  place_type: string;
  user_notes: string;
};

const PLACE_TYPES = [
  { value: 'restaurant', label: 'Restaurant' },
  { value: 'hotel', label: 'Hotel' },
  { value: 'attraction', label: 'Attraction' },
  { value: 'cafe', label: 'Café' },
  { value: 'bar', label: 'Bar' },
  { value: 'museum', label: 'Museum' },
  { value: 'park', label: 'Park' },
  { value: 'shop', label: 'Shop' },
  { value: 'other', label: 'Other' },
];

export function PlaceForm({
  tripId,
  place,
  initialData,
  isOpen,
  onClose,
  onSubmit,
  isLoading,
}: PlaceFormProps) {
  const isEditing = !!place;
  const form = useForm<FormData>({
    defaultValues: {
      name: '',
      lat: '',
      lng: '',
      place_type: '',
      user_notes: '',
    },
  });

  const {
    register,
    handleSubmit,
    reset,
    setValue,
    formState: { errors },
  } = form;

  const placeType = form.watch('place_type');

  // Initialize form with place data or search result
  useEffect(() => {
    if (place) {
      reset({
        name: place.name,
        lat: place.lat.toString(),
        lng: place.lng.toString(),
        place_type: place.place_type || '',
        user_notes: place.user_notes || '',
      });
    } else if (initialData) {
      reset({
        name: initialData.name,
        lat: initialData.lat.toString(),
        lng: initialData.lng.toString(),
        place_type: '',
        user_notes: '',
      });
    } else {
      reset({
        name: '',
        lat: '',
        lng: '',
        place_type: '',
        user_notes: '',
      });
    }
  }, [place, initialData, reset]);

  const handleFormSubmit = (data: FormData) => {
    const lat = parseFloat(data.lat);
    const lng = parseFloat(data.lng);

    if (isNaN(lat) || isNaN(lng)) {
      return;
    }

    if (isEditing) {
      const updateData: PlaceUpdate = {
        name: data.name,
        lat,
        lng,
        place_type: data.place_type || undefined,
        user_notes: data.user_notes || undefined,
      };
      onSubmit(updateData);
    } else {
      const createData: PlaceCreate = {
        trip_id: tripId,
        name: data.name,
        lat,
        lng,
        place_type: data.place_type || undefined,
        user_notes: data.user_notes || undefined,
        external_place_id: initialData?.id || undefined,
      };
      onSubmit(createData);
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="bg-slate-900 border-white/10 text-white sm:max-w-lg">
        <DialogHeader>
          <DialogTitle className="text-xl">
            {isEditing ? 'Edit Place' : initialData ? `Adding: ${initialData.name}` : 'Add Place'}
          </DialogTitle>
        </DialogHeader>

        <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4">
          {/* Name */}
          <div>
            <Label htmlFor="name" className="text-white/80">
              Name <span className="text-red-400">*</span>
            </Label>
            <Input
              id="name"
              {...register('name', { required: 'Name is required' })}
              className="mt-1.5 bg-white/5 border-white/10 text-white"
              placeholder="Place name"
            />
            {errors.name && (
              <p className="mt-1 text-xs text-red-400">{errors.name.message}</p>
            )}
          </div>

          {/* Coordinates */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="lat" className="text-white/80">
                Latitude <span className="text-red-400">*</span>
              </Label>
              <Input
                id="lat"
                type="number"
                step="any"
                {...register('lat', {
                  required: 'Latitude is required',
                  validate: (value) => {
                    const num = parseFloat(value);
                    return (
                      (num >= -90 && num <= 90) || 'Latitude must be between -90 and 90'
                    );
                  },
                })}
                className="mt-1.5 bg-white/5 border-white/10 text-white"
                placeholder="48.8584"
              />
              {errors.lat && (
                <p className="mt-1 text-xs text-red-400">{errors.lat.message}</p>
              )}
            </div>

            <div>
              <Label htmlFor="lng" className="text-white/80">
                Longitude <span className="text-red-400">*</span>
              </Label>
              <Input
                id="lng"
                type="number"
                step="any"
                {...register('lng', {
                  required: 'Longitude is required',
                  validate: (value) => {
                    const num = parseFloat(value);
                    return (
                      (num >= -180 && num <= 180) || 'Longitude must be between -180 and 180'
                    );
                  },
                })}
                className="mt-1.5 bg-white/5 border-white/10 text-white"
                placeholder="2.2945"
              />
              {errors.lng && (
                <p className="mt-1 text-xs text-red-400">{errors.lng.message}</p>
              )}
            </div>
          </div>

          {/* Place Type */}
          <div>
            <Label htmlFor="place_type" className="text-white/80">
              Place Type
            </Label>
            <Select value={placeType} onValueChange={(value) => setValue('place_type', value)}>
              <SelectTrigger className="mt-1.5 bg-white/5 border-white/10 text-white">
                <SelectValue placeholder="Select type" />
              </SelectTrigger>
              <SelectContent className="bg-slate-900 border-white/10">
                {PLACE_TYPES.map((type) => (
                  <SelectItem key={type.value} value={type.value} className="text-white">
                    {type.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Notes */}
          <div>
            <Label htmlFor="user_notes" className="text-white/80">
              Notes
            </Label>
            <Textarea
              id="user_notes"
              {...register('user_notes')}
              className="mt-1.5 bg-white/5 border-white/10 text-white resize-none"
              placeholder="Add your notes about this place..."
              rows={3}
            />
          </div>

          {/* Actions */}
          <div className="flex justify-end gap-3 pt-4">
            <Button
              type="button"
              variant="ghost"
              onClick={onClose}
              className="text-white/60 hover:text-white hover:bg-white/5"
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={isLoading}
              className="bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500"
            >
              {isLoading ? 'Saving...' : isEditing ? 'Update Place' : 'Add Place'}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
