import { clamp } from './geometry-math.js';

const TILE_SIZE = 512;
const MAX_WEB_MERCATOR_LAT = 85.05112878;

function toFinite(value, fallback = 0) {
  return Number.isFinite(value) ? value : fallback;
}

function normalizeLon(lon) {
  return (lon + 180) / 360;
}

function normalizeLat(lat) {
  const clamped = clamp(lat, -MAX_WEB_MERCATOR_LAT, MAX_WEB_MERCATOR_LAT);
  const sin = Math.sin((clamped * Math.PI) / 180);
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

function projectedPointToLngLat(point, mapContext) {
  const x = toFinite(point?.x, NaN);
  const y = toFinite(point?.y, NaN);
  const viewport = mapContext?.viewport || null;
  const mapWidth = toFinite(mapContext?.mapWidth, NaN);
  const mapHeight = toFinite(mapContext?.mapHeight, NaN);
  if (!Number.isFinite(x) || !Number.isFinite(y) || !viewport || !Number.isFinite(viewport.zoom)) {
    return null;
  }
  if (!Number.isFinite(viewport.center?.lng) || !Number.isFinite(viewport.center?.lat)) {
    return null;
  }
  if (!Number.isFinite(mapWidth) || !Number.isFinite(mapHeight) || mapWidth <= 0 || mapHeight <= 0) {
    return null;
  }

  const zoom = viewport.zoom;
  const centerWorld = lngLatToWorld(viewport.center.lng, viewport.center.lat, zoom);
  const worldX = x + centerWorld.x - mapWidth / 2;
  const worldY = y + centerWorld.y - mapHeight / 2;
  return worldToLngLat(worldX, worldY, zoom);
}

function nativeProjectPoint(map, point, mapContext) {
  if (!map || typeof map.project !== 'function') return null;
  const lngLat = projectedPointToLngLat(point, mapContext);
  if (!lngLat) return null;
  const projected = map.project([lngLat.lng, lngLat.lat]);
  const x = toFinite(projected?.x, NaN);
  const y = toFinite(projected?.y, NaN);
  if (!Number.isFinite(x) || !Number.isFinite(y)) return null;
  return { x, y };
}

function projectedCameraToNative(camera, mapContext) {
  if (!camera || typeof camera !== 'object') return null;
  if (
    Number.isFinite(camera.center?.lng)
    && Number.isFinite(camera.center?.lat)
    && Number.isFinite(camera.zoom)
  ) {
    return {
      center: [camera.center.lng, camera.center.lat],
      zoom: camera.zoom,
      bearing: toFinite(camera.bearing, 0),
      pitch: toFinite(camera.pitch, 0),
      animate: false,
    };
  }

  const centerLngLat = projectedPointToLngLat(camera.center, mapContext);
  const baseZoom = toFinite(mapContext?.viewport?.zoom, NaN);
  if (!centerLngLat || !Number.isFinite(baseZoom)) {
    return null;
  }

  const scale = Math.max(0.0001, toFinite(camera.scale, 1));
  return {
    center: [centerLngLat.lng, centerLngLat.lat],
    zoom: baseZoom + Math.log2(scale),
    bearing: toFinite(camera.bearing, 0),
    pitch: toFinite(camera.pitch, 0),
    animate: false,
  };
}

function projectCameraToViewport({ camera, markerState, mapContext, frameSize }) {
  const mapWidth = toFinite(mapContext?.mapWidth, toFinite(frameSize?.width, 720));
  const mapHeight = toFinite(mapContext?.mapHeight, toFinite(frameSize?.height, 1280));
  const frameWidth = toFinite(frameSize?.width, 720);
  const frameHeight = toFinite(frameSize?.height, 1280);

  const cameraScale = Math.max(0.0001, toFinite(camera?.scale, 1));
  const fallbackFocusX = markerState?.mapX ?? mapWidth / 2;
  const fallbackFocusY = markerState?.mapY ?? mapHeight / 2;
  const focusX = toFinite(camera?.center?.x, toFinite(fallbackFocusX, mapWidth / 2));
  const focusY = toFinite(camera?.center?.y, toFinite(fallbackFocusY, mapHeight / 2));

  const baseScale = Math.max(frameWidth / Math.max(1, mapWidth), frameHeight / Math.max(1, mapHeight));
  const totalScale = baseScale * cameraScale;
  const translateX = frameWidth / 2 - focusX * totalScale;
  const translateY = frameHeight / 2 - focusY * totalScale;

  const scaledMapW = mapWidth * totalScale;
  const scaledMapH = mapHeight * totalScale;
  const clampedTX = clamp(translateX, frameWidth - scaledMapW, 0);
  const clampedTY = clamp(translateY, frameHeight - scaledMapH, 0);

  return {
    mapWidth,
    mapHeight,
    frameWidth,
    frameHeight,
    focusX,
    focusY,
    cameraScale,
    totalScale,
    translateX: clampedTX,
    translateY: clampedTY,
  };
}

function projectNativeOverlayState({ map, mapContext, markerState }) {
  if (!map || map.mode !== 'native_gl') return null;
  const projectedRoutes = Array.isArray(mapContext?.projectedRoutes) ? mapContext.projectedRoutes : [];
  const projectedPlaces = Array.isArray(mapContext?.projectedPlaces) ? mapContext.projectedPlaces : [];

  const routes = projectedRoutes.map((route) => {
    const points = Array.isArray(route?.points)
      ? route.points.map((point) => nativeProjectPoint(map, point, mapContext)).filter(Boolean)
      : [];
    const startPoint = route?.startPoint
      ? nativeProjectPoint(map, route.startPoint, mapContext)
      : null;
    const endPoint = route?.endPoint
      ? nativeProjectPoint(map, route.endPoint, mapContext)
      : null;
    return {
      ...route,
      points,
      startPoint,
      endPoint,
    };
  });

  const places = projectedPlaces.map((place) => {
    const projected = nativeProjectPoint(map, place, mapContext);
    if (!projected) return null;
    return {
      ...place,
      x: projected.x,
      y: projected.y,
    };
  }).filter(Boolean);

  const marker = markerState
    ? nativeProjectPoint(map, { x: markerState.mapX, y: markerState.mapY }, mapContext)
    : null;

  return {
    routes,
    places,
    marker,
  };
}

export function applyCameraState(map, camera, context = {}) {
  if (!map || typeof map !== 'object') return camera || null;

  const nativeCamera = projectedCameraToNative(camera, context.mapContext);

  if (map.mode === 'native_gl' && typeof map.jumpTo === 'function' && nativeCamera) {
    map.jumpTo(nativeCamera);
  } else if (typeof map.jumpTo === 'function' && camera) {
    // Static compatibility map accepts projected camera fields.
    map.jumpTo({
      center: camera.center || null,
      zoom: toFinite(camera.scale, 1),
      bearing: toFinite(camera.bearing, 0),
      pitch: toFinite(camera.pitch, 0),
      animate: false,
    });
  }

  if (map.__state && typeof map.__state === 'object') {
    map.__state.camera = camera || null;
  }
  return camera || null;
}

export function upsertRouteLayerState(map, routeState) {
  const nextRouteState = routeState && typeof routeState === 'object' ? routeState : {};
  if (map?.__state && typeof map.__state === 'object') {
    map.__state.routeState = nextRouteState;
  }
  return nextRouteState;
}

export function upsertMarkerLayerState(map, markerState) {
  const nextMarkerState = markerState && typeof markerState === 'object' ? markerState : null;
  if (map?.__state && typeof map.__state === 'object') {
    map.__state.markerState = nextMarkerState;
  }
  return nextMarkerState;
}

export function applyFrameToMap(map, frameState, context = {}) {
  const safeState = frameState && typeof frameState === 'object' ? frameState : {};
  const mapContext = context.mapContext || {};
  const camera = applyCameraState(map, safeState.camera || null, context);
  const routeProgressByIndex = upsertRouteLayerState(map, safeState.routeProgressByIndex || {});
  const markerState = upsertMarkerLayerState(map, safeState.markerState || null);
  const nativeOverlay = projectNativeOverlayState({
    map,
    mapContext,
    markerState,
  });

  const viewport = projectCameraToViewport({
    camera,
    markerState,
    mapContext,
    frameSize: context.frameSize || {},
  });

  return {
    camera,
    routeProgressByIndex,
    markerState,
    viewport,
    nativeOverlay,
  };
}
