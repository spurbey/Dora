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

const MAX_WEB_MERCATOR_LAT = 85.05112878;
const DEFAULT_MAP_STYLE = 'mapbox/navigation-night-v1';
const TILE_SIZE = 512;

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

function isFiniteNumber(value) {
  return typeof value === 'number' && Number.isFinite(value);
}

function toLngLat(coord) {
  if (!Array.isArray(coord) || coord.length < 2) {
    return null;
  }
  const lng = Number(coord[0]);
  const lat = Number(coord[1]);
  if (!isFiniteNumber(lng) || !isFiniteNumber(lat)) {
    return null;
  }
  return {
    lng: clamp(lng, -180, 180),
    lat: clamp(lat, -MAX_WEB_MERCATOR_LAT, MAX_WEB_MERCATOR_LAT),
  };
}

function normalizeLon(lon) {
  return (lon + 180) / 360;
}

function normalizeLat(lat) {
  const sin = Math.sin((clamp(lat, -MAX_WEB_MERCATOR_LAT, MAX_WEB_MERCATOR_LAT) * Math.PI) / 180);
  return 0.5 - Math.log((1 + sin) / (1 - sin)) / (4 * Math.PI);
}

function lngLatToWorld(lng, lat, zoom) {
  const scale = TILE_SIZE * 2 ** zoom;
  return {
    x: normalizeLon(lng) * scale,
    y: normalizeLat(lat) * scale,
  };
}

function worldToLngLat(x, y, zoom) {
  const scale = TILE_SIZE * 2 ** zoom;
  const lon = (x / scale) * 360 - 180;
  const n = Math.PI - (2 * Math.PI * y) / scale;
  const lat = (180 / Math.PI) * Math.atan(0.5 * (Math.exp(n) - Math.exp(-n)));
  return {
    lng: clamp(lon, -180, 180),
    lat: clamp(lat, -MAX_WEB_MERCATOR_LAT, MAX_WEB_MERCATOR_LAT),
  };
}

function roundTo(value, places = 5) {
  const factor = 10 ** places;
  return Math.round(value * factor) / factor;
}

export function getRouteCoordinates(route) {
  const geo = route?.route_geojson;
  if (!geo || geo.type !== 'LineString' || !Array.isArray(geo.coordinates)) {
    return [];
  }
  return geo.coordinates.map(toLngLat).filter(Boolean);
}

export function getPlaceCoordinate(place) {
  const lat = Number(place?.lat);
  const lng = Number(place?.lng);
  if (!isFiniteNumber(lat) || !isFiniteNumber(lng)) {
    return null;
  }
  return {
    lng: clamp(lng, -180, 180),
    lat: clamp(lat, -MAX_WEB_MERCATOR_LAT, MAX_WEB_MERCATOR_LAT),
  };
}

export function fitViewportToCoordinates(
  coordinates,
  {
    width,
    height,
    paddingRatio = 0.14,
    defaultZoom = 11.25,
    minZoom = 1.5,
    maxZoom = 16.5,
  } = {},
) {
  const coords = Array.isArray(coordinates) ? coordinates.filter(Boolean) : [];
  if (coords.length === 0 || !isFiniteNumber(width) || !isFiniteNumber(height) || width <= 0 || height <= 0) {
    return null;
  }

  if (coords.length === 1) {
    return {
      center: coords[0],
      zoom: defaultZoom,
    };
  }

  const mercator = coords.map((point) => ({
    x: normalizeLon(point.lng),
    y: normalizeLat(point.lat),
  }));

  let minX = Infinity;
  let maxX = -Infinity;
  let minY = Infinity;
  let maxY = -Infinity;

  mercator.forEach((point) => {
    minX = Math.min(minX, point.x);
    maxX = Math.max(maxX, point.x);
    minY = Math.min(minY, point.y);
    maxY = Math.max(maxY, point.y);
  });

  const spanX = Math.max(maxX - minX, 1e-6);
  const spanY = Math.max(maxY - minY, 1e-6);
  const safePadding = clamp(paddingRatio, 0.02, 0.35);
  const viewWidth = Math.max(1, width * (1 - safePadding * 2));
  const viewHeight = Math.max(1, height * (1 - safePadding * 2));

  const zoomX = Math.log2(viewWidth / (TILE_SIZE * spanX));
  const zoomY = Math.log2(viewHeight / (TILE_SIZE * spanY));
  const zoom = clamp(Math.min(zoomX, zoomY), minZoom, maxZoom);

  const centerWorld = {
    x: ((minX + maxX) / 2) * TILE_SIZE * 2 ** zoom,
    y: ((minY + maxY) / 2) * TILE_SIZE * 2 ** zoom,
  };
  const center = worldToLngLat(centerWorld.x, centerWorld.y, zoom);
  return { center, zoom };
}

