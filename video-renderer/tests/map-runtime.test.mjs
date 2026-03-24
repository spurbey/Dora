import assert from 'node:assert/strict';
import test from 'node:test';

import {
  applyCameraState,
  applyFrameToMap,
  upsertMarkerLayerState,
  upsertRouteLayerState,
} from '../src/remotion/gl/map-runtime.js';

function compatMapFixture() {
  return {
    mode: 'static_compat',
    lastJumpTo: null,
    __state: {
      camera: null,
      routeState: {},
      markerState: null,
    },
    jumpTo(payload) {
      this.lastJumpTo = payload;
      this.__state.camera = payload;
    },
  };
}

test('applyCameraState forwards map-native camera to jumpTo', () => {
  const map = compatMapFixture();
  map.mode = 'native_gl';
  applyCameraState(map, {
    center: { lng: 85.31, lat: 27.71 },
    zoom: 9.25,
    bearing: 35,
    pitch: 20,
  });

  assert.deepEqual(map.lastJumpTo.center, [85.31, 27.71]);
  assert.equal(map.lastJumpTo.zoom, 9.25);
  assert.equal(map.lastJumpTo.bearing, 35);
  assert.equal(map.lastJumpTo.pitch, 20);
});

test('applyCameraState converts projected camera to native jumpTo payload', () => {
  const map = compatMapFixture();
  map.mode = 'native_gl';

  applyCameraState(map, {
    center: { x: 450, y: 520 },
    scale: 2,
    bearing: 22,
    pitch: 12,
  }, {
    mapContext: {
      viewport: {
        center: { lng: 85.31, lat: 27.71 },
        zoom: 8,
      },
      mapWidth: 900,
      mapHeight: 1100,
    },
  });

  assert.ok(Array.isArray(map.lastJumpTo.center));
  assert.ok(Number.isFinite(map.lastJumpTo.center[0]));
  assert.ok(Number.isFinite(map.lastJumpTo.center[1]));
  assert.equal(map.lastJumpTo.zoom, 9);
  assert.equal(map.lastJumpTo.bearing, 22);
  assert.equal(map.lastJumpTo.pitch, 12);
});

test('upsert route and marker states persist into compatibility map state', () => {
  const map = compatMapFixture();
  const route = upsertRouteLayerState(map, { 0: 0.5 });
  const marker = upsertMarkerLayerState(map, { mapX: 120, mapY: 220, heading: 10, isAtPlace: false });

  assert.deepEqual(route, { 0: 0.5 });
  assert.equal(marker.mapX, 120);
  assert.equal(map.__state.routeState[0], 0.5);
  assert.equal(map.__state.markerState.mapY, 220);
});

test('applyFrameToMap computes stable viewport transform from frame state', () => {
  const map = compatMapFixture();
  const result = applyFrameToMap(map, {
    camera: {
      center: { x: 420, y: 360 },
      scale: 1.6,
      bearing: 0,
      pitch: 0,
    },
    routeProgressByIndex: { 1: 0.8 },
    markerState: { mapX: 430, mapY: 370, heading: 12, isAtPlace: false },
  }, {
    mapContext: { mapWidth: 900, mapHeight: 1100 },
    frameSize: { width: 720, height: 1280 },
  });

  assert.equal(result.routeProgressByIndex[1], 0.8);
  assert.equal(result.markerState.mapX, 430);
  assert.ok(Number.isFinite(result.viewport.totalScale));
  assert.ok(Number.isFinite(result.viewport.translateX));
  assert.ok(Number.isFinite(result.viewport.translateY));
});
