export function resolveTimelinePlaces(snapshot = {}) {
  const timeline = Array.isArray(snapshot.timeline) ? snapshot.timeline : [];
  const directPlaces = Array.isArray(snapshot.places) ? snapshot.places : [];

  const timelinePlaces = timeline
    .filter((item) => item && item.component_type !== 'route' && item.name)
    .map((item) => ({
      ...item,
      media: Array.isArray(item.media) ? item.media : [],
    }));

  return timelinePlaces.length > 0 ? timelinePlaces : directPlaces;
}

export function resolveTimelineRoutes(snapshot = {}) {
  const timeline = Array.isArray(snapshot.timeline) ? snapshot.timeline : [];
  const directRoutes = Array.isArray(snapshot.routes) ? snapshot.routes : [];

  const timelineRoutes = timeline
    .filter((item) => item && item.component_type === 'route')
    .map((item) => ({
      ...item,
      route_geojson: item.route_geojson || null,
    }));

  return timelineRoutes.length > 0 ? timelineRoutes : directRoutes;
}

export function isImageMedia(media) {
  if (!media) {
    return false;
  }
  const fileType = (media.file_type || '').toLowerCase();
  if (fileType === 'photo' || fileType === 'image') {
    return true;
  }
  const mimeType = (media.mime_type || '').toLowerCase();
  return mimeType.startsWith('image/');
}

export function getPlaceImageUrl(place) {
  const media = Array.isArray(place?.media) ? place.media : [];
  const imageMedia = media.find(isImageMedia);
  if (imageMedia?.url) {
    return imageMedia.url;
  }
  const thumbFallback = media.find(
    (item) => typeof item?.thumbnail_url === 'string' && item.thumbnail_url.length > 0,
  );
  return thumbFallback?.thumbnail_url ?? null;
}

