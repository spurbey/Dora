import { clamp } from './geometry-math.js';
import { cameraStateAtFrame, buildCameraKeyframes } from './camera-planner.js';
import { extractRendererConfig, normalizeSnapshot, validateSnapshotForCinematic } from './normalize-snapshot.js';
import { buildOverlayTracks, overlayStateAtFrame } from './overlay-planner.js';
import { EASING } from './quality-constants.js';
import { buildRouteCurves, headingAtS, pointAtS } from './route-animator.js';
import { compileTimelineSegments, findActiveSegment } from './timeline-compiler.js';

function easeInOutCubic(input) {
  const p = clamp(input, 0, 1);
  if (p < 0.5) return 4 * p * p * p;
  return 1 - Math.pow(-2 * p + 2, 3) / 2;
}

function easeOutCubic(input) {
  const p = clamp(input, 0, 1);
  return 1 - Math.pow(1 - p, 3);
}

function easeInOutSine(input) {
  const p = clamp(input, 0, 1);
  return 0.5 * (1 - Math.cos(Math.PI * p));
}

function applyEasing(name, input) {
  switch (name) {
    case 'easeOutCubic':
      return easeOutCubic(input);
    case 'easeInOutSine':
      return easeInOutSine(input);
    case 'easeInOutCubic':
    default:
      return easeInOutCubic(input);
  }
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
  return applyEasing(EASING.route, local);
}

function fnv1aHex(value) {
  let hash = 0x811c9dc5;
  for (let i = 0; i < value.length; i++) {
    hash ^= value.charCodeAt(i);
    hash += (hash << 1) + (hash << 4) + (hash << 7) + (hash << 8) + (hash << 24);
  }
  return `fnv1a_${(hash >>> 0).toString(16).padStart(8, '0')}`;
}

function deepClone(value) {
  return JSON.parse(JSON.stringify(value));
}

function readFlag(flagName) {
  return typeof process !== 'undefined'
    && Boolean(process?.env)
    && process.env[flagName] === '1';
}

function shouldAllowDerivedStylePin(input) {
  return input?.allowDerivedStylePin === true || readFlag('CINEMATIC_GL_ALLOW_DERIVED_STYLE_PIN');
}

function shouldAssertDeterminism(input) {
  return input?.enableDeterminismCheck === true || readFlag('CINEMATIC_GL_ASSERT_PLAN_DETERMINISM');
}

export function buildRenderPlan(input) {
  const safeInput = input || {};
  const normalizeOptions = {
    allowDerivedStylePin: shouldAllowDerivedStylePin(safeInput),
  };
  const normalizedSnapshot = normalizeSnapshot(
    safeInput.snapshot || {
      places: safeInput.places,
      routes: safeInput.routes,
      renderer_config: safeInput.rendererConfig,
    },
    normalizeOptions,
  );
  validateSnapshotForCinematic(normalizedSnapshot, normalizeOptions);

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

  const plan = {
    normalizedSnapshot,
    rendererConfig: extractRendererConfig(normalizedSnapshot, normalizeOptions),
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
    __determinismInput: deepClone({
      snapshot: normalizedSnapshot,
      places,
      routes,
      fps,
      durationInFrames,
      projectedRoutes,
      projectedPlaces,
      width,
      height,
      segments: Array.isArray(safeInput.segments) ? safeInput.segments : null,
    }),
  };

  if (!safeInput.skipDeterminismCheck && shouldAssertDeterminism(safeInput)) {
    assertPlanDeterminism(plan);
  }
  return plan;
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
        const heading = headingAtS(curve, s);
        markerState = {
          mapX: point.x,
          mapY: point.y,
          heading: Number.isFinite(heading) ? heading : 0,
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

  const input = plan?.__determinismInput;
  if (!input) {
    throw new Error('render_plan_missing_determinism_input');
  }

  const rebuilt = buildRenderPlan({
    ...deepClone(input),
    segments: Array.isArray(input.segments) ? input.segments : undefined,
    skipDeterminismCheck: true,
  });

  const rebuiltHash = hashRenderPlan(rebuilt);
  if (hash !== rebuiltHash) {
    throw new Error('render_plan_hash_mismatch');
  }

  const totalFrames = Math.max(1, Number.isFinite(plan?.durationInFrames) ? plan.durationInFrames : 1);
  const sampleFrames = [...new Set([0, Math.floor((totalFrames - 1) / 2), totalFrames - 1])];
  for (const frame of sampleFrames) {
    const a = JSON.stringify(getFrameState(plan, frame));
    const b = JSON.stringify(getFrameState(rebuilt, frame));
    if (a !== b) {
      throw new Error(`render_plan_frame_state_mismatch_${frame}`);
    }
  }
}
