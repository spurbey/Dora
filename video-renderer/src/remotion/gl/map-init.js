function readFlag(flagName) {
  return typeof process !== 'undefined'
    && Boolean(process?.env)
    && process.env[flagName] === '1';
}

function fnv1aHex(value) {
  const text = String(value || '');
  let hash = 0x811c9dc5;
  for (let i = 0; i < text.length; i++) {
    hash ^= text.charCodeAt(i);
    hash += (hash << 1) + (hash << 4) + (hash << 7) + (hash << 8) + (hash << 24);
  }
  return `fnv1a_${(hash >>> 0).toString(16).padStart(8, '0')}`;
}

function deriveStyleHash(mapStyle) {
  return `derived_${fnv1aHex(mapStyle)}`;
}

function asObject(value) {
  return value && typeof value === 'object' && !Array.isArray(value) ? value : {};
}

function stripVolatileStyleFields(styleJson) {
  const src = asObject(styleJson);
  const out = { ...src };
  delete out.created;
  delete out.modified;
  return out;
}

function canonicalizeJson(value) {
  if (Array.isArray(value)) {
    return `[${value.map((entry) => canonicalizeJson(entry)).join(',')}]`;
  }
  if (value && typeof value === 'object') {
    const keys = Object.keys(value).sort();
    return `{${keys.map((key) => `${JSON.stringify(key)}:${canonicalizeJson(value[key])}`).join(',')}}`;
  }
  return JSON.stringify(value);
}

async function sha256Hex(text) {
  const source = String(text ?? '');
  if (globalThis.crypto?.subtle) {
    const bytes = new TextEncoder().encode(source);
    const digest = await globalThis.crypto.subtle.digest('SHA-256', bytes);
    const arr = Array.from(new Uint8Array(digest));
    return arr.map((b) => b.toString(16).padStart(2, '0')).join('');
  }
  return fnv1aHex(source);
}

