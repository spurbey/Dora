import { useMemo } from 'react';
import { useEditorStore } from '@/store/editorStore';
import { calculateQualityScore } from '@/utils/qualityScoreCalculator';

export function useQualityScore() {
  const { trip, tripMetadata, places, routes, placeMetadata, routeMetadata } = useEditorStore();

  return useMemo(
    () =>
      calculateQualityScore({
        trip,
        tripMetadata,
        places,
        routes,
        placeMetadata,
        routeMetadata,
      }),
    [trip, tripMetadata, places, routes, placeMetadata, routeMetadata]
  );
}
