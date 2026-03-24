import { clamp } from './geometry-math.js';
import { EASING, OVERLAY_SAFE_AREA } from './quality-constants.js';

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

function easeOutQuad(p) {
  const t = clamp(p, 0, 1);
  return 1 - (1 - t) * (1 - t);
}

function easeOutCubic(p) {
  const t = clamp(p, 0, 1);
  return 1 - Math.pow(1 - t, 3);
}

function applyEasing(name, p) {
  switch (name) {
    case 'easeOutQuad':
      return easeOutQuad(p);
    case 'easeOutCubic':
      return easeOutCubic(p);
    case 'easeInOutSine':
      return easeInOutSine(p);
    default:
      return clamp(p, 0, 1);
  }
}

function rectOverlapArea(a, b) {
  const x1 = Math.max(a.x, b.x);
  const y1 = Math.max(a.y, b.y);
  const x2 = Math.min(a.x + a.width, b.x + b.width);
  const y2 = Math.min(a.y + a.height, b.y + b.height);
  const w = Math.max(0, x2 - x1);
  const h = Math.max(0, y2 - y1);
  return w * h;
}

function pointToRectDistance(point, rect) {
  const dx = Math.max(rect.x - point.x, 0, point.x - (rect.x + rect.width));
  const dy = Math.max(rect.y - point.y, 0, point.y - (rect.y + rect.height));
  return Math.hypot(dx, dy);
}

function routeOverlapScore(routePolyline, rect) {
  let hits = 0;
  let minDistance = Number.POSITIVE_INFINITY;
  for (const point of routePolyline) {
    if (!point || !Number.isFinite(point.x) || !Number.isFinite(point.y)) continue;
    if (pointInRect(point, rect)) hits += 1;
    const d = pointToRectDistance(point, rect);
    if (d < minDistance) minDistance = d;
  }
  return {
    hits,
    minDistance: Number.isFinite(minDistance) ? minDistance : 9999,
  };
}

export function scoreCardCandidate(input) {
  const rect = safeRect(input?.rect);
  const viewport = safeRect(input?.viewport);
  const anchor = input?.anchor || { x: 0, y: 0 };
  const routePolyline = Array.isArray(input?.routePolyline) ? input.routePolyline : [];
  const candidate = input?.candidate || {};
  const ring = Number.isFinite(candidate.ring) ? candidate.ring : 1;

  let score = 1000;

  const overflowLeft = Math.max(0, viewport.x - rect.x);
  const overflowTop = Math.max(0, viewport.y - rect.y);
  const overflowRight = Math.max(0, rect.x + rect.width - (viewport.x + viewport.width));
  const overflowBottom = Math.max(0, rect.y + rect.height - (viewport.y + viewport.height));
  score -= (overflowLeft + overflowTop + overflowRight + overflowBottom) * 14;

  if (pointInRect(anchor, rect)) score -= 260;

  const route = routeOverlapScore(routePolyline, rect);
  score -= route.hits * 36;
  if (route.minDistance < 42) {
    score -= (42 - route.minDistance) * 3.5;
  }

  const centerRect = {
    x: viewport.x + viewport.width * 0.2,
    y: viewport.y + viewport.height * 0.24,
    width: viewport.width * 0.6,
    height: viewport.height * 0.46,
  };
  score -= rectOverlapArea(rect, centerRect) * 0.01;

  const anchorDistance = pointToRectDistance(anchor, rect);
  score -= anchorDistance * 0.35;

  // Prefer tighter rings when score is otherwise similar to reduce visual wandering.
  score -= (ring - 1) * 12;

  if (candidate.quadrant === 'N' || candidate.quadrant === 'NE' || candidate.quadrant === 'NW') {
    score += 14;
  }
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

  const offsetX = 22;
  const offsetY = 12;

  const ringMult = [1, 1.45];
  const candidates = [];
  for (const ring of ringMult) {
    const dx = offsetX * ring;
    const dy = offsetY * ring;
    candidates.push(
      { ring, quadrant: 'NE', x: anchor.x + dx, y: anchor.y - card.height - dy },
      { ring, quadrant: 'NW', x: anchor.x - card.width - dx, y: anchor.y - card.height - dy },
      { ring, quadrant: 'SE', x: anchor.x + dx, y: anchor.y + 18 + dy * 0.5 },
      { ring, quadrant: 'SW', x: anchor.x - card.width - dx, y: anchor.y + 18 + dy * 0.5 },
      { ring, quadrant: 'N', x: anchor.x - card.width / 2, y: anchor.y - card.height - dy * 1.1 },
      { ring, quadrant: 'S', x: anchor.x - card.width / 2, y: anchor.y + 20 + dy * 0.6 },
      { ring, quadrant: 'E', x: anchor.x + dx * 1.15, y: anchor.y - card.height / 2 },
      { ring, quadrant: 'W', x: anchor.x - card.width - dx * 1.15, y: anchor.y - card.height / 2 },
    );
  }

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
      candidate,
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
    opacity = applyEasing(EASING.label, local / Math.max(1, fadeInEnd));
  } else if (local >= fadeOutStart) {
    const p = (local - fadeOutStart) / Math.max(1, segFrames - 1 - fadeOutStart);
    opacity = 1 - applyEasing(EASING.opacity, p);
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
