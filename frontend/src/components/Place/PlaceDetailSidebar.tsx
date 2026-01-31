import { useState } from 'react';
import { X, Edit, Trash2, MapPin } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { PhotoUpload } from '@/components/Media/PhotoUpload';
import { PhotoGallery } from '@/components/Media/PhotoGallery';
import { Lightbox } from '@/components/Media/Lightbox';
import { ConfirmDialog } from '@/components/Shared/ConfirmDialog';
import { usePlace } from '@/hooks/usePlaces';
import { useDeleteMedia } from '@/hooks/useMediaUpload';
import { LoadingSpinner } from '@/components/Shared/LoadingSpinner';
import type { MediaFile } from '@/types/media';

interface PlaceDetailSidebarProps {
  placeId: string;
  isOpen: boolean;
  onClose: () => void;
  onEdit: () => void;
  onDelete: () => void;
}

const PLACE_TYPE_EMOJI: Record<string, string> = {
  restaurant: '🍽️',
  hotel: '🏨',
  attraction: '🎭',
  cafe: '☕',
  bar: '🍺',
  museum: '🏛️',
  park: '🌳',
  shop: '🛍️',
  other: '📍',
};

export function PlaceDetailSidebar({
  placeId,
  isOpen,
  onClose,
  onEdit,
  onDelete,
}: PlaceDetailSidebarProps) {
  const { data: place, isLoading } = usePlace(placeId);
  const deleteMedia = useDeleteMedia();
  const [lightboxOpen, setLightboxOpen] = useState(false);
  const [lightboxIndex, setLightboxIndex] = useState(0);
  const [mediaToDelete, setMediaToDelete] = useState<string | null>(null);

  if (!isOpen) return null;

  const handlePhotoClick = (_photo: MediaFile, index: number) => {
    setLightboxIndex(index);
    setLightboxOpen(true);
  };

  const handleLightboxNext = () => {
    if (place && lightboxIndex < place.photos.length - 1) {
      setLightboxIndex(lightboxIndex + 1);
    }
  };

  const handleLightboxPrevious = () => {
    if (lightboxIndex > 0) {
      setLightboxIndex(lightboxIndex - 1);
    }
  };

  const handleDeleteMedia = async () => {
    if (!mediaToDelete || !place) return;
    try {
      await deleteMedia.mutateAsync({
        id: mediaToDelete,
        placeId: place.id,
        tripId: place.trip_id,
      });
      setMediaToDelete(null);
    } catch (error) {
      console.error('Failed to delete media:', error);
    }
  };

  // Get media files from place.photos
  // Backend now returns full MediaFile objects
  const mediaFiles: MediaFile[] = place?.photos || [];

  return (
    <>
      {/* Overlay */}
      <div
        className="fixed inset-0 z-40 bg-black/50"
        onClick={onClose}
        aria-hidden="true"
      />

      {/* Sidebar */}
      <div className="fixed right-0 top-0 z-50 h-full w-full max-w-md overflow-y-auto border-l border-white/10 bg-slate-900 shadow-2xl">
        {/* Header */}
        <div className="sticky top-0 z-10 flex items-center justify-between border-b border-white/10 bg-slate-900/95 p-4 backdrop-blur">
          <h2 className="text-lg font-semibold text-white">Place Details</h2>
          <Button
            variant="ghost"
            size="icon"
            onClick={onClose}
            className="text-white/60 hover:text-white hover:bg-white/10"
          >
            <X className="h-5 w-5" />
          </Button>
        </div>

        {isLoading ? (
          <div className="flex items-center justify-center p-12">
            <LoadingSpinner size="lg" />
          </div>
        ) : place ? (
          <div className="space-y-6 p-4">
            {/* Place Info */}
            <div>
              <div className="flex items-start justify-between gap-3">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    <span className="text-2xl">
                      {PLACE_TYPE_EMOJI[place.place_type || 'other'] || '📍'}
                    </span>
                    <h3 className="text-xl font-bold text-white">{place.name}</h3>
                  </div>

                  {place.place_type && (
                    <div className="mb-2 flex items-center gap-1 text-sm text-white/60">
                      <MapPin className="h-3.5 w-3.5" />
                      {place.place_type.charAt(0).toUpperCase() + place.place_type.slice(1)}
                    </div>
                  )}

                  <p className="text-xs text-white/40">
                    {place.lat.toFixed(4)}, {place.lng.toFixed(4)}
                  </p>
                </div>

                <div className="flex gap-1">
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={onEdit}
                    className="h-9 w-9 text-white/60 hover:text-white hover:bg-white/10"
                  >
                    <Edit className="h-4 w-4" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={onDelete}
                    className="h-9 w-9 text-red-500/60 hover:text-red-500 hover:bg-red-500/10"
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              </div>

              {place.user_notes && (
                <div className="mt-4 rounded-lg border border-white/10 bg-white/5 p-3">
                  <p className="text-sm text-white/80">{place.user_notes}</p>
                </div>
              )}
            </div>

            {/* Photos */}
            <div>
              <h4 className="mb-3 font-semibold text-white">Photos</h4>
              <PhotoGallery
                photos={mediaFiles}
                onPhotoClick={handlePhotoClick}
                onPhotoDelete={(id) => setMediaToDelete(id)}
              />
            </div>

            {/* Upload */}
            <div>
              <h4 className="mb-3 font-semibold text-white">Add Photo</h4>
              <PhotoUpload placeId={place.id} />
            </div>
          </div>
        ) : (
          <div className="p-4 text-center text-white/50">Place not found</div>
        )}
      </div>

      {/* Lightbox */}
      {lightboxOpen && mediaFiles.length > 0 && (
        <Lightbox
          photos={mediaFiles}
          currentIndex={lightboxIndex}
          onClose={() => setLightboxOpen(false)}
          onNext={handleLightboxNext}
          onPrevious={handleLightboxPrevious}
        />
      )}

      {/* Delete Confirmation */}
      <ConfirmDialog
        open={!!mediaToDelete}
        onOpenChange={(open) => !open && setMediaToDelete(null)}
        onConfirm={handleDeleteMedia}
        title="Delete Photo"
        description="Are you sure you want to delete this photo? This action cannot be undone."
        confirmLabel="Delete"
        variant="destructive"
      />
    </>
  );
}
