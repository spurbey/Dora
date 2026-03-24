import { isAirRoute, resolveTransportMode } from './gl/transport-mode.js';

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

// ---------------------------------------------------------------------------
// Phase 1 helpers: global map context, journey timeline, route styles
// ---------------------------------------------------------------------------

export const ROUTE_STYLES = {
  car:   { color: '#FFC24D', width: 5, dash: null },
  foot:  { color: '#45E79B', width: 4, dash: null },
  bike:  { color: '#69F0AE', width: 4, dash: null },
  air:   { color: '#66D9FF', width: 4, dash: '10,7' },
  bus:   { color: '#FF9E58', width: 5, dash: null },
  train: { color: '#C186FF', width: 4.5, dash: null },
};

const DEFAULT_ROUTE_STYLE = ROUTE_STYLES.car;

export function getRouteStyle(route) {
  const mode = resolveTransportMode(route, 'car');
  return ROUTE_STYLES[mode] || DEFAULT_ROUTE_STYLE;
}

export function airArcPath(start, end) {
  if (!start || !end) return '';
  const midX = (start.x + end.x) / 2;
  const midY = (start.y + end.y) / 2;
  const dist = Math.hypot(end.x - start.x, end.y - start.y);
  const controlY = midY - dist * 0.3;
  return `M ${start.x.toFixed(2)} ${start.y.toFixed(2)} Q ${midX.toFixed(2)} ${controlY.toFixed(2)} ${end.x.toFixed(2)} ${end.y.toFixed(2)}`;
}

export function getHeadingAtProgress(points, progress) {
  if (!Array.isArray(points) || points.length < 2) return 0;
  const epsilon = 0.005;
  const p1 = pointAtProgress(points, Math.max(0, progress - epsilon));
  const p2 = pointAtProgress(points, Math.min(1, progress + epsilon));
  return Math.atan2(p2.y - p1.y, p2.x - p1.x) * (180 / Math.PI);
}

export function buildGlobalMapContext({ snapshot = {}, width = 720, height = 1280 }) {
  const places = resolveTimelinePlaces(snapshot);
  const routes = resolveTimelineRoutes(snapshot);

  // Collect every coordinate across all places and routes.
  const allCoords = [];
  const placeCoords = [];
  places.forEach((place) => {
    const coord = getPlaceCoordinate(place);
    if (coord) {
      allCoords.push(coord);
      placeCoords.push({ coord, place });
    }
  });
  routes.forEach((route) => {
    getRouteCoordinates(route).forEach((c) => allCoords.push(c));
  });

  if (allCoords.length === 0) return null;

  // CRITICAL: Mapbox Static API @2x means the geographic coverage is determined
  // by the PRE-@2x size. The @2x only doubles pixel density.
  // So we must fit the viewport and project coordinates using the GEOGRAPHIC
  // dimensions (what Mapbox actually covers), not the pixel dimensions.
  //
  // OVERSIZE factor gives room for camera panning without revealing map edges.
  // Larger map = higher auto-fit zoom = more city-level detail.
  const OVERSIZE = 2.5;
  const geoWidth = clamp(Math.round((width * OVERSIZE) / 2), 128, 1280);
  const geoHeight = clamp(Math.round((height * OVERSIZE) / 2), 128, 1280);

  // Fit viewport using geographic dimensions (matches Mapbox coverage).
  // Low padding maximizes the zoom level for more detail.
  const viewport = fitViewportToCoordinates(allCoords, {
    width: geoWidth,
    height: geoHeight,
    paddingRatio: 0.06,
  });
  if (!viewport) return null;

  // Project places into geographic coordinate space.
  const projectedPlaces = placeCoords.map(({ coord, place }) => {
    const [pt] = projectCoordinates([coord], viewport, geoWidth, geoHeight);
    return { x: pt.x, y: pt.y, place };
  });

  // Project routes into geographic coordinate space.
  const projectedRoutes = routes.map((route) => {
    const coords = getRouteCoordinates(route);
    if (coords.length === 0 && (isAirRoute(route) || !route.route_geojson)) {
      // Synthesize from start/end places.
      const startPlace = projectedPlaces.find((p) => p.place.id === route.start_place_id);
      const endPlace = projectedPlaces.find((p) => p.place.id === route.end_place_id);
      return { points: [], route, startPoint: startPlace || null, endPoint: endPlace || null, isArc: true };
    }
    const projected = projectCoordinates(coords, viewport, geoWidth, geoHeight);
    const smoothed = smoothPolyline(projected, projected.length > 12 ? 2 : projected.length > 4 ? 1 : 0);
    return { points: smoothed, route, startPoint: null, endPoint: null, isArc: false };
  });

  // Build static map URL. Pass geoWidth*2 so buildMapboxStaticUrl halves back
  // to geoWidth (the geographic size). The @2x image returned is geoWidth*2 pixels.
  const { token, style } = getRendererMapConfig(snapshot);
  const mapUrl = buildMapboxStaticUrl({
    token, style,
    center: viewport.center,
    zoom: viewport.zoom,
    width: geoWidth * 2,
    height: geoHeight * 2,
  });

  // mapWidth/mapHeight are the GEOGRAPHIC coordinate space.
  // The <Img> should be displayed at these CSS dimensions.
  // The @2x image provides 2x pixel density for crispness.
  return { mapUrl, viewport, projectedPlaces, projectedRoutes, mapWidth: geoWidth, mapHeight: geoHeight };
}

