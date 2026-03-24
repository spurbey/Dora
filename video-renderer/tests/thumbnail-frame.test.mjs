import assert from 'node:assert/strict';
import test from 'node:test';

import { selectThumbnailFrame } from '../src/thumbnail-frame.js';

function cinematicSnapshotFixture() {
  return {
    trip: { title: 'Thumbnail Fixture' },
    places: [
      { id: 'p1', name: 'Start', lat: 27.7, lng: 85.3 },
      { id: 'p2', name: 'Mid', lat: 27.71, lng: 85.31 },
      { id: 'p3', name: 'End', lat: 27.72, lng: 85.32 },
    ],
    routes: [
      {
        id: 'r1',
        transport_mode: 'car',
        route_geojson: { type: 'LineString', coordinates: [[85.3, 27.7], [85.305, 27.705], [85.31, 27.71]] },
      },
      {
        id: 'r2',
        transport_mode: 'air',
        route_geojson: { type: 'LineString', coordinates: [[85.31, 27.71], [85.315, 27.715], [85.32, 27.72]] },
      },
    ],
  };
}

test('classic template keeps legacy 45 percent thumbnail selection', () => {
  const frame = selectThumbnailFrame({
    template: 'classic',
    snapshot: {},
    durationInFrames: 300,
    fps: 30,
  });
  assert.equal(frame, 135);
});

test('cinematic selection avoids intro and outro overlay windows', () => {
  const fps = 30;
  const total = 300;
  const frame = selectThumbnailFrame({
    template: 'cinematic',
    snapshot: cinematicSnapshotFixture(),
    durationInFrames: total,
    fps,
  });

  const introFrames = Math.floor(1.5 * fps);
  const outroStart = total - Math.floor(1.0 * fps);
  assert.ok(frame >= introFrames, `expected frame >= intro (${introFrames}), got ${frame}`);
  assert.ok(frame < outroStart, `expected frame < outro start (${outroStart}), got ${frame}`);
});

test('cinematic selection is deterministic for same input', () => {
  const input = {
    template: 'cinematic',
    snapshot: cinematicSnapshotFixture(),
    durationInFrames: 360,
    fps: 30,
  };
  const first = selectThumbnailFrame(input);
  const second = selectThumbnailFrame(input);
  assert.equal(first, second);
});

test('cinematic selection falls back safely for invalid snapshot', () => {
  const frame = selectThumbnailFrame({
    template: 'cinematic',
    snapshot: null,
    durationInFrames: 200,
    fps: 25,
  });
  assert.equal(frame, 90);
});

