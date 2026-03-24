import { clamp } from './geometry-math.js';
import { OVERLAY_SAFE_AREA } from './quality-constants.js';

function safeRect(rect) {
  return {
    x: Number.isFinite(rect?.x) ? rect.x : 0,
    y: Number.isFinite(rect?.y) ? rect.y : 0,
    width: Number.isFinite(rect?.width) ? rect.width : 0,
    height: Number.isFinite(rect?.height) ? rect.height : 0,
  };
}

function pointInRect(point, rect) {
  return point.x >= rect.x
    && point.y >= rect.y
    && point.x <= rect.x + rect.width
    && point.y <= rect.y + rect.height;
}

function easeInOutSine(p) {
  const t = clamp(p, 0, 1);
  return 0.5 * (1 - Math.cos(Math.PI * t));
}

export function scoreCardCandidate(input) {
  const rect = safeRect(input?.rect);
  const viewport = safeRect(input?.viewport);
  const anchor = input?.anchor || { x: 0, y: 0 };
  const routePolyline = Array.isArray(input?.routePolyline) ? input.routePolyline : [];

  let score = 100;

  const overflowLeft = Math.max(0, viewport.x - rect.x);
  const overflowTop = Math.max(0, viewport.y - rect.y);
  const overflowRight = Math.max(0, rect.x + rect.width - (viewport.x + viewport.width));
  const overflowBottom = Math.max(0, rect.y + rect.height - (viewport.y + viewport.height));
  score -= (overflowLeft + overflowTop + overflowRight + overflowBottom) * 5;

  if (pointInRect(anchor, rect)) score -= 25;

  let routeHits = 0;
  for (const point of routePolyline) {
    if (pointInRect(point, rect)) routeHits += 1;
  }
  score -= routeHits * 2;

  return score;
}

export function resolveCardPlacement(input) {
  const anchor = input?.anchor || { x: 0, y: 0 };
  const card = input?.cardSize || { width: 170, height: 200 };
  const viewport = input?.viewport || { width: 720, height: 1280 };
  const routePolyline = Array.isArray(input?.routePolyline) ? input.routePolyline : [];

  const safeXMin = viewport.width * OVERLAY_SAFE_AREA.leftPct;
  const safeXMax = viewport.width * OVERLAY_SAFE_AREA.rightPct;
  const safeYMin = viewport.height * OVERLAY_SAFE_AREA.topPct;
  const safeYMax = viewport.height * OVERLAY_SAFE_AREA.bottomPct;

  const offsetX = 20;
  const offsetY = 10;

  const candidates = [
    { quadrant: 'NE', x: anchor.x + offsetX, y: anchor.y - card.height - offsetY },
    { quadrant: 'NW', x: anchor.x - card.width - offsetX, y: anchor.y - card.height - offsetY },
    { quadrant: 'SE', x: anchor.x + offsetX, y: anchor.y + 20 },
    { quadrant: 'SW', x: anchor.x - card.width - offsetX, y: anchor.y + 20 },
  ];

  let best = null;
  let bestScore = -Infinity;
  for (const candidate of candidates) {
    const rect = {
      x: clamp(candidate.x, safeXMin, safeXMax - card.width),
      y: clamp(candidate.y, safeYMin, safeYMax - card.height),
      width: card.width,
      height: card.height,
    };
    const score = scoreCardCandidate({
      rect,
      viewport: { x: safeXMin, y: safeYMin, width: safeXMax - safeXMin, height: safeYMax - safeYMin },
      routePolyline,
      anchor,
    });
    if (score > bestScore) {
      bestScore = score;
      best = { x: rect.x, y: rect.y, quadrant: candidate.quadrant };
    }
  }
  return best || { x: anchor.x, y: anchor.y, quadrant: 'NE' };
}

export function buildOverlayTracks(input) {
  const segments = Array.isArray(input?.segments) ? input.segments : [];
  const places = Array.isArray(input?.places) ? input.places : [];
  const fps = Number.isFinite(input?.fps) && input.fps > 0 ? input.fps : 30;
  const frameSize = input?.frameSize || { width: 720, height: 1280 };

  const labels = [];

  for (const segment of segments) {
    if (segment.type !== 'arrive') continue;
    const place = places[segment.placeIndex] || segment.place || null;
    labels.push({
      startFrame: segment.startFrame,
      endFrame: segment.endFrame,
      placeIndex: segment.placeIndex,
      place,
      fadeInFrames: Math.max(1, Math.floor(fps * 0.35)),
      fadeOutFrames: Math.max(1, Math.floor(fps * 0.25)),
    });
  }

  return {
    frameSize,
    labels,
  };
}

export function overlayStateAtFrame(tracks, frame) {
  const safeFrame = Math.max(0, Math.floor(Number.isFinite(frame) ? frame : 0));
  const labels = Array.isArray(tracks?.labels) ? tracks.labels : [];
  const activeLabel = labels.find((label) => safeFrame >= label.startFrame && safeFrame <= label.endFrame) || null;

  if (!activeLabel) {
    return {
      label: { place: null, opacity: 0 },
      activeArrivalSegment: null,
      activePlaceIndex: -1,
    };
  }

  const local = safeFrame - activeLabel.startFrame;
  const segFrames = Math.max(1, activeLabel.endFrame - activeLabel.startFrame + 1);
  const fadeInEnd = Math.min(activeLabel.fadeInFrames, segFrames - 1);
  const fadeOutStart = Math.max(fadeInEnd, segFrames - activeLabel.fadeOutFrames);

  let opacity;
  if (local <= fadeInEnd) {
    opacity = easeInOutSine(local / Math.max(1, fadeInEnd));
  } else if (local >= fadeOutStart) {
    const p = (local - fadeOutStart) / Math.max(1, segFrames - 1 - fadeOutStart);
    opacity = 1 - easeInOutSine(p);
  } else {
    opacity = 1;
  }

  return {
    label: {
      place: activeLabel.place,
      opacity: clamp(opacity, 0, 1),
    },
    activeArrivalSegment: {
      type: 'arrive',
      startFrame: activeLabel.startFrame,
      endFrame: activeLabel.endFrame,
      placeIndex: activeLabel.placeIndex,
      place: activeLabel.place,
    },
    activePlaceIndex: activeLabel.placeIndex,
  };
}
