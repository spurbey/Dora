import { create } from 'zustand';
import type { Place } from '@/types/place';

interface Viewport {
  latitude: number;
  longitude: number;
  zoom: number;
}

interface MapState {
  viewport: Viewport;
  selectedPlaceId: string | null;

  setViewport: (viewport: Partial<Viewport>) => void;
  setSelectedPlace: (id: string | null) => void;
  fitBoundsToPlaces: (places: Place[]) => Viewport | null;
}

export const useMapStore = create<MapState>((set) => ({
  viewport: {
    latitude: 48.8566, // Default to Paris
    longitude: 2.3522,
    zoom: 12,
  },
  selectedPlaceId: null,

  setViewport: (newViewport) =>
    set((state) => ({
      viewport: { ...state.viewport, ...newViewport },
    })),

  setSelectedPlace: (id) =>
    set({
      selectedPlaceId: id,
    }),

  fitBoundsToPlaces: (places) => {
    if (places.length === 0) return null;

    if (places.length === 1) {
      // Single place: center on it
      return {
        latitude: places[0].lat,
        longitude: places[0].lng,
        zoom: 14,
      };
    }

    // Multiple places: calculate bounding box
    const lats = places.map((p) => p.lat);
    const lngs = places.map((p) => p.lng);

    const minLat = Math.min(...lats);
    const maxLat = Math.max(...lats);
    const minLng = Math.min(...lngs);
    const maxLng = Math.max(...lngs);

    const centerLat = (minLat + maxLat) / 2;
    const centerLng = (minLng + maxLng) / 2;

    // Calculate appropriate zoom level based on bounds
    const latDiff = maxLat - minLat;
    const lngDiff = maxLng - minLng;
    const maxDiff = Math.max(latDiff, lngDiff);

    let zoom = 14;
    if (maxDiff > 1) zoom = 10;
    else if (maxDiff > 0.5) zoom = 11;
    else if (maxDiff > 0.2) zoom = 12;
    else if (maxDiff > 0.1) zoom = 13;

    return {
      latitude: centerLat,
      longitude: centerLng,
      zoom,
    };
  },
}));