export function projectCoordinates(coordinates, viewport, width, height) {
  if (!viewport || !viewport.center) {
    return [];
  }
  const coords = Array.isArray(coordinates) ? coordinates.filter(Boolean) : [];
  if (coords.length === 0) {
    return [];
  }
  const centerWorld = lngLatToWorld(viewport.center.lng, viewport.center.lat, viewport.zoom);
  return coords.map((point) => {
    const world = lngLatToWorld(point.lng, point.lat, viewport.zoom);
    return {
      x: world.x - centerWorld.x + width / 2,
      y: world.y - centerWorld.y + height / 2,
    };
  });
}

function downsamplePoints(points, maxPoints = 900) {
  if (!Array.isArray(points) || points.length <= maxPoints) {
    return points;
  }
  const step = Math.max(1, Math.floor((points.length - 1) / (maxPoints - 1)));
  const sampled = [];
  for (let index = 0; index < points.length; index += step) {
    sampled.push(points[index]);
  }
  const lastPoint = points[points.length - 1];
  const sampledLast = sampled[sampled.length - 1];
  if (!sampledLast || sampledLast.x !== lastPoint.x || sampledLast.y !== lastPoint.y) {
    sampled.push(lastPoint);
  }
  return sampled;
}

function chaikinIteration(points, ratio = 0.24) {
  if (!Array.isArray(points) || points.length < 3) {
    return points;
  }
  const clampedRatio = clamp(ratio, 0.1, 0.4);
  const next = [points[0]];
  for (let index = 0; index < points.length - 1; index += 1) {
    const p0 = points[index];
    const p1 = points[index + 1];
    const q = {
      x: (1 - clampedRatio) * p0.x + clampedRatio * p1.x,
      y: (1 - clampedRatio) * p0.y + clampedRatio * p1.y,
    };
    const r = {
      x: clampedRatio * p0.x + (1 - clampedRatio) * p1.x,
      y: clampedRatio * p0.y + (1 - clampedRatio) * p1.y,
    };
    next.push(q, r);
  }
  next.push(points[points.length - 1]);
  return next;
}

export function smoothPolyline(points, iterations = 1) {
  if (!Array.isArray(points) || points.length < 3) {
    return points || [];
  }
  const roundCount = clamp(Math.round(iterations), 0, 3);
  let current = points;
  for (let index = 0; index < roundCount; index += 1) {
    current = chaikinIteration(current);
    current = downsamplePoints(current, 900);
  }
  return current;
}

export function getRendererMapConfig(snapshot = {}) {
  const rendererConfig =
    snapshot && typeof snapshot.renderer_config === 'object' ? snapshot.renderer_config : {};
  const token = typeof rendererConfig.mapbox_token === 'string' ? rendererConfig.mapbox_token.trim() : '';
  const style = typeof rendererConfig.map_style === 'string' && rendererConfig.map_style.trim().length > 0
    ? rendererConfig.map_style.trim()
    : DEFAULT_MAP_STYLE;
  return { token, style };
}

