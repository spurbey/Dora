import { clamp } from './geometry-math.js';
import { resolveTransportMode } from './transport-mode.js';

function safeFrames(durationInFrames) {
  if (!Number.isFinite(durationInFrames)) return 0;
  return Math.max(0, Math.floor(durationInFrames));
}

function toLngLat(coord) {
  if (!Array.isArray(coord) || coord.length < 2) return null;
  const lng = Number(coord[0]);
  const lat = Number(coord[1]);
  if (!Number.isFinite(lng) || !Number.isFinite(lat)) return null;
  return { lng, lat };
}

function haversineMeters(a, b) {
  if (!a || !b) return 0;
  const toRad = (deg) => (deg * Math.PI) / 180;
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const sinDlat = Math.sin(dLat / 2);
  const sinDlng = Math.sin(dLng / 2);
  const h = sinDlat * sinDlat + Math.cos(lat1) * Math.cos(lat2) * sinDlng * sinDlng;
  const c = 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h));
  return 6371000 * c;
}

function estimateRouteDistanceMeters(route) {
  const coordinates = Array.isArray(route?.route_geojson?.coordinates)
    ? route.route_geojson.coordinates
    : [];
  if (coordinates.length < 2) return 0;
  let total = 0;
  let prev = toLngLat(coordinates[0]);
  for (let i = 1; i < coordinates.length; i++) {
    const next = toLngLat(coordinates[i]);
    if (prev && next) total += haversineMeters(prev, next);
    prev = next;
  }
  return total;
}

function parseEpochMs(value) {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === 'string' && value.trim().length > 0) {
    const parsed = Date.parse(value);
    if (Number.isFinite(parsed)) return parsed;
  }
  return Number.NaN;
}

function routeSortKey(route, index) {
  const fields = [
    route?.started_at,
    route?.start_time,
    route?.departure_time,
    route?.timestamp,
    route?.created_at,
    route?.updated_at,
  ];
  for (const candidate of fields) {
    const parsed = parseEpochMs(candidate);
    if (Number.isFinite(parsed)) return { hasTime: true, value: parsed, index };
  }
  return { hasTime: false, value: Number.NaN, index };
}

function placeCoordinate(place) {
  const lat = Number(place?.lat);
  const lng = Number(place?.lng);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null;
  return { lat, lng };
}

function nearestPlaceIndex(coord, placeCoords) {
  if (!coord || !Array.isArray(placeCoords) || placeCoords.length === 0) {
    return -1;
  }
  let bestIndex = -1;
  let bestDistance = Number.POSITIVE_INFINITY;
  for (let i = 0; i < placeCoords.length; i++) {
    const pc = placeCoords[i];
    if (!pc) continue;
    const d = haversineMeters(coord, pc);
    if (d < bestDistance) {
      bestDistance = d;
      bestIndex = i;
    }
  }
  return bestIndex;
}

function resolveRouteEndpoints(route, routeIndex, placeIdToIndex, placeCoords, placeCount) {
  const startById = placeIdToIndex.get(route?.start_place_id ?? '');
  const endById = placeIdToIndex.get(route?.end_place_id ?? '');

  const coordinates = Array.isArray(route?.route_geojson?.coordinates)
    ? route.route_geojson.coordinates
    : [];
  const startCoord = coordinates.length > 0 ? toLngLat(coordinates[0]) : null;
  const endCoord = coordinates.length > 0 ? toLngLat(coordinates[coordinates.length - 1]) : null;

  let startIndex = Number.isInteger(startById) ? startById : nearestPlaceIndex(startCoord, placeCoords);
  let endIndex = Number.isInteger(endById) ? endById : nearestPlaceIndex(endCoord, placeCoords);

  if (!Number.isInteger(startIndex) || startIndex < 0 || startIndex >= placeCount) {
    startIndex = clamp(routeIndex, 0, Math.max(0, placeCount - 1));
  }
  if (!Number.isInteger(endIndex) || endIndex < 0 || endIndex >= placeCount) {
    endIndex = clamp(routeIndex + 1, 0, Math.max(0, placeCount - 1));
  }

  if (startIndex === endIndex && placeCount > 1) {
    endIndex = clamp(startIndex + 1, 0, placeCount - 1);
  }

  return { startIndex, endIndex };
}

