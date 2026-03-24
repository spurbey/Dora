import assert from 'node:assert/strict';
import test from 'node:test';

import { compileTimelineSegments } from '../src/remotion/gl/timeline-compiler.js';
import {
  assertPlanDeterminism,
  buildRenderPlan,
  getFrameState,
} from '../src/remotion/gl/render-plan-builder.js';

function fixtureSnapshot() {
  return {
    trip: { title: 'Planner Fixture' },
    places: [
      { id: 'p1', name: 'A', lat: 27.7, lng: 85.3 },
      { id: 'p2', name: 'B', lat: 27.71, lng: 85.31 },
      { id: 'p3', name: 'C', lat: 27.72, lng: 85.32 },
    ],
    routes: [
      {
        id: 'r1',
        transport_mode: 'car',
        route_geojson: { type: 'LineString', coordinates: [[85.3, 27.7], [85.305, 27.705], [85.31, 27.71]] },
      },
      {
        id: 'r2',
        transport_mode: 'car',
        route_geojson: { type: 'LineString', coordinates: [[85.31, 27.71], [85.315, 27.715], [85.32, 27.72]] },
      },
    ],
    renderer_config: {
      map_style: 'mapbox/navigation-night-v1',
    },
  };
}

test('timeline compiler keeps final arrival for short durations', () => {
  const places = [{ id: 'p1' }, { id: 'p2' }, { id: 'p3' }];
  const routes = [{ id: 'r1' }, { id: 'r2' }];
  const segments = compileTimelineSegments({
    places,
    routes,
    fps: 30,
    durationInFrames: 30,
  });

  assert.equal(segments.length, 5);
  assert.equal(segments[0].startFrame, 0);
  assert.equal(segments[segments.length - 1].type, 'arrive');
  assert.equal(segments[segments.length - 1].placeIndex, 2);
  assert.equal(segments[segments.length - 1].endFrame, 29);
});

test('camera planner does not jump to {0,0} for empty route geometry', () => {
  const snapshot = fixtureSnapshot();
  const plan = buildRenderPlan({
    snapshot,
    fps: 30,
    durationInFrames: 90,
    projectedPlaces: [
      { x: 120, y: 140, place: snapshot.places[0] },
      { x: 320, y: 360, place: snapshot.places[1] },
      { x: 520, y: 600, place: snapshot.places[2] },
    ],
    projectedRoutes: [
      { points: [], isArc: false, route: snapshot.routes[0] },
      { points: [], isArc: false, route: snapshot.routes[1] },
    ],
    width: 720,
    height: 1280,
  });

  const travel = plan.segments.find((segment) => segment.type === 'travel');
  assert.ok(travel, 'travel segment should exist');
  const mid = Math.floor((travel.startFrame + travel.endFrame) / 2);
  const state = getFrameState(plan, mid);

  assert.ok(state.camera);
  assert.notEqual(state.camera.center.x, 0);
  assert.notEqual(state.camera.center.y, 0);
});

test('style pin is always present after normalization/validation', () => {
  const snapshot = fixtureSnapshot();
  const plan = buildRenderPlan({
    snapshot,
    fps: 30,
    durationInFrames: 60,
    projectedPlaces: [
      { x: 100, y: 100, place: snapshot.places[0] },
      { x: 240, y: 240, place: snapshot.places[1] },
      { x: 420, y: 420, place: snapshot.places[2] },
    ],
    projectedRoutes: [
      { points: [{ x: 100, y: 100 }, { x: 240, y: 240 }], isArc: false, route: snapshot.routes[0] },
      { points: [{ x: 240, y: 240 }, { x: 420, y: 420 }], isArc: false, route: snapshot.routes[1] },
    ],
    width: 720,
    height: 1280,
  });

  assert.ok(
    plan.rendererConfig.style_revision || plan.rendererConfig.style_hash,
    'renderer config must include a style pin',
  );
});

test('assertPlanDeterminism validates rebuilt plan equivalence', () => {
  const snapshot = fixtureSnapshot();
  const plan = buildRenderPlan({
    snapshot,
    fps: 30,
    durationInFrames: 90,
    projectedPlaces: [
      { x: 100, y: 100, place: snapshot.places[0] },
      { x: 250, y: 250, place: snapshot.places[1] },
      { x: 420, y: 420, place: snapshot.places[2] },
    ],
    projectedRoutes: [
      { points: [{ x: 100, y: 100 }, { x: 180, y: 160 }, { x: 250, y: 250 }], isArc: false, route: snapshot.routes[0] },
      { points: [{ x: 250, y: 250 }, { x: 340, y: 310 }, { x: 420, y: 420 }], isArc: false, route: snapshot.routes[1] },
    ],
    width: 720,
    height: 1280,
  });

  assert.doesNotThrow(() => assertPlanDeterminism(plan));

  plan.segments[0].startFrame += 1;
  assert.throws(() => assertPlanDeterminism(plan), /render_plan_hash_mismatch|render_plan_frame_state_mismatch_/);
});
