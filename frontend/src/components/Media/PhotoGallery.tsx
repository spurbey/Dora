import { Trash2, Image as ImageIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';
import type { MediaFile } from '@/types/media';

interface PhotoGalleryProps {
  photos: MediaFile[];
  onPhotoClick: (photo: MediaFile, index: number) => void;
  onPhotoDelete?: (id: string) => void;
  className?: string;
}

export function PhotoGallery({
  photos,
  onPhotoClick,
  onPhotoDelete,
  className,
}: PhotoGalleryProps) {
  if (photos.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center rounded-lg border border-dashed border-white/20 bg-white/5 p-8 text-center">
        <ImageIcon className="h-12 w-12 text-white/20" />
        <p className="mt-2 text-sm text-white/50">No photos yet</p>
      </div>
    );
  }

  return (
    <div className={`grid grid-cols-2 gap-3 md:grid-cols-3 ${className}`}>
      {photos.map((photo, index) => (
        <div
          key={photo.id}
          className="group relative aspect-square cursor-pointer overflow-hidden rounded-lg bg-slate-800"
          onClick={() => onPhotoClick(photo, index)}
        >
          <img
            src={photo.thumbnail_url || photo.file_url}
            alt={photo.caption || 'Photo'}
            className="h-full w-full object-cover transition-transform group-hover:scale-110"
          />

          {/* Caption Overlay */}
          {photo.caption && (
            <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/80 to-transparent p-2 opacity-0 transition-opacity group-hover:opacity-100">
              <p className="text-xs text-white line-clamp-2">{photo.caption}</p>
            </div>
          )}

          {/* Delete Button */}
          {onPhotoDelete && (
            <Button
              variant="ghost"
              size="icon"
              onClick={(e) => {
                e.stopPropagation();
                onPhotoDelete(photo.id);
              }}
              className="absolute right-2 top-2 h-8 w-8 bg-black/50 text-white opacity-0 transition-opacity hover:bg-red-500/80 group-hover:opacity-100"
            >
              <Trash2 className="h-4 w-4" />
            </Button>
          )}
        </div>
      ))}
    </div>
  );
}