export function buildJourneyTimeline(places, routes, journeyFrames, fps) {
  const numPlaces = places.length;
  if (numPlaces === 0) return [];

  const numRoutes = Math.min(routes.length, numPlaces - 1);
  const ARRIVE_BASE_SEC = 2.5;
  const TRAVEL_BASE_SEC = 1.2;

  const totalNeeded = numPlaces * ARRIVE_BASE_SEC + numRoutes * TRAVEL_BASE_SEC;
  const journeySec = journeyFrames / fps;
  const scale = totalNeeded > 0 ? clamp(journeySec / totalNeeded, 0.5, 2.0) : 1;

  const arriveFrames = Math.max(Math.floor(fps * 0.8), Math.floor(ARRIVE_BASE_SEC * scale * fps));
  const travelFrames = numRoutes > 0 ? Math.max(Math.floor(fps * 0.5), Math.floor(TRAVEL_BASE_SEC * scale * fps)) : 0;

  const segments = [];
  let cursor = 0;

  for (let i = 0; i < numPlaces; i++) {
    const af = i === 0 || i === numPlaces - 1
      ? Math.min(arriveFrames + Math.floor(fps * 0.3), journeyFrames - cursor)
      : Math.min(arriveFrames, journeyFrames - cursor);
    if (af <= 0) break;

    segments.push({
      type: 'arrive',
      startFrame: cursor,
      endFrame: cursor + af - 1,
      placeIndex: i,
      routeIndex: -1,
      place: places[i],
      route: null,
    });
    cursor += af;

    if (i < numRoutes && cursor < journeyFrames) {
      const tf = Math.min(travelFrames, journeyFrames - cursor);
      if (tf <= 0) break;
      segments.push({
        type: 'travel',
        startFrame: cursor,
        endFrame: cursor + tf - 1,
        placeIndex: i,
        routeIndex: i,
        place: null,
        route: routes[i],
      });
      cursor += tf;
    }
  }

  return segments;
}

// ---------------------------------------------------------------------------
// Phase 3 helpers: multi-photo, card positioning, transport mode icons
// ---------------------------------------------------------------------------

export function getPlaceImageUrls(place, maxImages = 3) {
  const media = Array.isArray(place?.media) ? place.media : [];
  const images = media.filter(isImageMedia);
  const urls = [];
  for (const img of images) {
    const url = img.url || img.thumbnail_url;
    if (url && urls.length < maxImages) urls.push(url);
  }
  // Fallback to thumbnails if no image-type media found.
  if (urls.length === 0) {
    for (const item of media) {
      const url = item?.thumbnail_url || item?.url;
      if (url && urls.length < maxImages) urls.push(url);
    }
  }
  return urls;
}

