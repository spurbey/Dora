function normalizeToken(value) {
  return String(value || '').trim().toLowerCase();
}

function canonicalizeMode(rawMode) {
  const mode = normalizeToken(rawMode);
  if (!mode) return '';

  if (
    mode === 'air'
    || mode === 'flight'
    || mode === 'plane'
    || mode === 'airplane'
  ) {
    return 'air';
  }
  if (
    mode === 'walk'
    || mode === 'walking'
    || mode === 'hike'
    || mode === 'hiking'
    || mode === 'foot'
  ) {
    return 'foot';
  }
  if (
    mode === 'drive'
    || mode === 'driving'
    || mode === 'road'
    || mode === 'car'
    || mode === '4w'
    || mode === '4-wheeler'
    || mode === '4_wheeler'
  ) {
    return 'car';
  }
  if (mode === 'train' || mode === 'rail') return 'train';
  if (mode === 'bus' || mode === 'coach') return 'bus';
  if (mode === 'bike' || mode === 'cycling' || mode === 'cycle') return 'bike';

  return mode;
}

export function resolveTransportMode(route, fallback = '') {
  const safeRoute = route && typeof route === 'object' ? route : {};
  const preferred = canonicalizeMode(
    safeRoute.transport_mode
    || safeRoute.mode
    || safeRoute.travel_mode,
  );
  if (preferred) return preferred;

  const category = canonicalizeMode(safeRoute.route_category || safeRoute.category);
  if (category) return category;

  return canonicalizeMode(fallback);
}

export function isAirRoute(route) {
  return resolveTransportMode(route) === 'air';
}
