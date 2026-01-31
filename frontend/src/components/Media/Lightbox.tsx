import { useEffect } from 'react';
import { X, ChevronLeft, ChevronRight } from 'lucide-react';
import { Button } from '@/components/ui/button';
import type { MediaFile } from '@/types/media';

interface LightboxProps {
  photos: MediaFile[];
  currentIndex: number;
  onClose: () => void;
  onNext: () => void;
  onPrevious: () => void;
}

export function Lightbox({
  photos,
  currentIndex,
  onClose,
  onNext,
  onPrevious,
}: LightboxProps) {
  const currentPhoto = photos[currentIndex];

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose();
      } else if (e.key === 'ArrowLeft') {
        onPrevious();
      } else if (e.key === 'ArrowRight') {
        onNext();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [onClose, onNext, onPrevious]);

  // Prevent body scroll when lightbox is open
  useEffect(() => {
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, []);

  if (!currentPhoto) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/95">
      {/* Close Button */}
      <Button
        variant="ghost"
        size="icon"
        onClick={onClose}
        className="absolute right-4 top-4 z-10 h-10 w-10 text-white hover:bg-white/10"
      >
        <X className="h-6 w-6" />
      </Button>

      {/* Previous Button */}
      {currentIndex > 0 && (
        <Button
          variant="ghost"
          size="icon"
          onClick={onPrevious}
          className="absolute left-4 top-1/2 z-10 h-12 w-12 -translate-y-1/2 text-white hover:bg-white/10"
        >
          <ChevronLeft className="h-8 w-8" />
        </Button>
      )}

      {/* Next Button */}
      {currentIndex < photos.length - 1 && (
        <Button
          variant="ghost"
          size="icon"
          onClick={onNext}
          className="absolute right-4 top-1/2 z-10 h-12 w-12 -translate-y-1/2 text-white hover:bg-white/10"
        >
          <ChevronRight className="h-8 w-8" />
        </Button>
      )}

      {/* Main Image */}
      <div className="relative max-h-[90vh] max-w-[90vw]">
        <img
          src={currentPhoto.file_url}
          alt={currentPhoto.caption || 'Photo'}
          className="max-h-[90vh] max-w-[90vw] object-contain"
        />

        {/* Caption */}
        {currentPhoto.caption && (
          <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/80 to-transparent p-4">
            <p className="text-center text-white">{currentPhoto.caption}</p>
          </div>
        )}

        {/* Photo Counter */}
        <div className="absolute left-1/2 top-4 -translate-x-1/2 rounded-full bg-black/50 px-3 py-1 text-sm text-white">
          {currentIndex + 1} / {photos.length}
        </div>
      </div>

      {/* Swipe instruction for mobile */}
      <div className="absolute bottom-4 left-1/2 -translate-x-1/2 text-xs text-white/50 md:hidden">
        Swipe left or right to navigate
      </div>
    </div>
  );
}
