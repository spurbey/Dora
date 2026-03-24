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

async function withMockedFetch(fetchImpl, fn) {
  const previousFetch = globalThis.fetch;
  globalThis.fetch = fetchImpl;
  try {
    return await fn();
  } finally {
    if (typeof previousFetch === 'function') {
      globalThis.fetch = previousFetch;
    } else {
      delete globalThis.fetch;
    }
  }
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

test('initMapWithGate rejects native mapbox init without token', async () => {
  await assert.rejects(
    () => initMapWithGate({
      mapStyle: 'mapbox/navigation-night-v1',
      styleHash: `derived_${fnv1aHex('mapbox/navigation-night-v1')}`,
      enableNativeGl: true,
      delayRenderLabel: 'test_gate',
    }),
    /map_token_invalid/,
  );
});

test('initMapWithGate falls back to compatibility map when native runtime unavailable', async () => {
  const result = await initMapWithGate({
    mapStyle: 'https://example.com/style.json',
    styleHash: `derived_${fnv1aHex('https://example.com/style.json')}`,
    enableNativeGl: true,
    allowCompatFallback: true,
    delayRenderLabel: 'test_gate',
  });

  assert.equal(result.map.mode, 'static_compat');
  assert.equal(typeof result.map.jumpTo, 'function');
});

test('initMapWithGate surfaces native runtime error when compat fallback disabled', async () => {
  await assert.rejects(
    () => initMapWithGate({
      mapStyle: 'https://example.com/style.json',
      styleHash: `derived_${fnv1aHex('https://example.com/style.json')}`,
      enableNativeGl: true,
      allowCompatFallback: false,
      delayRenderLabel: 'test_gate',
    }),
    /gl_runtime_unavailable/,
  );
});

test('initMapWithGate verifies revision-only style pin when token is present', async () => {
  await withMockedFetch(
    async () => ({
      ok: true,
      status: 200,
      async json() {
        return {
          version: 8,
          name: 'Navigation Night',
          modified: 'rev_match',
          sources: {},
          layers: [],
        };
      },
    }),
    async () => {
      const result = await initMapWithGate({
        mapStyle: 'mapbox/navigation-night-v1',
        styleRevision: 'rev_match',
        mapboxToken: 'pk.test-token',
        delayRenderLabel: 'test_gate',
      });
      assert.equal(result?.styleMeta?.styleRevision, 'rev_match');
    },
  );
});

test('initMapWithGate rejects revision-only pin when token is missing', async () => {
  await assert.rejects(
    () => initMapWithGate({
      mapStyle: 'mapbox/navigation-night-v1',
      styleRevision: 'rev_match',
      delayRenderLabel: 'test_gate',
    }),
    /map_style_unreachable/,
  );
});

test('initMapWithGate classifies 401 style fetch as map_token_invalid', async () => {
  await withMockedFetch(
    async () => ({
      ok: false,
      status: 401,
      async json() {
        return {};
      },
    }),
    async () => {
      await assert.rejects(
        () => initMapWithGate({
          mapStyle: 'mapbox/navigation-night-v1',
          styleHash: 'sha256_any',
          mapboxToken: 'pk.invalid',
          delayRenderLabel: 'test_gate',
        }),
        /map_token_invalid/,
      );
    },
  );
});

test('initMapWithGate supports mapbox URI style format', async () => {
  let requestedUrl = null;
  await withMockedFetch(
    async (url) => {
      requestedUrl = String(url);
      return {
        ok: true,
        status: 200,
        async json() {
          return {
            version: 8,
            name: 'Navigation Night',
            modified: 'rev_uri',
            sources: {},
            layers: [],
          };
        },
      };
    },
    async () => {
      await initMapWithGate({
        mapStyle: 'mapbox://styles/mapbox/navigation-night-v1',
        styleRevision: 'rev_uri',
        mapboxToken: 'pk.test-token',
        delayRenderLabel: 'test_gate',
      });
    },
  );

  assert.ok(
    requestedUrl?.startsWith('https://api.mapbox.com/styles/v1/mapbox/navigation-night-v1?access_token='),
    `unexpected style URL: ${requestedUrl}`,
  );
});
