import { clamp } from './geometry-math.js';
import { cameraStateAtFrame, buildCameraKeyframes } from './camera-planner.js';
import { extractRendererConfig, normalizeSnapshot, validateSnapshotForCinematic } from './normalize-snapshot.js';
import { buildOverlayTracks, overlayStateAtFrame } from './overlay-planner.js';
import { buildRouteCurves, headingAtS, pointAtS } from './route-animator.js';
import { compileTimelineSegments, findActiveSegment } from './timeline-compiler.js';

function easeInOutCubic(input) {
  const p = clamp(input, 0, 1);
  if (p < 0.5) return 4 * p * p * p;
  return 1 - Math.pow(-2 * p + 2, 3) / 2;
}

function safeFrame(frame) {
  if (!Number.isFinite(frame)) return 0;
  return Math.max(0, Math.floor(frame));
}

function routeProgressForFrame(segment, frame) {
  if (!segment || segment.type !== 'travel') return 0;
  if (frame >= segment.endFrame) return 1;
  if (frame < segment.startFrame) return 0;
  const span = Math.max(1, segment.endFrame - segment.startFrame);
  const local = (frame - segment.startFrame) / span;
  return easeInOutCubic(local);
}

function fnv1aHex(value) {
  let hash = 0x811c9dc5;
  for (let i = 0; i < value.length; i++) {
    hash ^= value.charCodeAt(i);
    hash += (hash << 1) + (hash << 4) + (hash << 7) + (hash << 8) + (hash << 24);
  }
  return `fnv1a_${(hash >>> 0).toString(16).padStart(8, '0')}`;
}

export function buildRenderPlan(input) {
  const safeInput = input || {};
  const normalizedSnapshot = normalizeSnapshot(
    safeInput.snapshot || {
      places: safeInput.places,
      routes: safeInput.routes,
      renderer_config: safeInput.rendererConfig,
    },
  );
  validateSnapshotForCinematic(normalizedSnapshot);

  const places = Array.isArray(safeInput.places) ? safeInput.places : normalizedSnapshot.places;
  const routes = Array.isArray(safeInput.routes) ? safeInput.routes : normalizedSnapshot.routes;
  const durationInFrames = Number.isFinite(safeInput.durationInFrames) ? safeInput.durationInFrames : 0;
  const fps = Number.isFinite(safeInput.fps) ? safeInput.fps : 30;
  const projectedRoutes = Array.isArray(safeInput.projectedRoutes) ? safeInput.projectedRoutes : [];
  const projectedPlaces = Array.isArray(safeInput.projectedPlaces) ? safeInput.projectedPlaces : [];
  const width = Number.isFinite(safeInput.width) ? safeInput.width : 720;
  const height = Number.isFinite(safeInput.height) ? safeInput.height : 1280;

  const segments = Array.isArray(safeInput.segments)
    ? safeInput.segments
    : compileTimelineSegments({
      places,
      routes,
      fps,
      durationInFrames,
    });

  const routeCurves = buildRouteCurves({ projectedRoutes });
  const cameraKeyframes = buildCameraKeyframes({
    segments,
    routeCurves,
    projectedPlaces,
    frameSize: { width, height },
  });
  const overlayTracks = buildOverlayTracks({
    segments,
    places,
    fps,
    frameSize: { width, height },
  });

  return {
    normalizedSnapshot,
    rendererConfig: extractRendererConfig(normalizedSnapshot),
    fps,
    durationInFrames: Math.max(0, Math.floor(durationInFrames)),
    places,
    routes,
    segments,
    projectedPlaces,
    projectedRoutes,
    routeCurves,
    cameraKeyframes,
    overlayTracks,
  };
}

export function getFrameState(plan, frame) {
  if (!plan) {
    return {
      frame: 0,
      activeSegment: null,
      routeProgressByIndex: {},
      markerState: null,
      camera: null,
      overlay: null,
    };
  }

  const f = safeFrame(frame);
  const segments = Array.isArray(plan.segments) ? plan.segments : [];
  const activeSegment = findActiveSegment(segments, f);

  const routeProgressByIndex = {};
  for (const segment of segments) {
    if (segment?.type !== 'travel' || segment.routeIndex == null || segment.routeIndex < 0) continue;
    routeProgressByIndex[segment.routeIndex] = routeProgressForFrame(segment, f);
  }

  let markerState = null;

  if (activeSegment) {
    if (activeSegment.type === 'arrive') {
      const placePoint = plan.projectedPlaces?.[activeSegment.placeIndex];
      if (placePoint) {
        markerState = {
          mapX: placePoint.x,
          mapY: placePoint.y,
          heading: 0,
          isAtPlace: true,
        };
      }
    } else if (activeSegment.type === 'travel') {
      const routeIndex = activeSegment.routeIndex;
      const curve = plan.routeCurves?.[routeIndex];
      const s = routeProgressByIndex[routeIndex] ?? 0;
      const point = pointAtS(curve, s);
      if (point) {
        markerState = {
          mapX: point.x,
          mapY: point.y,
          heading: headingAtS(curve, s),
          isAtPlace: false,
        };
      }
    }
  }

  const camera = cameraStateAtFrame(f, plan.cameraKeyframes || []);
  const overlay = overlayStateAtFrame(plan.overlayTracks || {}, f);

  return {
    frame: f,
    activeSegment,
    routeProgressByIndex,
    markerState,
    camera,
    overlay,
  };
}

export function hashRenderPlan(plan) {
  const safePlan = plan || {};
  const payload = JSON.stringify({
    durationInFrames: safePlan.durationInFrames,
    fps: safePlan.fps,
    segments: safePlan.segments || [],
    routeCurves: safePlan.routeCurves || [],
    projectedPlaces: safePlan.projectedPlaces || [],
    cameraKeyframes: safePlan.cameraKeyframes || [],
    overlayTracks: safePlan.overlayTracks || [],
    rendererConfig: safePlan.rendererConfig || {},
  });
  return fnv1aHex(payload);
}

export function assertPlanDeterminism(plan) {
  const hash = hashRenderPlan(plan);
  if (!hash || typeof hash !== 'string') {
    throw new Error('render_plan_non_deterministic_hash');
  }
}
