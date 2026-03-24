import { normalizeSnapshot } from './remotion/gl/normalize-snapshot.js';
import { compileTimelineSegments } from './remotion/gl/timeline-compiler.js';

const INTRO_SEC = 1.5;
const OUTRO_SEC = 1.0;
const DEFAULT_THUMBNAIL_PROGRESS = 0.45;

function safeInt(value, fallback = 0) {
  const n = Number(value);
  if (!Number.isFinite(n)) return fallback;
  return Math.max(0, Math.floor(n));
}

function clampFrame(frame, totalFrames) {
  const maxFrame = Math.max(0, safeInt(totalFrames) - 1);
  return Math.min(maxFrame, Math.max(0, safeInt(frame)));
}

function defaultFrame(totalFrames) {
  return clampFrame(Math.floor(Math.max(0, totalFrames) * DEFAULT_THUMBNAIL_PROGRESS), totalFrames);
}

function segmentSpan(segment) {
  if (!segment) return 0;
  return Math.max(1, safeInt(segment.endFrame) - safeInt(segment.startFrame) + 1);
}

function pickFrameWithinSegment(segment, ratio) {
  const span = segmentSpan(segment);
  const start = safeInt(segment?.startFrame);
  const offset = Math.floor((span - 1) * ratio);
  return start + offset;
}

function scoreSegment(segment, segments, fps) {
  const span = segmentSpan(segment);
  const safeFps = Math.max(1, safeInt(fps, 30));
  if (segment?.type === 'travel') {
    const mode = (segment.route?.transport_mode || '').toLowerCase();
    const airBoost = mode === 'air' ? safeFps * 0.35 : 0;
    return span + safeFps * 0.25 + airBoost;
  }

  if (segment?.type === 'arrive') {
    const isFirst = segment.placeIndex === 0;
    const lastArrive = [...segments].reverse().find((item) => item.type === 'arrive');
    const isLast = lastArrive && lastArrive.startFrame === segment.startFrame && lastArrive.endFrame === segment.endFrame;
    const firstPenalty = isFirst ? safeFps * 0.35 : 0;
    const lastBoost = isLast ? safeFps * 0.55 : 0;
    return span + lastBoost - firstPenalty;
  }

  return span;
}

function pickBestSegment(segments, fps) {
  let best = null;
  let bestScore = -Infinity;
  for (const segment of segments) {
    const score = scoreSegment(segment, segments, fps);
    if (score > bestScore) {
      best = segment;
      bestScore = score;
    }
  }
  return best;
}

export function selectThumbnailFrame({
  template,
  snapshot,
  durationInFrames,
  durationSec,
  fps,
}) {
  const safeFps = Math.max(1, safeInt(fps, 30));
  const explicitDurationFrames = safeInt(durationInFrames);
  const derivedDurationFrames = safeInt(durationSec) * safeFps;
  const totalFrames = Math.max(explicitDurationFrames, derivedDurationFrames);
  if (totalFrames <= 0) return 0;

  if (template !== 'cinematic') {
    return defaultFrame(totalFrames);
  }

  try {
    const normalized = normalizeSnapshot(snapshot || {});
    const places = Array.isArray(normalized.places) ? normalized.places : [];
    const routes = Array.isArray(normalized.routes) ? normalized.routes : [];
    if (places.length === 0) {
      return defaultFrame(totalFrames);
    }

    const introFrames = Math.floor(INTRO_SEC * safeFps);
    const outroFrames = Math.floor(OUTRO_SEC * safeFps);
    const journeyFrames = Math.max(0, totalFrames - introFrames - outroFrames);
    if (journeyFrames <= 0) {
      return defaultFrame(totalFrames);
    }

    const segments = compileTimelineSegments({
      places,
      routes,
      fps: safeFps,
      durationInFrames: journeyFrames,
    });
    if (!Array.isArray(segments) || segments.length === 0) {
      return defaultFrame(totalFrames);
    }

    const best = pickBestSegment(segments, safeFps);
    if (!best) {
      return defaultFrame(totalFrames);
    }

    const localFrame = best.type === 'travel'
      ? pickFrameWithinSegment(best, 0.68)
      : pickFrameWithinSegment(best, 0.60);
    const globalFrame = introFrames + localFrame;
    return clampFrame(globalFrame, totalFrames);
  } catch {
    return defaultFrame(totalFrames);
  }
}

