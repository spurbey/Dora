import { useState } from 'react';
import { Plus, Search } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { LoadingSpinner } from '@/components/Shared/LoadingSpinner';
import { EmptyState } from '@/components/Shared/EmptyState';
import { ConfirmDialog } from '@/components/Shared/ConfirmDialog';
import { PlaceSearch } from '@/components/Place/PlaceSearch';
import { PlaceForm } from '@/components/Place/PlaceForm';
import { PlaceListItem } from '@/components/Place/PlaceListItem';
import { usePlaces, useCreatePlace, useUpdatePlace, useDeletePlace } from '@/hooks/usePlaces';
import type { Place, PlaceCreate, PlaceUpdate } from '@/types/place';
import type { SearchResult } from '@/types/search';

interface TripTimelineProps {
  tripId: string;
  centerLocation?: { lat: number; lng: number };
}

export function TripTimeline({ tripId, centerLocation }: TripTimelineProps) {
  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [selectedPlace, setSelectedPlace] = useState<Place | null>(null);
  const [selectedSearchResult, setSelectedSearchResult] = useState<SearchResult | null>(null);
  const [placeToDelete, setPlaceToDelete] = useState<string | null>(null);

  const { data: places = [], isLoading, error } = usePlaces(tripId);
  const createPlace = useCreatePlace();
  const updatePlace = useUpdatePlace();
  const deletePlace = useDeletePlace();

  // Sort places by order_in_trip or created_at
  const sortedPlaces = [...places].sort((a, b) => {
    if (a.order_in_trip !== null && b.order_in_trip !== null) {
      return a.order_in_trip - b.order_in_trip;
    }
    if (a.order_in_trip !== null) return -1;
    if (b.order_in_trip !== null) return 1;
    return new Date(a.created_at).getTime() - new Date(b.created_at).getTime();
  });

  const handleSearchSelect = (result: SearchResult) => {
    setSelectedSearchResult(result);
    setIsSearchOpen(false);
    setIsFormOpen(true);
  };

  const handleAddPlace = () => {
    setSelectedPlace(null);
    setSelectedSearchResult(null);
    setIsSearchOpen(true);
  };

  const handleEditPlace = (place: Place) => {
    setSelectedPlace(place);
    setSelectedSearchResult(null);
    setIsFormOpen(true);
  };

  const handleFormSubmit = async (data: PlaceCreate | PlaceUpdate) => {
    try {
      if (selectedPlace) {
        await updatePlace.mutateAsync({ id: selectedPlace.id, data: data as PlaceUpdate });
      } else {
        await createPlace.mutateAsync(data as PlaceCreate);
      }
      setIsFormOpen(false);
      setSelectedPlace(null);
      setSelectedSearchResult(null);
    } catch (error) {
      console.error('Failed to save place:', error);
    }
  };

  const handleDeleteConfirm = async () => {
    if (!placeToDelete) return;
    try {
      await deletePlace.mutateAsync({ id: placeToDelete, tripId });
      setPlaceToDelete(null);
    } catch (error) {
      console.error('Failed to delete place:', error);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="rounded-lg border border-red-500/20 bg-red-500/10 p-4 text-center text-red-400">
        Failed to load places. Please try again.
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-white">Timeline</h2>
          <p className="text-sm text-white/60">
            {sortedPlaces.length} {sortedPlaces.length === 1 ? 'place' : 'places'}
          </p>
        </div>
        <Button
          onClick={handleAddPlace}
          className="bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500"
        >
          <Plus className="mr-2 h-4 w-4" />
          Add Place
        </Button>
      </div>

      {/* Search Modal */}
      {isSearchOpen && (
        <Card className="border-white/10 bg-white/5 p-4">
          <div className="mb-3 flex items-center gap-2">
            <Search className="h-5 w-5 text-emerald-400" />
            <h3 className="font-semibold text-white">Search for a place</h3>
          </div>
          <PlaceSearch
            tripId={tripId}
            initialLocation={centerLocation}
            onSelectPlace={handleSearchSelect}
          />
          <Button
            variant="ghost"
            onClick={() => setIsSearchOpen(false)}
            className="mt-3 w-full text-white/60 hover:text-white hover:bg-white/5"
          >
            Cancel
          </Button>
        </Card>
      )}

      {/* Timeline List */}
      {sortedPlaces.length === 0 ? (
        <EmptyState
          title="No places added yet"
          description="Search and add places to build your trip timeline"
          actionLabel="Add First Place"
          onAction={handleAddPlace}
        />
      ) : (
        <div className="space-y-0">
          {sortedPlaces.map((place, index) => (
            <PlaceListItem
              key={place.id}
              place={place}
              index={index}
              onEdit={() => handleEditPlace(place)}
              onDelete={() => setPlaceToDelete(place.id)}
            />
          ))}
        </div>
      )}

      {/* Place Form Modal */}
      <PlaceForm
        tripId={tripId}
        place={selectedPlace || undefined}
        initialData={selectedSearchResult || undefined}
        isOpen={isFormOpen}
        onClose={() => {
          setIsFormOpen(false);
          setSelectedPlace(null);
          setSelectedSearchResult(null);
        }}
        onSubmit={handleFormSubmit}
        isLoading={createPlace.isPending || updatePlace.isPending}
      />

      {/* Delete Confirmation */}
      <ConfirmDialog
        open={!!placeToDelete}
        onOpenChange={(open) => !open && setPlaceToDelete(null)}
        onConfirm={handleDeleteConfirm}
        title="Delete Place"
        description="Are you sure you want to delete this place? This action cannot be undone."
        confirmLabel="Delete"
        variant="destructive"
      />
    </div>
  );
}
