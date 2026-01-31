import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { MapPin, Clock, Image } from 'lucide-react';
import { Navbar } from '@/components/Layout/Navbar';
import { Sidebar } from '@/components/Layout/Sidebar';
import { PageContainer } from '@/components/Layout/PageContainer';
import { TripHeader } from '@/components/Trip/TripHeader';
import { TripForm } from '@/components/Trip/TripForm';
import { TripTimeline } from '@/components/Trip/TripTimeline';
import { PlaceForm } from '@/components/Place/PlaceForm';
import { PlaceDetailSidebar } from '@/components/Place/PlaceDetailSidebar';
import { MapView } from '@/components/Map/MapView';
import { PhotoGallery } from '@/components/Media/PhotoGallery';
import { Lightbox } from '@/components/Media/Lightbox';
import { EmptyState } from '@/components/Shared/EmptyState';
import { LoadingPage } from '@/components/Shared/LoadingSpinner';
import { ConfirmDialog } from '@/components/Shared/ConfirmDialog';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { useTrip, useUpdateTrip, useDeleteTrip } from '@/hooks/useTrips';
import { usePlaces, useUpdatePlace, useDeletePlace } from '@/hooks/usePlaces';
import { useMapStore } from '@/store/mapStore';
import type { TripUpdate } from '@/types/trip';
import type { Place, PlaceUpdate } from '@/types/place';
import type { MediaFile } from '@/types/media';