function travelBeatWeight(route) {
  const base = 1.6;
  const distanceMeters = estimateRouteDistanceMeters(route);
  const distanceKm = distanceMeters / 1000;
  const distanceBoost = clamp(Math.log10(distanceKm + 1) * 1.9, 0, 2.7);
  const mode = resolveTransportMode(route);
  const modeBoost = mode === 'air'
    ? 2.3
    : mode === 'train'
      ? 0.45
      : mode === 'foot'
        ? 0.2
        : 0;
  return base + distanceBoost + modeBoost;
}

function buildSegmentSpecs({ places, routes }) {
  const safePlaces = Array.isArray(places) ? places : [];
  const safeRoutes = Array.isArray(routes) ? routes : [];
  const placeCount = safePlaces.length;
  if (placeCount === 0) return { specs: [], beats: [] };

  const placeIdToIndex = new Map();
  const placeCoords = safePlaces.map((place, index) => {
    const id = place?.id;
    if (typeof id === 'string' && id.length > 0 && !placeIdToIndex.has(id)) {
      placeIdToIndex.set(id, index);
    }
    return placeCoordinate(place);
  });

  if (safeRoutes.length === 0) {
    const specs = [];
    const beats = [];
    for (let i = 0; i < placeCount; i++) {
      specs.push({
        type: 'arrive',
        placeIndex: i,
        routeIndex: -1,
        place: safePlaces[i],
        route: null,
      });
      beats.push(i === 0 || i === placeCount - 1 ? 2.4 : 1.8);
    }
    return { specs, beats };
  }

  const legs = safeRoutes.map((route, routeIndex) => {
    const endpoints = resolveRouteEndpoints(
      route,
      routeIndex,
      placeIdToIndex,
      placeCoords,
      placeCount,
    );
    const sortKey = routeSortKey(route, routeIndex);
    return {
      route,
      routeIndex,
      startIndex: endpoints.startIndex,
      endIndex: endpoints.endIndex,
      sortKey,
    };
  }).sort((a, b) => {
    if (a.sortKey.hasTime && b.sortKey.hasTime && a.sortKey.value !== b.sortKey.value) {
      return a.sortKey.value - b.sortKey.value;
    }
    if (a.sortKey.hasTime !== b.sortKey.hasTime) {
      return a.sortKey.hasTime ? -1 : 1;
    }
    return a.sortKey.index - b.sortKey.index;
  });

  const specs = [];
  const beats = [];
  const pushArrive = (placeIndex) => {
    if (!Number.isInteger(placeIndex) || placeIndex < 0 || placeIndex >= placeCount) return;
    const prev = specs[specs.length - 1];
    if (prev?.type === 'arrive' && prev.placeIndex === placeIndex) return;
    specs.push({
      type: 'arrive',
      placeIndex,
      routeIndex: -1,
      place: safePlaces[placeIndex],
      route: null,
    });
    beats.push(1.8);
  };

  let currentPlaceIndex = null;
  for (const leg of legs) {
    if (!Number.isInteger(leg.startIndex) || !Number.isInteger(leg.endIndex)) continue;

    if (currentPlaceIndex == null || currentPlaceIndex !== leg.startIndex) {
      pushArrive(leg.startIndex);
      currentPlaceIndex = leg.startIndex;
    }

    specs.push({
      type: 'travel',
      placeIndex: leg.startIndex,
      routeIndex: leg.routeIndex,
      place: null,
      route: leg.route,
    });
    beats.push(travelBeatWeight(leg.route));

    pushArrive(leg.endIndex);
    currentPlaceIndex = leg.endIndex;
  }

  if (specs.length === 0) {
    for (let i = 0; i < placeCount; i++) {
      pushArrive(i);
    }
  }

  const firstArrive = specs.findIndex((spec) => spec.type === 'arrive');
  if (firstArrive >= 0) beats[firstArrive] = 2.4;
  for (let i = specs.length - 1; i >= 0; i--) {
    if (specs[i].type === 'arrive') {
      beats[i] = 2.4;
      break;
    }
  }
  return { specs, beats };
}

