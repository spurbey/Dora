import { clamp } from './geometry-math.js';

function toFinite(value, fallback = 0) {
  return Number.isFinite(value) ? value : fallback;
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

export function applyCameraState(map, camera) {
  if (!map || typeof map !== 'object') return camera || null;

  if (
    map
    && typeof map.jumpTo === 'function'
    && camera
    && Number.isFinite(camera.center?.lng)
    && Number.isFinite(camera.center?.lat)
    && Number.isFinite(camera.zoom)
  ) {
    map.jumpTo({
      center: [camera.center.lng, camera.center.lat],
      zoom: camera.zoom,
      bearing: toFinite(camera.bearing, 0),
      pitch: toFinite(camera.pitch, 0),
      animate: false,
    });
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
  const camera = applyCameraState(map, safeState.camera || null);
  const routeProgressByIndex = upsertRouteLayerState(map, safeState.routeProgressByIndex || {});
  const markerState = upsertMarkerLayerState(map, safeState.markerState || null);

  const viewport = projectCameraToViewport({
    camera,
    markerState,
    mapContext: context.mapContext || {},
    frameSize: context.frameSize || {},
  });

  return {
    camera,
    routeProgressByIndex,
    markerState,
    viewport,
  };
}

