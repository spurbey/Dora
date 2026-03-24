import { clamp, lerp, lerpAngleDegShortest } from './geometry-math.js';
import { CAMERA_LIMITS, EASING } from './quality-constants.js';
import { headingAtS, pointAtS } from './route-animator.js';

function toFinite(value, fallback = 0) {
  return Number.isFinite(value) ? value : fallback;
}

function segmentPreset(segment) {
  if (!segment) {
    return {
      scaleStart: 3.2,
      scaleMid: 3.2,
      scaleEnd: 3.2,
      pitchStart: 0,
      pitchMid: 0,
      pitchEnd: 0,
      lookAheadStart: 0,
      lookAheadMid: 0,
      lookAheadEnd: 1,
    };
  }

  if (segment.type === 'arrive') {
    return {
      scaleStart: 4.2,
      scaleMid: 4.9,
      scaleEnd: 5.2,
      pitchStart: 16,
      pitchMid: 19,
      pitchEnd: 17,
      lookAheadStart: 0,
      lookAheadMid: 0,
      lookAheadEnd: 0,
    };
  }

  const mode = String(segment.route?.transport_mode || '').toLowerCase();
  if (mode === 'air') {
    return {
      scaleStart: 2.1,
      scaleMid: 1.85,
      scaleEnd: 2.25,
      pitchStart: 44,
      pitchMid: 52,
      pitchEnd: 40,
      lookAheadStart: 0.08,
      lookAheadMid: 0.58,
      lookAheadEnd: 0.9,
    };
  }

  return {
    scaleStart: 4.8,
    scaleMid: 4.2,
    scaleEnd: 4.6,
    pitchStart: 24,
    pitchMid: 30,
    pitchEnd: 22,
    lookAheadStart: 0.12,
    lookAheadMid: 0.62,
    lookAheadEnd: 0.88,
  };
}

function keyframe(frame, center, scale, bearing, pitch, easing = EASING.camera) {
  return {
    frame: Math.max(0, Math.floor(frame)),
    center: {
      x: toFinite(center?.x),
      y: toFinite(center?.y),
    },
    scale: toFinite(scale, 1),
    bearing: toFinite(bearing, 0),
    pitch: toFinite(pitch, 0),
    easing,
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

function boundBearingByFrameSpan(fromBearing, toBearing, frameSpan) {
  const span = Math.max(1, Math.floor(toFinite(frameSpan, 1)));
  const maxDelta = CAMERA_LIMITS.maxBearingDeltaPerFrame * span;
  return fromBearing + clamp(
    shortestAngleDeltaDeg(fromBearing, toBearing),
    -maxDelta,
    maxDelta,
  );
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
    easing: typeof c.easing === 'string' ? c.easing : EASING.camera,
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
  let lastScale = 3.2;
  let lastCenter = placeCenter(projectedPlaces, 0) || {
    x: Number.isFinite(frameSize.width) ? frameSize.width / 2 : 0,
    y: Number.isFinite(frameSize.height) ? frameSize.height / 2 : 0,
  };

  for (const segment of segments) {
    const preset = segmentPreset(segment);

    if (segment.type === 'arrive') {
      const center = placeCenter(projectedPlaces, segment.placeIndex) || lastCenter;
      const frameSpan = Math.max(1, segment.endFrame - segment.startFrame);
      const settleFrame = Math.min(
        segment.endFrame,
        segment.startFrame + Math.max(1, Math.floor(frameSpan * 0.38)),
      );

      const settleBearing = boundBearingByFrameSpan(
        lastBearing,
        lastBearing * 0.42,
        settleFrame - segment.startFrame,
      );
      const endBearing = boundBearingByFrameSpan(
        settleBearing,
        settleBearing * 0.62,
        segment.endFrame - settleFrame,
      );

      const startScale = lerp(lastScale, preset.scaleStart, 0.45);
      out.push(keyframe(
        segment.startFrame,
        {
          x: lerp(lastCenter.x, center.x, 0.55),
          y: lerp(lastCenter.y, center.y, 0.55),
        },
        startScale,
        lastBearing,
        preset.pitchStart,
        'easeOutQuad',
      ));
      out.push(keyframe(
        settleFrame,
        {
          x: lerp(lastCenter.x, center.x, 0.85),
          y: lerp(lastCenter.y, center.y, 0.85),
        },
        preset.scaleMid,
        settleBearing,
        preset.pitchMid,
        'easeInOutSine',
      ));
      out.push(keyframe(
        segment.endFrame,
        center,
        preset.scaleEnd,
        endBearing,
        preset.pitchEnd,
        'easeInOutSine',
      ));

      lastBearing = endBearing;
      lastScale = preset.scaleEnd;
      lastCenter = center;
      continue;
    }

    if (segment.type === 'travel') {
      const curve = routeCurves[segment.routeIndex];
      const startPlace = placeCenter(projectedPlaces, segment.placeIndex);
      const endPlace = placeCenter(projectedPlaces, segment.placeIndex + 1);
      const start = pointAtS(curve, preset.lookAheadStart)
        || pointAtS(curve, 0)
        || startPlace
        || lastCenter
        || endPlace;
      const mid = pointAtS(curve, preset.lookAheadMid)
        || pointAtS(curve, 0.5)
        || endPlace
        || start;
      const end = pointAtS(curve, preset.lookAheadEnd)
        || pointAtS(curve, 1)
        || endPlace
        || mid
        || start;
      if (!start || !mid || !end) continue;

      const rawStartBearing = headingAtS(curve, preset.lookAheadStart + 0.03);
      const rawMidBearing = headingAtS(curve, preset.lookAheadMid);
      const rawEndBearing = headingAtS(curve, Math.min(0.98, preset.lookAheadEnd + 0.04));

      const startBearing = Number.isFinite(rawStartBearing)
        ? rawStartBearing
        : fallbackBearing(start, end, lastBearing);

      const frameSpan = Math.max(1, segment.endFrame - segment.startFrame);
      const midFrame = Math.min(
        segment.endFrame,
        segment.startFrame + Math.max(1, Math.floor(frameSpan * 0.52)),
      );

      const midBearingRaw = Number.isFinite(rawMidBearing)
        ? rawMidBearing
        : fallbackBearing(start, mid, startBearing);
      const midBearing = boundBearingByFrameSpan(
        startBearing,
        midBearingRaw,
        midFrame - segment.startFrame,
      );

      const endBearingRaw = Number.isFinite(rawEndBearing)
        ? rawEndBearing
        : fallbackBearing(mid, end, midBearing);
      const endBearing = boundBearingByFrameSpan(
        midBearing,
        endBearingRaw,
        segment.endFrame - midFrame,
      );

      out.push(keyframe(
        segment.startFrame,
        start,
        preset.scaleStart,
        startBearing,
        preset.pitchStart,
        'easeInOutCubic',
      ));
      out.push(keyframe(
        midFrame,
        mid,
        preset.scaleMid,
        midBearing,
        preset.pitchMid,
        'easeInOutSine',
      ));
      out.push(keyframe(
        segment.endFrame,
        end,
        preset.scaleEnd,
        endBearing,
        preset.pitchEnd,
        'easeOutQuad',
      ));

      lastBearing = endBearing;
      lastScale = preset.scaleEnd;
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
  const easingName = typeof next.easing === 'string' ? next.easing : EASING.camera;
  const eased = applyEasing(easingName, t);
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
    easing: easingName,
  });
}

export function cameraStateAtFrame(frame, keyframes) {
  return clampCameraState(interpolateCamera(frame, keyframes));
}

export function clampCameraState(camera) {
  return clampByLimits(camera);
}