export function allocateSegmentFrames({ beatWeights, durationInFrames }) {
  const totalFrames = safeFrames(durationInFrames);
  const weights = Array.isArray(beatWeights)
    ? beatWeights.map((w) => (Number.isFinite(w) && w > 0 ? w : 0))
    : [];

  if (weights.length === 0 || totalFrames <= 0) return [];
  const sum = weights.reduce((acc, w) => acc + w, 0);
  if (sum <= 0) return weights.map(() => 0);

  const scaled = weights.map((w) => (w / sum) * totalFrames);
  const base = scaled.map((n) => Math.floor(n));
  let remainder = totalFrames - base.reduce((acc, n) => acc + n, 0);

  const order = scaled
    .map((n, idx) => ({ idx, frac: n - Math.floor(n) }))
    .sort((a, b) => {
      if (b.frac !== a.frac) return b.frac - a.frac;
      return a.idx - b.idx;
    });

  for (let i = 0; i < order.length && remainder > 0; i++) {
    base[order[i].idx] += 1;
    remainder -= 1;
  }

  return base;
}

export function compileTimelineSegments({
  places,
  routes,
  fps,
  durationInFrames,
}) {
  const safePlaces = Array.isArray(places) ? places : [];
  const totalFrames = safeFrames(durationInFrames);
  if (safePlaces.length === 0 || totalFrames <= 0) return [];
  const { specs, beats } = buildSegmentSpecs({ places: safePlaces, routes });

  let specsToUse = specs;
  let beatsToUse = beats;

  if (totalFrames < specs.length) {
    const keep = [];
    keep.push(0);
    if (totalFrames > 1 && specs.length > 1) {
      keep.push(specs.length - 1);
    }
    for (let i = 1; i < specs.length - 1 && keep.length < totalFrames; i++) {
      keep.push(i);
    }
    const uniqueOrdered = [...new Set(keep)].sort((a, b) => a - b);
    specsToUse = uniqueOrdered.map((idx) => specs[idx]);
    beatsToUse = uniqueOrdered.map((idx) => beats[idx] ?? 1);
  }

  let frameAlloc = Array(specsToUse.length).fill(1);
  const remaining = totalFrames - specsToUse.length;
  if (remaining > 0) {
    const extra = allocateSegmentFrames({ beatWeights: beatsToUse, durationInFrames: remaining });
    frameAlloc = frameAlloc.map((base, idx) => base + (extra[idx] || 0));
  }

  const segments = [];
  let cursor = 0;

  for (let i = 0; i < specsToUse.length; i++) {
    const spec = specsToUse[i];
    const budget = frameAlloc[i] || 0;
    if (budget <= 0 || cursor >= totalFrames) continue;
    const frames = clamp(budget, 1, totalFrames - cursor);
    segments.push({
      ...spec,
      startFrame: cursor,
      endFrame: cursor + frames - 1,
    });
    cursor += frames;
  }

  if (segments.length === 0) return [];

  const finalSeg = segments[segments.length - 1];
  if (finalSeg.endFrame < totalFrames - 1) {
    finalSeg.endFrame = totalFrames - 1;
  }

  return segments;
}

export function findActiveSegment(segments, frame) {
  if (!Array.isArray(segments) || segments.length === 0) return null;
  if (!Number.isFinite(frame)) return segments[0];
  for (let i = segments.length - 1; i >= 0; i--) {
    if (frame >= segments[i].startFrame) return segments[i];
  }
  return segments[0];
}
