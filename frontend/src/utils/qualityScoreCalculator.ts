import type { Trip } from '@/types/trip';
import type { TripMetadata } from '@/types/tripMetadata';
import type { Place } from '@/types/place';
import type { Route } from '@/types/route';
import type { PlaceMetadata } from '@/types/placeMetadata';
import type { RouteMetadata } from '@/types/routeMetadata';

interface QualityScoreInput {
  trip: Trip | null;
  tripMetadata: TripMetadata | null;
  places: Place[];
  routes: Route[];
  placeMetadata: Record<string, PlaceMetadata>;
  routeMetadata: Record<string, RouteMetadata>;
}

export function calculateQualityScore({
  trip,
  tripMetadata,
  places,
  routes,
  placeMetadata,
  routeMetadata,
}: QualityScoreInput) {
  const tripFields = [
    tripMetadata?.traveler_type?.length,
    tripMetadata?.age_group,
    tripMetadata?.travel_style?.length,
    tripMetadata?.difficulty_level,
    tripMetadata?.budget_category,
    tripMetadata?.activity_focus?.length,
  ];
  const tripMetadataScore =
    tripFields.filter((item) => Boolean(item)).length / tripFields.length;

  const placeCount = places.length;
  const routeCount = routes.length;
  const placeWithMetadata = places.filter((place) => Boolean(placeMetadata[place.id])).length;
  const routeWithMetadata = routes.filter((route) => Boolean(routeMetadata[route.id])).length;
  const placeCoverage = placeCount ? placeWithMetadata / placeCount : 0;
  const routeCoverage = routeCount ? routeWithMetadata / routeCount : 0;
  const componentMetadataScore = (placeCoverage + routeCoverage) / 2;

  const hasCoverPhoto = Boolean(trip?.cover_photo_url);
  const avgPhotos =
    placeCount > 0
      ? places.reduce((sum, place) => sum + (place.photos?.length ?? 0), 0) / placeCount
      : 0;
  const photoScore = avgPhotos >= 2 ? 1 : avgPhotos / 2;
  const mediaScore = (hasCoverPhoto ? 0.25 : 0) + 0.75 * photoScore;

  const hasDescription = Boolean(trip?.description);
  const hasDates = Boolean(trip?.start_date && trip?.end_date);
  const timelineScore = (hasDescription ? 0.5 : 0) + (hasDates ? 0.5 : 0);

  const score =
    tripMetadataScore * 0.3 +
    componentMetadataScore * 0.4 +
    mediaScore * 0.2 +
    timelineScore * 0.1;

  return {
    score,
    breakdown: {
      tripMetadataScore,
      componentMetadataScore,
      mediaScore,
      timelineScore,
    },
  };
}