function buildStyleApiUrl(mapStyle, mapboxToken) {
  if (typeof mapStyle !== 'string' || mapStyle.trim().length === 0) return null;
  const trimmedStyle = mapStyle.trim();
  if (!mapboxToken || mapboxToken.trim().length === 0) return null;
  if (/^https?:\/\//i.test(trimmedStyle)) {
    const hasQuery = trimmedStyle.includes('?');
    return `${trimmedStyle}${hasQuery ? '&' : '?'}access_token=${encodeURIComponent(mapboxToken)}`;
  }
  const stylePath = /^mapbox:\/\/styles\//i.test(trimmedStyle)
    ? trimmedStyle.replace(/^mapbox:\/\/styles\//i, '')
    : trimmedStyle.replace(/^styles\//i, '');
  return `https://api.mapbox.com/styles/v1/${stylePath}?access_token=${encodeURIComponent(mapboxToken)}`;
}

async function fetchStyleMeta({ mapStyle, mapboxToken }) {
  const url = buildStyleApiUrl(mapStyle, mapboxToken);
  if (!url) return null;

  const timeoutMs = 8_000;
  const controller = typeof AbortController !== 'undefined' ? new AbortController() : null;
  const timeoutHandle = controller ? setTimeout(() => controller.abort(), timeoutMs) : null;

  try {
    const response = await fetch(url, controller ? { signal: controller.signal } : undefined);
    if (!response.ok) {
      if (response.status === 401 || response.status === 403) {
        throw new Error('map_token_invalid');
      }
      throw new Error(`map_style_unreachable_http_${response.status}`);
    }
    const payload = await response.json();
    const stripped = stripVolatileStyleFields(payload);
    const canonical = canonicalizeJson(stripped);
    const styleHash = await sha256Hex(canonical);
    const styleRevision = typeof payload?.modified === 'string' && payload.modified.trim().length > 0
      ? payload.modified.trim()
      : null;

    return {
      styleHash,
      styleRevision,
    };
  } catch (err) {
    if (err?.message === 'map_token_invalid') {
      throw err;
    }
    throw new Error(err?.name === 'AbortError' ? 'map_style_unreachable_timeout' : 'map_style_unreachable');
  } finally {
    if (timeoutHandle) clearTimeout(timeoutHandle);
  }
}

export function verifyStylePin(input) {
  const safe = asObject(input);
  const requestedStyleHash = typeof safe.requestedStyleHash === 'string' && safe.requestedStyleHash.trim().length > 0
    ? safe.requestedStyleHash.trim()
    : null;
  const requestedStyleRevision = typeof safe.requestedStyleRevision === 'string' && safe.requestedStyleRevision.trim().length > 0
    ? safe.requestedStyleRevision.trim()
    : null;
  const fetchedStyleHash = typeof safe.fetchedStyleHash === 'string' && safe.fetchedStyleHash.trim().length > 0
    ? safe.fetchedStyleHash.trim()
    : null;
  const fetchedStyleRevision = typeof safe.fetchedStyleRevision === 'string' && safe.fetchedStyleRevision.trim().length > 0
    ? safe.fetchedStyleRevision.trim()
    : null;

  if (requestedStyleHash && fetchedStyleHash && requestedStyleHash !== fetchedStyleHash) {
    throw new Error('map_style_revision_mismatch');
  }
  if (requestedStyleRevision && fetchedStyleRevision && requestedStyleRevision !== fetchedStyleRevision) {
    throw new Error('map_style_revision_mismatch');
  }
}

function createCompatMap(input = {}) {
  const state = {
    camera: {
      center: null,
      zoom: null,
      bearing: 0,
      pitch: 0,
    },
    routeState: {},
    markerState: null,
    mode: 'static_compat',
    container: input.container || null,
  };

  return {
    mode: 'static_compat',
    jumpTo(nextCamera = {}) {
      state.camera = {
        ...state.camera,
        ...nextCamera,
      };
    },
    __state: state,
  };
}

export async function initMapWithGate(input = {}) {
  const mapStyle = typeof input.mapStyle === 'string' && input.mapStyle.trim().length > 0
    ? input.mapStyle.trim()
    : 'mapbox/navigation-night-v1';
  const requestedStyleHash = typeof input.styleHash === 'string' && input.styleHash.trim().length > 0
    ? input.styleHash.trim()
    : null;
  const requestedStyleRevision = typeof input.styleRevision === 'string' && input.styleRevision.trim().length > 0
    ? input.styleRevision.trim()
    : null;
  const mapboxToken = typeof input.mapboxToken === 'string' && input.mapboxToken.trim().length > 0
    ? input.mapboxToken.trim()
    : null;
  const allowDerivedStylePin = readFlag('CINEMATIC_GL_ALLOW_DERIVED_STYLE_PIN');

  if (!requestedStyleHash && !requestedStyleRevision) {
    throw new Error('cinematic_snapshot_missing_style_pin');
  }

  let fetchedStyleHash = null;
  let fetchedStyleRevision = null;
  const isDerivedRequested = Boolean(requestedStyleHash && requestedStyleHash.startsWith('derived_'));
  const needsRemoteStyleValidation = Boolean(requestedStyleHash || requestedStyleRevision);

  if (isDerivedRequested || (allowDerivedStylePin && !requestedStyleRevision && requestedStyleHash)) {
    fetchedStyleHash = deriveStyleHash(mapStyle);
  } else if (needsRemoteStyleValidation && mapboxToken) {
    const styleMeta = await fetchStyleMeta({ mapStyle, mapboxToken });
    fetchedStyleHash = styleMeta?.styleHash || null;
    fetchedStyleRevision = styleMeta?.styleRevision || null;
  } else if (needsRemoteStyleValidation && !mapboxToken) {
    // Non-derived style pins require style metadata fetch for verification.
    throw new Error('map_style_unreachable');
  }

  verifyStylePin({
    requestedStyleHash,
    requestedStyleRevision,
    fetchedStyleHash,
    fetchedStyleRevision,
  });

  const map = createCompatMap({ container: input.container });
  return {
    map,
    release: () => {},
    styleMeta: {
      styleHash: fetchedStyleHash || requestedStyleHash || deriveStyleHash(mapStyle),
      styleRevision: fetchedStyleRevision || requestedStyleRevision || null,
    },
  };
}

export function destroyMap(map) {
  if (!map || typeof map !== 'object') return;
  if (typeof map.remove === 'function') {
    try {
      map.remove();
    } catch {
      // no-op
    }
  }
}