export function TripDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data: trip, isLoading, error } = useTrip(id ?? '');
  const { data: places = [] } = usePlaces(id ?? '');
  const updateTrip = useUpdateTrip();
  const deleteTrip = useDeleteTrip();

  const updatePlace = useUpdatePlace();
  const deletePlace = useDeletePlace();
  const { setSelectedPlace } = useMapStore();

  const [formOpen, setFormOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [placeFormOpen, setPlaceFormOpen] = useState(false);
  const [placeDeleteDialogOpen, setPlaceDeleteDialogOpen] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [selectedPlace, setSelectedPlaceState] = useState<Place | null>(null);
  const [lightboxOpen, setLightboxOpen] = useState(false);
  const [lightboxIndex, setLightboxIndex] = useState(0);
  const [activeTab, setActiveTab] = useState('timeline');

  // Calculate center location from first place, or default to Paris
  const centerLocation =
    places.length > 0
      ? { lat: places[0].lat, lng: places[0].lng }
      : { lat: 48.8566, lng: 2.3522 };

  // Collect all media files from all places
  // Backend now returns full MediaFile objects
  const allMediaFiles: MediaFile[] = places.flatMap((place) => place.photos || []);

  const handleEditSubmit = async (data: TripUpdate) => {
    if (!id) return;
    try {
      await updateTrip.mutateAsync({ id, data });
      setFormOpen(false);
    } catch (err) {
      console.error('Failed to update trip:', err);
    }
  };

  const handleDeleteConfirm = async () => {
    if (!id) return;
    try {
      await deleteTrip.mutateAsync(id);
      navigate('/dashboard');
    } catch (err) {
      console.error('Failed to delete trip:', err);
    }
  };

  const handlePlaceClick = (place: Place) => {
    setSelectedPlaceState(place);
    setSelectedPlace(place.id);
    setSidebarOpen(true);
  };

  const handleCloseSidebar = () => {
    setSidebarOpen(false);
    setSelectedPlace(null);
    setTimeout(() => setSelectedPlaceState(null), 300);
  };

  const handleEditPlace = () => {
    setSidebarOpen(false);
    setPlaceFormOpen(true);
  };

  const handleDeletePlace = () => {
    setSidebarOpen(false);
    setPlaceDeleteDialogOpen(true);
  };

  const handlePlaceFormSubmit = async (data: PlaceUpdate) => {
    if (!selectedPlace) return;
    try {
      await updatePlace.mutateAsync({ id: selectedPlace.id, data });
      setPlaceFormOpen(false);
      setSelectedPlaceState(null);
    } catch (err) {
      console.error('Failed to update place:', err);
    }
  };

  const handlePlaceDeleteConfirm = async () => {
    if (!selectedPlace || !id) return;
    try {
      await deletePlace.mutateAsync({ id: selectedPlace.id, tripId: id });
      setPlaceDeleteDialogOpen(false);
      setSelectedPlaceState(null);
    } catch (err) {
      console.error('Failed to delete place:', err);
    }
  };

  const handlePhotoClick = (_photo: MediaFile, index: number) => {
    setLightboxIndex(index);
    setLightboxOpen(true);
  };

  const handleLightboxNext = () => {
    if (lightboxIndex < allMediaFiles.length - 1) {
      setLightboxIndex(lightboxIndex + 1);
    }
  };

  const handleLightboxPrevious = () => {
    if (lightboxIndex > 0) {
      setLightboxIndex(lightboxIndex - 1);
    }
  };

  if (isLoading) {
    return (
      <>
        <Navbar />
        <Sidebar />
        <PageContainer>
          <LoadingPage />
        </PageContainer>
      </>
    );
  }

  if (error || !trip) {
    return (
      <>
        <Navbar />
        <Sidebar />
        <PageContainer>
          <div className="flex min-h-[400px] flex-col items-center justify-center text-center">
            <h2 className="mb-2 text-xl font-semibold text-white">Trip not found</h2>
            <p className="mb-4 text-white/60">
              The trip you're looking for doesn't exist or you don't have access to it.
            </p>
            <button
              onClick={() => navigate('/dashboard')}
              className="text-emerald-400 hover:text-emerald-300"
            >
              Back to Dashboard
            </button>
          </div>
        </PageContainer>
      </>
    );
  }

  return (
    <>
      <Navbar />
      <Sidebar />
      <PageContainer>
        <TripHeader
          trip={trip}
          onEdit={() => setFormOpen(true)}
          onDelete={() => setDeleteDialogOpen(true)}
        />

        {/* Tabs */}
        <Tabs value={activeTab} onValueChange={setActiveTab} className="mt-6">
          <TabsList className="border-b border-white/10 bg-transparent">
            <TabsTrigger
              value="timeline"
              className="data-[state=active]:border-b-2 data-[state=active]:border-emerald-400 data-[state=active]:text-emerald-400"
            >
              <Clock className="mr-2 h-4 w-4" />
              Timeline
            </TabsTrigger>
            <TabsTrigger
              value="map"
              className="data-[state=active]:border-b-2 data-[state=active]:border-emerald-400 data-[state=active]:text-emerald-400"
            >
              <MapPin className="mr-2 h-4 w-4" />
              Map
            </TabsTrigger>
            <TabsTrigger
              value="photos"
              className="data-[state=active]:border-b-2 data-[state=active]:border-emerald-400 data-[state=active]:text-emerald-400"
            >
              <Image className="mr-2 h-4 w-4" />
              Photos
            </TabsTrigger>
          </TabsList>

          <TabsContent value="timeline" className="mt-6">
            <TripTimeline tripId={id ?? ''} centerLocation={centerLocation} />
          </TabsContent>

          <TabsContent value="map" className="mt-6">
            {places.length === 0 ? (
              <EmptyState
                icon={MapPin}
                title="No places to show"
                description="Add places to your trip to see them on the map."
              />
            ) : (
              <div className="h-[600px] rounded-lg overflow-hidden">
                <MapView
                  places={places}
                  onPlaceClick={handlePlaceClick}
                  isVisible={activeTab === 'map'}
                />
              </div>
            )}
          </TabsContent>

          <TabsContent value="photos" className="mt-6">
            {allMediaFiles.length === 0 ? (
              <EmptyState
                icon={Image}
                title="No photos yet"
                description="Upload photos to your places to see them here."
              />
            ) : (
              <PhotoGallery
                photos={allMediaFiles}
                onPhotoClick={handlePhotoClick}
              />
            )}
          </TabsContent>
        </Tabs>

        {/* Edit Trip Modal */}
        <TripForm
          trip={trip}
          open={formOpen}
          onOpenChange={setFormOpen}
          onSubmit={handleEditSubmit}
          isLoading={updateTrip.isPending}
        />

        {/* Delete Trip Confirmation Dialog */}
        <ConfirmDialog
          open={deleteDialogOpen}
          onOpenChange={setDeleteDialogOpen}
          title="Delete Trip"
          description="Are you sure you want to delete this trip? This action cannot be undone and all associated places will be removed."
          confirmLabel="Delete"
          onConfirm={handleDeleteConfirm}
          variant="destructive"
          isLoading={deleteTrip.isPending}
        />

        {/* Place Detail Sidebar */}
        {selectedPlace && (
          <PlaceDetailSidebar
            placeId={selectedPlace.id}
            isOpen={sidebarOpen}
            onClose={handleCloseSidebar}
            onEdit={handleEditPlace}
            onDelete={handleDeletePlace}
          />
        )}

        {/* Edit Place Modal */}
        {selectedPlace && (
          <PlaceForm
            tripId={id ?? ''}
            place={selectedPlace}
            isOpen={placeFormOpen}
            onClose={() => {
              setPlaceFormOpen(false);
              setSelectedPlaceState(null);
            }}
            onSubmit={handlePlaceFormSubmit}
            isLoading={updatePlace.isPending}
          />
        )}

        {/* Delete Place Confirmation */}
        <ConfirmDialog
          open={placeDeleteDialogOpen}
          onOpenChange={setPlaceDeleteDialogOpen}
          title="Delete Place"
          description="Are you sure you want to delete this place? This action cannot be undone and all photos will be removed."
          confirmLabel="Delete"
          onConfirm={handlePlaceDeleteConfirm}
          variant="destructive"
          isLoading={deletePlace.isPending}
        />

        {/* Photos Lightbox */}
        {lightboxOpen && allMediaFiles.length > 0 && (
          <Lightbox
            photos={allMediaFiles}
            currentIndex={lightboxIndex}
            onClose={() => setLightboxOpen(false)}
            onNext={handleLightboxNext}
            onPrevious={handleLightboxPrevious}
          />
        )}
      </PageContainer>
    </>
  );
}
