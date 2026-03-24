import assert from 'node:assert/strict';
import test from 'node:test';

import { compileTimelineSegments } from '../src/remotion/gl/timeline-compiler.js';
import {
  assertPlanDeterminism,
  buildRenderPlan,
  getFrameState,
} from '../src/remotion/gl/render-plan-builder.js';
import {
  buildOverlayTracks,
  overlayStateAtFrame,
  resolveCardPlacement,
} from '../src/remotion/gl/overlay-planner.js';

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
      style_revision: 'rev_fixture_2026_03_24',
      mapbox_gl_enabled: true,
      mapbox_gl_strict: false,
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

test('timeline compiler uses route place endpoints and timestamps for deterministic leg order', () => {
  const places = [
    { id: 'mumbai', lat: 19.076, lng: 72.8777 },
    { id: 'kathmandu', lat: 27.7172, lng: 85.324 },
    { id: 'oman', lat: 23.588, lng: 58.3829 },
    { id: 'dubai', lat: 25.2048, lng: 55.2708 },
  ];
  const routes = [
    {
      id: 'r3',
      start_place_id: 'oman',
      end_place_id: 'dubai',
      transport_mode: 'air',
      started_at: '2026-01-12T10:00:00Z',
    },
    {
      id: 'r1',
      start_place_id: 'mumbai',
      end_place_id: 'kathmandu',
      transport_mode: 'air',
      started_at: '2026-01-02T10:00:00Z',
    },
    {
      id: 'r2',
      start_place_id: 'kathmandu',
      end_place_id: 'oman',
      transport_mode: 'air',
      started_at: '2026-01-06T10:00:00Z',
    },
  ];

  const segments = compileTimelineSegments({
    places,
    routes,
    fps: 30,
    durationInFrames: 180,
  });

  const travelSegments = segments.filter((segment) => segment.type === 'travel');
  assert.equal(travelSegments.length, 3);
  assert.deepEqual(
    travelSegments.map((segment) => segment.routeIndex),
    [1, 2, 0],
    'travel order should follow route timestamps, not input array order',
  );
  assert.equal(segments[segments.length - 1].type, 'arrive');
  assert.equal(segments[segments.length - 1].placeIndex, 3, 'final arrival should land on route chain destination');
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

test('buildRenderPlan requires explicit style pin by default', () => {
  const snapshot = fixtureSnapshot();
  snapshot.renderer_config = {
    map_style: 'mapbox/navigation-night-v1',
  };

  assert.throws(
    () => buildRenderPlan({
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
    }),
    /cinematic_snapshot_missing_style_pin/,
  );
});

test('allowDerivedStylePin enables deterministic compatibility pin generation', () => {
  const snapshot = fixtureSnapshot();
  snapshot.renderer_config = {
    map_style: 'mapbox/navigation-night-v1',
  };
  const plan = buildRenderPlan({
    snapshot,
    allowDerivedStylePin: true,
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

  assert.ok(plan.rendererConfig.style_hash, 'renderer config must include a derived style hash');
  assert.match(plan.rendererConfig.style_hash, /^derived_fnv1a_[0-9a-f]{8}$/);
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

test('buildRenderPlan keeps native-gl renderer flags from snapshot config', () => {
  const snapshot = fixtureSnapshot();
  snapshot.renderer_config.mapbox_gl_enabled = true;
  snapshot.renderer_config.mapbox_gl_strict = true;

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

  assert.equal(plan.rendererConfig.mapbox_gl_enabled, true);
  assert.equal(plan.rendererConfig.mapbox_gl_strict, true);
});

test('frame state exposes only active travel route progress to avoid multi-leg clutter', () => {
  const snapshot = {
    trip: { title: 'Route Progress Focus Fixture' },
    places: [
      { id: 'p1', name: 'A', lat: 27.7, lng: 85.3 },
      { id: 'p2', name: 'B', lat: 27.71, lng: 85.31 },
      { id: 'p3', name: 'C', lat: 27.72, lng: 85.32 },
    ],
    routes: [
      {
        id: 'r1',
        start_place_id: 'p1',
        end_place_id: 'p2',
        transport_mode: 'air',
        route_geojson: null,
      },
      {
        id: 'r2',
        start_place_id: 'p2',
        end_place_id: 'p3',
        transport_mode: 'air',
        route_geojson: null,
      },
    ],
    renderer_config: {
      map_style: 'mapbox/navigation-night-v1',
      style_revision: 'rev_fixture_focus_2026_03_25',
      mapbox_gl_enabled: true,
      mapbox_gl_strict: false,
    },
  };

  const plan = buildRenderPlan({
    snapshot,
    fps: 30,
    durationInFrames: 150,
    projectedPlaces: [
      { x: 120, y: 240, place: snapshot.places[0] },
      { x: 360, y: 380, place: snapshot.places[1] },
      { x: 610, y: 500, place: snapshot.places[2] },
    ],
    projectedRoutes: [
      {
        isArc: true,
        startPoint: { x: 120, y: 240 },
        endPoint: { x: 360, y: 380 },
        points: [],
        route: snapshot.routes[0],
      },
      {
        isArc: true,
        startPoint: { x: 360, y: 380 },
        endPoint: { x: 610, y: 500 },
        points: [],
        route: snapshot.routes[1],
      },
    ],
    width: 720,
    height: 1280,
  });

  const firstTravel = plan.segments.find((segment) => segment.type === 'travel' && segment.routeIndex === 0);
  const secondTravel = plan.segments.find((segment) => segment.type === 'travel' && segment.routeIndex === 1);
  assert.ok(firstTravel && secondTravel, 'both travel segments should exist');

  const firstTravelFrame = Math.floor((firstTravel.startFrame + firstTravel.endFrame) / 2);
  const secondTravelFrame = Math.floor((secondTravel.startFrame + secondTravel.endFrame) / 2);
  const firstState = getFrameState(plan, firstTravelFrame);
  const secondState = getFrameState(plan, secondTravelFrame);

  assert.deepEqual(Object.keys(firstState.routeProgressByIndex), ['0']);
  assert.deepEqual(Object.keys(secondState.routeProgressByIndex), ['1']);
});

test('overlay label uses eased fade-in and reaches zero at fade-out tail', () => {
  const tracks = buildOverlayTracks({
    segments: [
      {
        type: 'arrive',
        startFrame: 0,
        endFrame: 29,
        placeIndex: 0,
      },
    ],
    places: [{ id: 'p1', name: 'Arrival' }],
    fps: 30,
    frameSize: { width: 720, height: 1280 },
  });

  const midFadeIn = overlayStateAtFrame(tracks, 5);
  const endFrame = overlayStateAtFrame(tracks, 29);
  assert.ok(midFadeIn.label.opacity > 0.6, `expected eased fade-in > 0.6, got ${midFadeIn.label.opacity}`);
  assert.ok(endFrame.label.opacity <= 0.01, `expected fade-out tail near 0, got ${endFrame.label.opacity}`);
});

test('resolveCardPlacement avoids route-heavy quadrant near anchor', () => {
  const placement = resolveCardPlacement({
    anchor: { x: 340, y: 640 },
    cardSize: { width: 170, height: 200 },
    viewport: { width: 720, height: 1280 },
    routePolyline: [
      { x: 360, y: 450 },
      { x: 390, y: 470 },
      { x: 420, y: 500 },
      { x: 445, y: 530 },
      { x: 470, y: 560 },
    ],
  });

  assert.notEqual(placement.quadrant, 'NE');
});

test('air route_category without transport_mode still gets air pacing and camera profile', () => {
  const snapshot = {
    trip: { title: 'Air Route Category Fixture' },
    places: [
      { id: 'p1', name: 'Kathmandu', lat: 27.7172, lng: 85.324 },
      { id: 'p2', name: 'Dubai', lat: 25.2048, lng: 55.2708 },
    ],
    routes: [
      {
        id: 'r1',
        route_category: 'air',
        transport_mode: '',
        route_geojson: null,
      },
    ],
    renderer_config: {
      map_style: 'mapbox/navigation-night-v1',
      style_revision: 'rev_air_fixture_2026_03_25',
      mapbox_gl_enabled: true,
      mapbox_gl_strict: false,
    },
  };

  const plan = buildRenderPlan({
    snapshot,
    fps: 30,
    durationInFrames: 120,
    projectedPlaces: [
      { x: 140, y: 220, place: snapshot.places[0] },
      { x: 620, y: 360, place: snapshot.places[1] },
    ],
    projectedRoutes: [
      {
        isArc: true,
        startPoint: { x: 140, y: 220 },
        endPoint: { x: 620, y: 360 },
        points: [],
        route: snapshot.routes[0],
      },
    ],
    width: 720,
    height: 1280,
  });

  const travel = plan.segments.find((segment) => segment.type === 'travel');
  assert.ok(travel, 'travel segment should exist');

  const quarter = Math.floor(travel.startFrame + (travel.endFrame - travel.startFrame) * 0.25);
  const middle = Math.floor(travel.startFrame + (travel.endFrame - travel.startFrame) * 0.5);
  const quarterState = getFrameState(plan, quarter);
  const middleState = getFrameState(plan, middle);

  const travelProgress = quarterState.routeProgressByIndex[travel.routeIndex];
  assert.ok(travelProgress < 0.2, `expected slow air lift-off pacing, got ${travelProgress}`);
  assert.ok(middleState.camera.pitch >= 45, `expected air mid-flight pitch >= 45, got ${middleState.camera.pitch}`);
  assert.ok(middleState.camera.scale <= 2.05, `expected air cruise zoomed-out scale <= 2.05, got ${middleState.camera.scale}`);
});
