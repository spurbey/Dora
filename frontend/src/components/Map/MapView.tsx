import { useEffect, useRef, useState } from 'react';
import { mapboxgl } from '@/lib/mapbox';
import { useMapStore } from '@/store/mapStore';
import { MapControls } from './MapControls';
import type { Place } from '@/types/place';

interface MapViewProps {
  places: Place[];
  onPlaceClick: (place: Place) => void;
  className?: string;
  isVisible?: boolean;
}

export function MapView({ places, onPlaceClick, className, isVisible = true }: MapViewProps) {
  const mapContainer = useRef<HTMLDivElement>(null);
  const map = useRef<mapboxgl.Map | null>(null);
  const markers = useRef<mapboxgl.Marker[]>([]);
  const { viewport, setViewport, fitBoundsToPlaces, selectedPlaceId } = useMapStore();
  const [isMapLoaded, setIsMapLoaded] = useState(false);

  // Initialize map
  useEffect(() => {
    // Prevent double initialization
    if (!mapContainer.current || map.current) return;

    // Verify token is set
    if (!mapboxgl.accessToken) {
      console.error('Mapbox token is not configured');
      return;
    }

    const mapInstance = new mapboxgl.Map({
      container: mapContainer.current,
      style: 'mapbox://styles/mapbox/dark-v11',
      center: [viewport.longitude, viewport.latitude],
      zoom: viewport.zoom,
    });

    mapInstance.on('load', () => {
      setIsMapLoaded(true);
    });

    mapInstance.on('move', () => {
      const center = mapInstance.getCenter();
      const zoom = mapInstance.getZoom();
      setViewport({
        latitude: center.lat,
        longitude: center.lng,
        zoom,
      });
    });

    map.current = mapInstance;

    return () => {
      // Clean up markers
      markers.current.forEach((marker) => marker.remove());
      markers.current = [];

      // Remove map
      mapInstance.remove();
      map.current = null;
      setIsMapLoaded(false);
    };
  }, []);

  // Resize map when it becomes visible (fixes tab switching)
  useEffect(() => {
    if (map.current && isMapLoaded && isVisible) {
      // Small delay to ensure container dimensions are updated
      const timeoutId = setTimeout(() => {
        map.current?.resize();
      }, 100);
      return () => clearTimeout(timeoutId);
    }
  }, [isVisible, isMapLoaded]);

  // Update markers when places change
  useEffect(() => {
    if (!map.current || !isMapLoaded) return;

    // Clear existing markers
    markers.current.forEach((marker) => marker.remove());
    markers.current = [];

    // Add new markers
    places.forEach((place, index) => {
      const el = document.createElement('div');
      el.className = 'custom-marker';

      const isSelected = place.id === selectedPlaceId;

      el.innerHTML = `
        <div class="marker-content ${isSelected ? 'marker-selected' : ''}">
          <div class="marker-number">${place.order_in_trip ?? index + 1}</div>
        </div>
      `;

      el.onclick = () => onPlaceClick(place);

      const marker = new mapboxgl.Marker(el)
        .setLngLat([place.lng, place.lat])
        .addTo(map.current!);

      markers.current.push(marker);
    });

    // Fit bounds to show all places
    if (places.length > 0) {
      const newViewport = fitBoundsToPlaces(places);
      if (newViewport) {
        map.current.flyTo({
          center: [newViewport.longitude, newViewport.latitude],
          zoom: newViewport.zoom,
          duration: 1000,
        });
      }
    }
  }, [places, isMapLoaded, selectedPlaceId, onPlaceClick, fitBoundsToPlaces]);

  const handleZoomIn = () => {
    map.current?.zoomIn();
  };

  const handleZoomOut = () => {
    map.current?.zoomOut();
  };

  const handleResetView = () => {
    if (places.length > 0) {
      const newViewport = fitBoundsToPlaces(places);
      if (newViewport) {
        map.current?.flyTo({
          center: [newViewport.longitude, newViewport.latitude],
          zoom: newViewport.zoom,
          duration: 1000,
        });
      }
    }
  };

  const handleGeolocate = () => {
    if ('geolocation' in navigator) {
      navigator.geolocation.getCurrentPosition((position) => {
        map.current?.flyTo({
          center: [position.coords.longitude, position.coords.latitude],
          zoom: 14,
          duration: 1000,
        });
      });
    }
  };

  return (
    <div className={`relative h-full w-full ${className ?? ''}`}>
      <div ref={mapContainer} className="h-full w-full rounded-lg overflow-hidden" />
      <MapControls
        onZoomIn={handleZoomIn}
        onZoomOut={handleZoomOut}
        onResetView={handleResetView}
        onGeolocate={handleGeolocate}
      />
      <style>{`
        .custom-marker {
          cursor: pointer;
          transition: transform 0.2s;
        }
        .custom-marker:hover {
          transform: scale(1.1);
        }
        .marker-content {
          width: 40px;
          height: 40px;
          border-radius: 50%;
          background: linear-gradient(135deg, #10b981, #14b8a6);
          border: 3px solid white;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
          display: flex;
          align-items: center;
          justify-content: center;
          animation: pulse 2s infinite;
        }
        .marker-selected {
          background: linear-gradient(135deg, #f59e0b, #f97316);
          animation: pulse-selected 1s infinite;
        }
        .marker-number {
          color: white;
          font-weight: bold;
          font-size: 14px;
        }
        @keyframes pulse {
          0%, 100% {
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
          }
          50% {
            box-shadow: 0 4px 20px rgba(16, 185, 129, 0.6);
          }
        }
        @keyframes pulse-selected {
          0%, 100% {
            box-shadow: 0 4px 12px rgba(245, 158, 11, 0.6);
          }
          50% {
            box-shadow: 0 4px 24px rgba(245, 158, 11, 0.9);
          }
        }
      `}</style>
    </div>
  );
}
