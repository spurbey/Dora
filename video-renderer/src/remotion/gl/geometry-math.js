import { isLngLat } from './types.js';

export function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

export function lerp(a, b, t) {
  const n = clamp(t, 0, 1);
  return a + (b - a) * n;
}

export function lerpAngleDegShortest(aDeg, bDeg, t) {
  let delta = ((bDeg - aDeg + 540) % 360) - 180;
  if (!Number.isFinite(delta)) delta = 0;
  return aDeg + delta * clamp(t, 0, 1);
}

export function lerpLngShortest(aLng, bLng, t) {
  let delta = bLng - aLng;
  if (delta > 180) delta -= 360;
  if (delta < -180) delta += 360;
  return aLng + delta * clamp(t, 0, 1);
}

export function haversineMeters(a, b) {
  if (!isLngLat(a) || !isLngLat(b)) return 0;
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

export function cumulativePolylineMeters(points) {
  const safePoints = Array.isArray(points) ? points.filter(isLngLat) : [];
  if (safePoints.length === 0) return { cumulative: [], total: 0 };
  if (safePoints.length === 1) return { cumulative: [0], total: 0 };

  const cumulative = [0];
  let total = 0;
  for (let i = 1; i < safePoints.length; i++) {
    total += haversineMeters(safePoints[i - 1], safePoints[i]);
    cumulative.push(total);
  }
  return { cumulative, total };
}
