import { clamp, lerp, lerpAngleDegShortest } from './geometry-math.js';
import { CAMERA_LIMITS, EASING } from './quality-constants.js';
import { headingAtS, pointAtS } from './route-animator.js';

function toFinite(value, fallback = 0) {
  return Number.isFinite(value) ? value : fallback;
}

function segmentPreset(segment) {
  if (!segment) return { scale: 1, pitch: 0 };
  if (segment.type === 'arrive') return { scale: 5.0, pitch: 18 };
  const mode = (segment.route?.transport_mode || '').toLowerCase();
  if (mode === 'air') return { scale: 2.0, pitch: 45 };
  return { scale: 4.0, pitch: 28 };
}

function keyframe(frame, center, scale, bearing, pitch) {
  return {
    frame: Math.max(0, Math.floor(frame)),
    center: {
      x: toFinite(center?.x),
      y: toFinite(center?.y),
    },
    scale: toFinite(scale, 1),
    bearing: toFinite(bearing, 0),
    pitch: toFinite(pitch, 0),
  };
}

function placeCenter(projectedPlaces, index) {
  const place = projectedPlaces[index];
  if (!place) return null;
  const x = Number(place.x);
  const y = Number(place.y);
  if (!Number.isFinite(x) || !Number.isFinite(y)) return null;
  return { x, y };
}

function fallbackBearing(start, end, previousBearing = 0) {
  if (!start || !end) return toFinite(previousBearing, 0);
  const dx = end.x - start.x;
  const dy = end.y - start.y;
  if (Math.abs(dx) < 1e-6 && Math.abs(dy) < 1e-6) {
    return toFinite(previousBearing, 0);
  }
  return (Math.atan2(dy, dx) * 180) / Math.PI;
}

function shortestAngleDeltaDeg(fromDeg, toDeg) {
  return ((toDeg - fromDeg + 540) % 360) - 180;
}

function easeInOutSine(t) {
  return 0.5 * (1 - Math.cos(Math.PI * clamp(t, 0, 1)));
}

function easeInOutCubic(t) {
  const p = clamp(t, 0, 1);
  if (p < 0.5) return 4 * p * p * p;
  return 1 - Math.pow(-2 * p + 2, 3) / 2;
}

function easeOutQuad(t) {
  const p = clamp(t, 0, 1);
  return 1 - (1 - p) * (1 - p);
}

function applyEasing(name, t) {
  switch (name) {
    case 'easeInOutSine':
      return easeInOutSine(t);
    case 'easeInOutCubic':
      return easeInOutCubic(t);
    case 'easeOutQuad':
      return easeOutQuad(t);
    default:
      return clamp(t, 0, 1);
  }
}

function clampByLimits(camera) {
  const c = camera || {};
  return {
    ...c,
    scale: clamp(toFinite(c.scale, 1), CAMERA_LIMITS.minZoom, CAMERA_LIMITS.maxZoom),
    pitch: clamp(toFinite(c.pitch, 0), CAMERA_LIMITS.minPitch, CAMERA_LIMITS.maxPitch),
    bearing: toFinite(c.bearing, 0),
    center: {
      x: toFinite(c.center?.x),
      y: toFinite(c.center?.y),
    },
  };
}

