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

function requiresMapboxToken(mapStyle) {
  const style = String(mapStyle || '').trim();
  if (!style) return false;
  if (/^https?:\/\//i.test(style)) return false;
  return true;
}

function resolveMapStyleUrl(mapStyle) {
  const style = String(mapStyle || '').trim();
  if (!style) return 'mapbox://styles/mapbox/navigation-night-v1';
  if (style.startsWith('mapbox://styles/')) return style;
  if (/^https?:\/\//i.test(style)) return style;
  return `mapbox://styles/${style}`;
}

function buildStyleApiUrl(mapStyle, mapboxToken) {
  const style = String(mapStyle || '').trim();
  if (!style || !mapboxToken) return null;
  if (/^https?:\/\//i.test(style)) {
    const hasQuery = style.includes('?');
    return `${style}${hasQuery ? '&' : '?'}access_token=${encodeURIComponent(mapboxToken)}`;
  }
  const normalizedStyle = style.startsWith('mapbox://styles/')
    ? style.replace('mapbox://styles/', '')
    : style;
  return `https://api.mapbox.com/styles/v1/${normalizedStyle}?access_token=${encodeURIComponent(mapboxToken)}`;
}

function shouldEnableNativeGl(input) {
  if (typeof input?.enableNativeGl === 'boolean') {
    return input.enableNativeGl;
  }
  return readFlag('CINEMATIC_GL_ENABLE_MAPBOX');
}

function shouldAllowCompatFallback(input) {
  if (typeof input?.allowCompatFallback === 'boolean') {
    return input.allowCompatFallback;
  }
  return true;
}

function isTerminalInitError(code) {
  return code === 'map_token_invalid'
    || code === 'map_style_revision_mismatch'
    || code === 'cinematic_snapshot_missing_style_pin';
}

function normalizeMapInitError(err, fallbackCode = 'map_init_failed') {
  const message = String(err?.message || fallbackCode);
  if (message.startsWith('map_') || message.startsWith('gl_') || message.startsWith('cinematic_')) {
    return new Error(message);
  }
  return new Error(fallbackCode);
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

function waitForMapEvent(map, eventName, timeoutMs = 20_000) {
  return new Promise((resolve, reject) => {
    let done = false;
    const timer = setTimeout(() => {
      if (done) return;
      done = true;
      reject(new Error(eventName === 'idle' ? 'gl_timeout_idle' : 'gl_timeout_delay_render'));
    }, timeoutMs);

    const cleanup = () => {
      clearTimeout(timer);
      if (typeof map?.off === 'function') {
        map.off(eventName, onEvent);
        map.off('error', onError);
      }
    };

    const onEvent = () => {
      if (done) return;
      done = true;
      cleanup();
      resolve();
    };

    const onError = () => {
      if (done) return;
      done = true;
      cleanup();
      reject(new Error('gl_runtime_init_error'));
    };

    if (typeof map?.once === 'function') {
      map.once(eventName, onEvent);
      map.once('error', onError);
    } else {
      done = true;
      cleanup();
      reject(new Error('gl_runtime_unavailable'));
    }
  });
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
      throw new Error('map_style_unreachable');
    }
    const payload = await response.json();
    const stripped = stripVolatileStyleFields(payload);
    const canonical = canonicalizeJson(stripped);
    const styleHash = await sha256Hex(canonical);
    const styleRevision = typeof payload?.modified === 'string' && payload.modified.trim().length > 0
      ? payload.modified.trim()
      : null;
    return { styleHash, styleRevision };
  } catch (err) {
    if (err?.name === 'AbortError') {
      throw new Error('map_style_unreachable_timeout');
    }
    if (String(err?.message || '') === 'map_token_invalid') {
      throw new Error('map_token_invalid');
    }
    throw new Error('map_style_unreachable');
  } finally {
    if (timeoutHandle) clearTimeout(timeoutHandle);
  }
}

async function styleMetaFromMap(map, mapStyle, mapboxToken) {
  const style = typeof map?.getStyle === 'function' ? map.getStyle() : null;
  if (style && Object.keys(style).length > 0) {
    const stripped = stripVolatileStyleFields(style);
    const canonical = canonicalizeJson(stripped);
    const styleHash = await sha256Hex(canonical);
    const styleRevision = typeof style?.metadata?.modified === 'string'
      ? style.metadata.modified
      : null;
    return { styleHash, styleRevision };
  }
  return fetchStyleMeta({ mapStyle, mapboxToken });
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

async function initNativeMap(input) {
  const mapStyle = input.mapStyle;
  const mapboxToken = input.mapboxToken;
  const requestedStyleHash = input.requestedStyleHash;
  const requestedStyleRevision = input.requestedStyleRevision;
  const isDerivedRequested = Boolean(requestedStyleHash && requestedStyleHash.startsWith('derived_'));

  if (requiresMapboxToken(mapStyle) && !mapboxToken) {
    throw new Error('map_token_invalid');
  }

  let mapboxGlModule;
  try {
    mapboxGlModule = await import('mapbox-gl');
  } catch {
    throw new Error('gl_runtime_unavailable');
  }

  const mapboxgl = mapboxGlModule?.default || mapboxGlModule;
  if (!mapboxgl || typeof mapboxgl.Map !== 'function') {
    throw new Error('gl_runtime_unavailable');
  }

  if (mapboxToken && 'accessToken' in mapboxgl) {
    mapboxgl.accessToken = mapboxToken;
  }

  const map = new mapboxgl.Map({
    container: input.container,
    style: resolveMapStyleUrl(mapStyle),
    center: input.initialCenter || [0, 0],
    zoom: Number.isFinite(input.initialZoom) ? input.initialZoom : 1,
    bearing: 0,
    pitch: 0,
    interactive: false,
    attributionControl: false,
    preserveDrawingBuffer: true,
    fadeDuration: 0,
  });
  map.mode = 'native_gl';

  await waitForMapEvent(map, 'style.load');
  await waitForMapEvent(map, 'idle');

  let fetchedStyleHash = null;
  let fetchedStyleRevision = null;
  if (isDerivedRequested) {
    fetchedStyleHash = deriveStyleHash(mapStyle);
  } else if (requestedStyleHash) {
    const styleMeta = await styleMetaFromMap(map, mapStyle, mapboxToken);
    fetchedStyleHash = styleMeta?.styleHash || null;
    fetchedStyleRevision = styleMeta?.styleRevision || null;
  }

  verifyStylePin({
    requestedStyleHash,
    requestedStyleRevision,
    fetchedStyleHash,
    fetchedStyleRevision,
  });

  return {
    map,
    release: () => {},
    styleMeta: {
      styleHash: fetchedStyleHash || requestedStyleHash || deriveStyleHash(mapStyle),
      styleRevision: fetchedStyleRevision || requestedStyleRevision || null,
    },
  };
}

async function initCompatRuntime(input) {
  const mapStyle = input.mapStyle;
  const mapboxToken = typeof input.mapboxToken === 'string' && input.mapboxToken.trim().length > 0
    ? input.mapboxToken.trim()
    : null;
  const requestedStyleHash = input.requestedStyleHash;
  const requestedStyleRevision = input.requestedStyleRevision;
  const allowDerivedStylePin = readFlag('CINEMATIC_GL_ALLOW_DERIVED_STYLE_PIN');
  const isDerivedRequested = Boolean(requestedStyleHash && requestedStyleHash.startsWith('derived_'));

  let fetchedStyleHash = null;
  let fetchedStyleRevision = null;
  if (isDerivedRequested || (allowDerivedStylePin && !requestedStyleRevision && requestedStyleHash)) {
    fetchedStyleHash = deriveStyleHash(mapStyle);
  } else if ((requestedStyleHash || requestedStyleRevision) && mapboxToken) {
    const styleMeta = await fetchStyleMeta({ mapStyle, mapboxToken });
    fetchedStyleHash = styleMeta?.styleHash || null;
    fetchedStyleRevision = styleMeta?.styleRevision || null;
  } else if (
    requestedStyleRevision
    && !requestedStyleHash
    && requiresMapboxToken(mapStyle)
    && !mapboxToken
  ) {
    throw new Error('map_style_unreachable');
  } else if (requestedStyleHash && !requestedStyleRevision) {
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

  if (!requestedStyleHash && !requestedStyleRevision) {
    throw new Error('cinematic_snapshot_missing_style_pin');
  }

  const nativeRequested = shouldEnableNativeGl(input);
  const allowCompatFallback = shouldAllowCompatFallback(input);

  if (nativeRequested) {
    try {
      return await initNativeMap({
        ...input,
        mapStyle,
        mapboxToken,
        requestedStyleHash,
        requestedStyleRevision,
      });
    } catch (err) {
      const normalizedErr = normalizeMapInitError(err, 'gl_runtime_init_error');
      if (!allowCompatFallback || isTerminalInitError(normalizedErr.message)) {
        throw normalizedErr;
      }
    }
  }

  return initCompatRuntime({
    ...input,
    mapStyle,
    mapboxToken,
    requestedStyleHash,
    requestedStyleRevision,
  });
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
