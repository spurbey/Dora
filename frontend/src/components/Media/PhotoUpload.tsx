import { useState, useRef } from 'react';
import { Upload, X, Image as ImageIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { LoadingSpinner } from '@/components/Shared/LoadingSpinner';
import { useMediaUpload } from '@/hooks/useMediaUpload';
import type { MediaFile } from '@/types/media';

interface PhotoUploadProps {
  placeId: string;
  onUploadComplete?: (media: MediaFile) => void;
}

const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
const ALLOWED_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];

export function PhotoUpload({ placeId, onUploadComplete }: PhotoUploadProps) {
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [caption, setCaption] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [isDragging, setIsDragging] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const { uploadWithProgress, isUploading } = useMediaUpload();

  const validateFile = (file: File): string | null => {
    if (!ALLOWED_TYPES.includes(file.type)) {
      return 'Invalid file type. Please upload a JPEG, PNG, or WebP image.';
    }
    if (file.size > MAX_FILE_SIZE) {
      return 'File too large. Maximum size is 10MB.';
    }
    return null;
  };

  const handleFileSelect = (file: File) => {
    setError(null);

    const validationError = validateFile(file);
    if (validationError) {
      setError(validationError);
      return;
    }

    setSelectedFile(file);

    // Create preview
    const reader = new FileReader();
    reader.onload = (e) => {
      setPreviewUrl(e.target?.result as string);
    };
    reader.readAsDataURL(file);
  };

  const handleFileInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      handleFileSelect(file);
    }
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);

    const file = e.dataTransfer.files[0];
    if (file) {
      handleFileSelect(file);
    }
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const handleUpload = async () => {
    if (!selectedFile) return;

    try {
      const media = await uploadWithProgress({
        file: selectedFile,
        trip_place_id: placeId,
        caption: caption || undefined,
      });

      // Reset form
      setSelectedFile(null);
      setPreviewUrl(null);
      setCaption('');
      setError(null);

      onUploadComplete?.(media);
    } catch (err) {
      setError('Failed to upload photo. Please try again.');
      console.error('Upload error:', err);
    }
  };

  const handleCancel = () => {
    setSelectedFile(null);
    setPreviewUrl(null);
    setCaption('');
    setError(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  return (
    <div className="space-y-4">
      {!selectedFile ? (
        <div
          onDrop={handleDrop}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onClick={() => fileInputRef.current?.click()}
          className={`cursor-pointer rounded-lg border-2 border-dashed p-8 text-center transition-colors ${
            isDragging
              ? 'border-emerald-400 bg-emerald-500/10'
              : 'border-white/20 bg-white/5 hover:border-emerald-400/50 hover:bg-white/10'
          }`}
        >
          <input
            ref={fileInputRef}
            type="file"
            accept={ALLOWED_TYPES.join(',')}
            onChange={handleFileInputChange}
            className="hidden"
          />
          <Upload className="mx-auto h-12 w-12 text-white/40" />
          <p className="mt-2 text-sm text-white/60">
            Drag & drop a photo here, or click to browse
          </p>
          <p className="mt-1 text-xs text-white/40">JPEG, PNG, WebP (max 10MB)</p>
        </div>
      ) : (
        <div className="space-y-4">
          {/* Preview */}
          <div className="relative">
            {previewUrl && (
              <img
                src={previewUrl}
                alt="Preview"
                className="h-48 w-full rounded-lg object-cover"
              />
            )}
            <Button
              variant="ghost"
              size="icon"
              onClick={handleCancel}
              className="absolute right-2 top-2 h-8 w-8 bg-black/50 text-white hover:bg-black/70"
            >
              <X className="h-4 w-4" />
            </Button>
          </div>

          {/* Caption */}
          <div>
            <Label htmlFor="caption" className="text-white/80">
              Caption (optional)
            </Label>
            <Input
              id="caption"
              value={caption}
              onChange={(e) => setCaption(e.target.value)}
              placeholder="Add a caption..."
              className="mt-1.5 bg-white/5 border-white/10 text-white"
              disabled={isUploading}
            />
          </div>

          {/* Actions */}
          <div className="flex gap-2">
            <Button
              onClick={handleUpload}
              disabled={isUploading}
              className="flex-1 bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500"
            >
              {isUploading ? (
                <>
                  <LoadingSpinner size="sm" className="mr-2" />
                  Uploading...
                </>
              ) : (
                <>
                  <ImageIcon className="mr-2 h-4 w-4" />
                  Upload Photo
                </>
              )}
            </Button>
            <Button
              variant="ghost"
              onClick={handleCancel}
              disabled={isUploading}
              className="text-white/60 hover:text-white hover:bg-white/5"
            >
              Cancel
            </Button>
          </div>
        </div>
      )}

      {error && (
        <div className="rounded-lg border border-red-500/20 bg-red-500/10 p-3 text-sm text-red-400">
          {error}
        </div>
      )}
    </div>
  );
}
