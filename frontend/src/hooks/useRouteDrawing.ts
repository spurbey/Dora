import { useCallback, useState } from 'react';
import { mapboxDirections, type MapboxProfile } from '@/services/mapboxDirections';
import { useEditorStore } from '@/store/editorStore';
import type { TempRoute } from '@/types/route';

const PROFILE_BY_MODE: Record<TempRoute['transport_mode'], MapboxProfile> = {
  car: 'driving',
  bike: 'cycling',
  foot: 'walking',
};

export function useRouteDrawing() {
  const tempRoute = useEditorStore((state) => state.tempRoute);
  const setTempRoute = useEditorStore((state) => state.setTempRoute);
  const drawingTransportMode = useEditorStore((state) => state.drawingTransportMode);

  const [isLoading, setIsLoading] = useState(false);

  const buildPreview = useCallback(
    async (points: TempRoute['points'], transportMode: TempRoute['transport_mode']) => {
      if (points.length < 2) return;

      setIsLoading(true);
      try {
        const coordinates: Array<[number, number]> = points.map((point) => [point.lng, point.lat]);
        const profile = PROFILE_BY_MODE[transportMode];
        const preview = await mapboxDirections.getRoute(coordinates, profile);

        setTempRoute({
          points,
          transport_mode: transportMode,
          preview,
        });
      } catch (error) {
        // Keep existing points if preview fails
        setTempRoute({
          points,
          transport_mode: transportMode,
        });
        console.error('Failed to fetch route preview', error);
      } finally {
        setIsLoading(false);
      }
    },
    [setTempRoute]
  );

  const addPoint = useCallback(
    async (lng: number, lat: number, transportMode: TempRoute['transport_mode'] = drawingTransportMode) => {
      const points = [...(tempRoute?.points ?? []), { lng, lat }];

      setTempRoute({
        points,
        transport_mode: transportMode,
        preview: tempRoute?.preview,
      });

      if (points.length >= 2) {
        await buildPreview(points, transportMode);
      }
    },
    [buildPreview, drawingTransportMode, setTempRoute, tempRoute?.points, tempRoute?.preview]
  );

  const clearRoute = useCallback(() => {
    setTempRoute(null);
  }, [setTempRoute]);

  const undoLastPoint = useCallback(async () => {
    if (!tempRoute) return;

    const points = tempRoute.points.slice(0, -1);
    if (points.length === 0) {
      setTempRoute(null);
      return;
    }

    setTempRoute({
      points,
      transport_mode: tempRoute.transport_mode,
    });

    if (points.length >= 2) {
      await buildPreview(points, tempRoute.transport_mode);
    }
  }, [buildPreview, setTempRoute, tempRoute]);

  return {
    tempRoute,
    isLoading,
    addPoint,
    clearRoute,
    undoLastPoint,
  };
}
