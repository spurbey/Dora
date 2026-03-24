import assert from 'node:assert/strict';
import test from 'node:test';

import {
  initMapWithGate,
  verifyStylePin,
} from '../src/remotion/gl/map-init.js';

function fnv1aHex(value) {
  const text = String(value || '');
  let hash = 0x811c9dc5;
  for (let i = 0; i < text.length; i++) {
    hash ^= text.charCodeAt(i);
    hash += (hash << 1) + (hash << 4) + (hash << 7) + (hash << 8) + (hash << 24);
  }
  return `fnv1a_${(hash >>> 0).toString(16).padStart(8, '0')}`;
}

test('verifyStylePin passes when requested and fetched pins match', () => {
  assert.doesNotThrow(() => verifyStylePin({
    requestedStyleHash: 'derived_fnv1a_12345678',
    fetchedStyleHash: 'derived_fnv1a_12345678',
    requestedStyleRevision: 'rev_a',
    fetchedStyleRevision: 'rev_a',
  }));
});

test('verifyStylePin throws on hash mismatch', () => {
  assert.throws(
    () => verifyStylePin({
      requestedStyleHash: 'derived_fnv1a_aaaa1111',
      fetchedStyleHash: 'derived_fnv1a_bbbb2222',
    }),
    /map_style_revision_mismatch/,
  );
});

test('initMapWithGate initializes compatibility map for derived style hash', async () => {
  const mapStyle = 'mapbox/navigation-night-v1';
  const result = await initMapWithGate({
    container: null,
    mapStyle,
    styleHash: `derived_${fnv1aHex(mapStyle)}`,
    delayRenderLabel: 'test_gate',
  });

  assert.ok(result?.map, 'map should be returned');
  assert.equal(typeof result.map.jumpTo, 'function');
  assert.ok(result?.styleMeta?.styleHash?.startsWith('derived_fnv1a_'));
});

test('initMapWithGate rejects missing cinematic style pin', async () => {
  await assert.rejects(
    () => initMapWithGate({
      mapStyle: 'mapbox/navigation-night-v1',
      delayRenderLabel: 'test_gate',
    }),
    /cinematic_snapshot_missing_style_pin/,
  );
});

test('initMapWithGate rejects explicit hash without token when revision absent', async () => {
  await assert.rejects(
    () => initMapWithGate({
      mapStyle: 'mapbox/navigation-night-v1',
      styleHash: 'sha256_deadbeef',
      delayRenderLabel: 'test_gate',
    }),
    /map_style_unreachable/,
  );
});