export function cardScreenPosition(placeMapX, placeMapY, totalScale, translateX, translateY, frameWidth, frameHeight) {
  // Transform place map-pixel coords through the camera to screen space.
  const screenX = placeMapX * totalScale + translateX;
  const screenY = placeMapY * totalScale + translateY;

  // Default: card appears to the right and above the place dot.
  const CARD_W = 170;
  const CARD_H = 200;
  const OFFSET_X = 20;
  const OFFSET_Y = -CARD_H - 10;

  let cardX = screenX + OFFSET_X;
  let cardY = screenY + OFFSET_Y;

  // Edge avoidance.
  if (cardX + CARD_W > frameWidth * 0.92) cardX = screenX - CARD_W - OFFSET_X;
  if (cardY < frameHeight * 0.1) cardY = screenY + 20;
  if (cardX < frameWidth * 0.04) cardX = frameWidth * 0.04;
  if (cardY + CARD_H > frameHeight * 0.85) cardY = frameHeight * 0.85 - CARD_H;

  return { x: cardX, y: cardY };
}

// Inline SVG path data for transport mode icons (16x16 viewBox).
/**
 * Compute a point along the quadratic bezier arc used for air routes.
 * The arc is the same curve as generated by `airArcPath`.
 */
export function pointOnArc(start, end, progress) {
  if (!start || !end) return null;
  const midX = (start.x + end.x) / 2;
  const midY = (start.y + end.y) / 2;
  const dist = Math.hypot(end.x - start.x, end.y - start.y);
  const controlX = midX;
  const controlY = midY - dist * 0.3;
  const t = clamp(progress, 0, 1);
  const t1 = 1 - t;
  return {
    x: t1 * t1 * start.x + 2 * t1 * t * controlX + t * t * end.x,
    y: t1 * t1 * start.y + 2 * t1 * t * controlY + t * t * end.y,
  };
}

// Inline SVG path data for transport mode icons.
// 24x24 viewBox, top-down orientation, facing RIGHT for heading rotation.
export const TRAVEL_MODE_ICONS = {
  air: 'M 22 12 L 14 5 L 14 9.5 L 5 9.5 L 3 12 L 5 14.5 L 14 14.5 L 14 19 Z',
  car: 'M 3 8 Q 3 6 5 6 L 19 6 Q 21 6 21 8 L 21 16 Q 21 18 19 18 L 5 18 Q 3 18 3 16 Z M 5 5 L 5 3 L 9 3 L 9 5 M 15 5 L 15 3 L 19 3 L 19 5 M 5 19 L 5 21 L 9 21 L 9 19 M 15 19 L 15 21 L 19 21 L 19 19',
  foot: 'M 12 2 a 3 3 0 1 0 0 6 a 3 3 0 1 0 0 -6 M 9 9 L 15 9 L 16 15 L 17 21 L 14 21 L 12 16 L 10 21 L 7 21 L 8 15 Z',
  bike: 'M 5 16 a 4.5 4.5 0 1 1 0 -9 a 4.5 4.5 0 1 1 0 9 M 19 16 a 4.5 4.5 0 1 1 0 -9 a 4.5 4.5 0 1 1 0 9 M 5 11.5 L 12 5 L 19 11.5 M 12 5 L 12 11.5',
  bus: 'M 2 7 L 22 7 Q 23 7 23 8 L 23 16 Q 23 17 22 17 L 2 17 Q 1 17 1 16 L 1 8 Q 1 7 2 7 Z M 1 11 L 23 11 M 4 17 L 4 20 L 7 20 L 7 17 M 17 17 L 17 20 L 20 20 L 20 17',
  train: 'M 2 7 L 20 7 Q 23 7 23 10 L 23 14 Q 23 17 20 17 L 2 17 Q 1 17 1 14 L 1 10 Q 1 7 2 7 Z M 23 12 L 24 10 L 24 14 Z M 4 17 L 3 20 M 8 17 L 7 20 M 16 17 L 15 20 M 20 17 L 19 20',
};

// Icon viewBox size — matches the paths above.
export const ICON_VIEWBOX = 24;