export function buildCameraKeyframes(input) {
  const segments = Array.isArray(input?.segments) ? input.segments : [];
  const routeCurves = Array.isArray(input?.routeCurves) ? input.routeCurves : [];
  const projectedPlaces = Array.isArray(input?.projectedPlaces) ? input.projectedPlaces : [];
  const frameSize = input?.frameSize || { width: 720, height: 1280 };
  if (segments.length === 0) return [];

  const out = [];
  let lastBearing = 0;
  let lastCenter = placeCenter(projectedPlaces, 0) || {
    x: Number.isFinite(frameSize.width) ? frameSize.width / 2 : 0,
    y: Number.isFinite(frameSize.height) ? frameSize.height / 2 : 0,
  };

  for (const segment of segments) {
    const preset = segmentPreset(segment);
    if (segment.type === 'arrive') {
      const center = placeCenter(projectedPlaces, segment.placeIndex) || lastCenter;
      out.push(keyframe(segment.startFrame, center, preset.scale, lastBearing, preset.pitch));
      out.push(keyframe(segment.endFrame, center, preset.scale, lastBearing, preset.pitch));
      lastCenter = center;
      continue;
    }

    if (segment.type === 'travel') {
      const curve = routeCurves[segment.routeIndex];
      const startPlace = placeCenter(projectedPlaces, segment.placeIndex);
      const endPlace = placeCenter(projectedPlaces, segment.placeIndex + 1);

      const start = pointAtS(curve, 0) || startPlace || lastCenter || endPlace;
      const end = pointAtS(curve, 1) || endPlace || start || lastCenter;
      if (!start || !end) {
        continue;
      }

      const rawStartBearing = headingAtS(curve, 0.02);
      const rawEndBearing = headingAtS(curve, 0.98);
      const startBearing = Number.isFinite(rawStartBearing)
        ? rawStartBearing
        : fallbackBearing(start, end, lastBearing);
      const endBearing = Number.isFinite(rawEndBearing)
        ? rawEndBearing
        : fallbackBearing(start, end, startBearing);
      const frameSpan = Math.max(1, segment.endFrame - segment.startFrame);
      const maxBearingDelta = CAMERA_LIMITS.maxBearingDeltaPerFrame * frameSpan;
      const limitedEndBearing = startBearing + clamp(
        shortestAngleDeltaDeg(startBearing, endBearing),
        -maxBearingDelta,
        maxBearingDelta,
      );
      out.push(keyframe(segment.startFrame, start, preset.scale, startBearing, preset.pitch));
      out.push(keyframe(segment.endFrame, end, preset.scale, limitedEndBearing, preset.pitch));
      lastBearing = limitedEndBearing;
      lastCenter = end;
    }
  }

  const dedup = new Map();
  for (const kf of out) {
    dedup.set(kf.frame, kf);
  }
  return [...dedup.values()]
    .sort((a, b) => a.frame - b.frame)
    .map(clampByLimits);
}

export function interpolateCamera(frame, keyframes) {
  const safeFrame = Math.max(0, Math.floor(toFinite(frame)));
  const keys = Array.isArray(keyframes) ? keyframes : [];
  if (keys.length === 0) {
    return clampByLimits(keyframe(safeFrame, { x: 0, y: 0 }, 1, 0, 0));
  }
  if (keys.length === 1) return clampByLimits(keys[0]);

  let prev = keys[0];
  let next = keys[keys.length - 1];
  for (let i = 0; i < keys.length; i++) {
    if (keys[i].frame <= safeFrame) prev = keys[i];
    if (keys[i].frame >= safeFrame) {
      next = keys[i];
      break;
    }
  }

  if (prev.frame === next.frame) return clampByLimits(prev);

  const t = clamp((safeFrame - prev.frame) / Math.max(1, next.frame - prev.frame), 0, 1);
  const eased = applyEasing(EASING.camera, t);
  const elapsedFrames = Math.max(0, safeFrame - prev.frame);
  const maxBearingDelta = CAMERA_LIMITS.maxBearingDeltaPerFrame * elapsedFrames;
  const rawBearing = lerpAngleDegShortest(prev.bearing, next.bearing, eased);
  const boundedBearing = prev.bearing + clamp(
    shortestAngleDeltaDeg(prev.bearing, rawBearing),
    -maxBearingDelta,
    maxBearingDelta,
  );

  return clampByLimits({
    frame: safeFrame,
    center: {
      x: lerp(prev.center.x, next.center.x, eased),
      y: lerp(prev.center.y, next.center.y, eased),
    },
    scale: lerp(prev.scale, next.scale, eased),
    bearing: boundedBearing,
    pitch: lerp(prev.pitch, next.pitch, eased),
  });
}

export function cameraStateAtFrame(frame, keyframes) {
  return clampCameraState(interpolateCamera(frame, keyframes));
}

export function clampCameraState(camera) {
  return clampByLimits(camera);
}