export function buildMapboxStaticUrl({
  token,
  style = DEFAULT_MAP_STYLE,
  center,
  zoom,
  width,
  height,
}) {
  if (!token || !center || !isFiniteNumber(zoom) || !isFiniteNumber(width) || !isFiniteNumber(height)) {
    return null;
  }

  const requestWidth = clamp(Math.round(width / 2), 128, 1280);
  const requestHeight = clamp(Math.round(height / 2), 128, 1280);

  const centerSegment = `${roundTo(center.lng, 5)},${roundTo(center.lat, 5)},${roundTo(zoom, 2)},0,0`;
  const sizeSegment = `${requestWidth}x${requestHeight}@2x`;
  return `https://api.mapbox.com/styles/v1/${style}/static/${centerSegment}/${sizeSegment}?access_token=${encodeURIComponent(token)}&logo=false&attribution=false`;
}

export function buildSceneMapContext({
  snapshot = {},
  route = null,
  place = null,
  width = 720,
  height = 1280,
  paddingRatio = 0.14,
}) {
  const routeCoordinates = getRouteCoordinates(route);
  const placeCoordinate = getPlaceCoordinate(place);
  const coordinates = routeCoordinates.slice();
  if (placeCoordinate) {
    coordinates.push(placeCoordinate);
  }
  if (coordinates.length === 0) {
    return null;
  }

  const viewport = fitViewportToCoordinates(coordinates, {
    width,
    height,
    paddingRatio,
  });
  if (!viewport) {
    return null;
  }

  const projectedRoutePoints = projectCoordinates(routeCoordinates, viewport, width, height);
  const routePoints = smoothPolyline(
    projectedRoutePoints,
    projectedRoutePoints.length > 12 ? 2 : projectedRoutePoints.length > 4 ? 1 : 0,
  );
  const placePoint = placeCoordinate
    ? projectCoordinates([placeCoordinate], viewport, width, height)[0]
    : null;
  const { token, style } = getRendererMapConfig(snapshot);
  const mapUrl = buildMapboxStaticUrl({
    token,
    style,
    center: viewport.center,
    zoom: viewport.zoom,
    width,
    height,
  });

  const start = routePoints[0] || null;
  const end = routePoints[routePoints.length - 1] || null;
  const routeVector = start && end
    ? { x: end.x - start.x, y: end.y - start.y }
    : { x: 0, y: 0 };

  return {
    mapUrl,
    viewport,
    routePoints,
    placePoint,
    routeVector,
  };
}

export function pointsToPath(points) {
  if (!Array.isArray(points) || points.length < 2) {
    return '';
  }
  return points
    .map((point, index) => `${index === 0 ? 'M' : 'L'} ${point.x.toFixed(2)} ${point.y.toFixed(2)}`)
    .join(' ');
}

export function polylineLength(points) {
  if (!Array.isArray(points) || points.length < 2) {
    return 0;
  }
  let total = 0;
  for (let index = 1; index < points.length; index += 1) {
    const dx = points[index].x - points[index - 1].x;
    const dy = points[index].y - points[index - 1].y;
    total += Math.hypot(dx, dy);
  }
  return total;
}

export function pointAtProgress(points, progress) {
  if (!Array.isArray(points) || points.length === 0) {
    return { x: 0, y: 0 };
  }
  if (points.length === 1) {
    return points[0];
  }

  const targetLength = polylineLength(points) * clamp(progress, 0, 1);
  let walked = 0;
  for (let index = 1; index < points.length; index += 1) {
    const previous = points[index - 1];
    const current = points[index];
    const segmentLength = Math.hypot(current.x - previous.x, current.y - previous.y);
    if (walked + segmentLength >= targetLength) {
      const ratio = segmentLength === 0 ? 0 : (targetLength - walked) / segmentLength;
      return {
        x: previous.x + (current.x - previous.x) * ratio,
        y: previous.y + (current.y - previous.y) * ratio,
      };
    }
    walked += segmentLength;
  }
  return points[points.length - 1];
}
