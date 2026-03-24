const DEFAULT_MAP_STYLE = 'mapbox/navigation-night-v1';

function asObject(value) {
  return value && typeof value === 'object' && !Array.isArray(value) ? value : {};
}

function asArray(value) {
  return Array.isArray(value) ? value : [];
}

function toNumberOrNull(value) {
  const n = Number(value);
  return Number.isFinite(n) ? n : null;
}

function normalizePlace(place, index) {
  const safe = asObject(place);
  return {
    ...safe,
    id: safe.id ?? `place_${index}`,
    lat: toNumberOrNull(safe.lat),
    lng: toNumberOrNull(safe.lng),
    media: asArray(safe.media),
  };
}

function normalizeRoute(route, index) {
  const safe = asObject(route);
  const geo = asObject(safe.route_geojson);
  const lineString = geo.type === 'LineString' && Array.isArray(geo.coordinates)
    ? { type: 'LineString', coordinates: geo.coordinates }
    : null;
  return {
    ...safe,
    id: safe.id ?? `route_${index}`,
    transport_mode: typeof safe.transport_mode === 'string' ? safe.transport_mode : '',
    route_geojson: lineString,
    route_category: typeof safe.route_category === 'string' ? safe.route_category : '',
  };
}

function resolvePlaces(snapshot) {
  const timeline = asArray(snapshot.timeline);
  const timelinePlaces = timeline
    .filter((item) => item && item.component_type !== 'route' && item.name)
    .map((place, index) => normalizePlace(place, index));
  if (timelinePlaces.length > 0) return timelinePlaces;
  return asArray(snapshot.places).map((place, index) => normalizePlace(place, index));
}

function resolveRoutes(snapshot) {
  const timeline = asArray(snapshot.timeline);
  const timelineRoutes = timeline
    .filter((item) => item && item.component_type === 'route')
    .map((route, index) => normalizeRoute(route, index));
  if (timelineRoutes.length > 0) return timelineRoutes;
  return asArray(snapshot.routes).map((route, index) => normalizeRoute(route, index));
}

export function normalizeSnapshot(snapshot) {
  const safe = asObject(snapshot);
  const rendererConfig = asObject(safe.renderer_config);
  return {
    ...safe,
    trip: asObject(safe.trip),
    timeline: asArray(safe.timeline),
    places: resolvePlaces(safe),
    routes: resolveRoutes(safe),
    renderer_config: {
      ...rendererConfig,
      map_style: typeof rendererConfig.map_style === 'string' && rendererConfig.map_style.trim().length > 0
        ? rendererConfig.map_style.trim()
        : DEFAULT_MAP_STYLE,
      style_revision: typeof rendererConfig.style_revision === 'string' ? rendererConfig.style_revision : null,
      style_hash: typeof rendererConfig.style_hash === 'string' ? rendererConfig.style_hash : null,
      mapbox_token: typeof rendererConfig.mapbox_token === 'string' ? rendererConfig.mapbox_token : null,
    },
  };
}

export function extractRendererConfig(snapshot) {
  const normalized = normalizeSnapshot(snapshot);
  return {
    map_style: normalized.renderer_config.map_style,
    style_revision: normalized.renderer_config.style_revision,
    style_hash: normalized.renderer_config.style_hash,
    mapbox_token: normalized.renderer_config.mapbox_token,
  };
}

export function validateSnapshotForCinematic(snapshot) {
  const normalized = normalizeSnapshot(snapshot);
  if (typeof normalized.renderer_config.map_style !== 'string' || normalized.renderer_config.map_style.length === 0) {
    throw new Error('cinematic_snapshot_invalid_map_style');
  }
  if (!Array.isArray(normalized.places) || normalized.places.length === 0) {
    throw new Error('cinematic_snapshot_missing_places');
  }
}
