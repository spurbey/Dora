import { clamp } from './geometry-math.js';

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

function travelBeatWeight(route) {
  const base = 1.6;
  const distanceMeters = estimateRouteDistanceMeters(route);
  const distanceKm = distanceMeters / 1000;
  const distanceBoost = clamp(Math.log10(distanceKm + 1) * 1.9, 0, 2.7);
  const mode = String(route?.transport_mode || '').toLowerCase();
  const modeBoost = mode === 'air' ? 0.9 : mode === 'train' ? 0.35 : 0;
  return base + distanceBoost + modeBoost;
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
  const safeRoutes = Array.isArray(routes) ? routes : [];
  const totalFrames = safeFrames(durationInFrames);
  if (safePlaces.length === 0 || totalFrames <= 0) return [];

  const numPlaces = safePlaces.length;
  const numRoutes = Math.min(safeRoutes.length, Math.max(0, numPlaces - 1));
  const beats = [];
  const specs = [];

  for (let i = 0; i < numPlaces; i++) {
    const arriveWeightSec = (i === 0 || i === numPlaces - 1) ? 2.4 : 1.8;
    beats.push(arriveWeightSec);
    specs.push({
      type: 'arrive',
      placeIndex: i,
      routeIndex: -1,
      place: safePlaces[i],
      route: null,
    });

    if (i < numRoutes) {
      beats.push(travelBeatWeight(safeRoutes[i]));
      specs.push({
        type: 'travel',
        placeIndex: i,
        routeIndex: i,
        place: null,
        route: safeRoutes[i],
      });
    }
  }

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
