export function isLngLat(value) {
  if (!value || typeof value !== 'object') return false;
  const lng = Number(value.lng);
  const lat = Number(value.lat);
  return Number.isFinite(lng) && Number.isFinite(lat);
}

export function isFrameIndex(value) {
  return Number.isInteger(value) && value >= 0;
}

export function isNormalized(value) {
  return typeof value === 'number' && Number.isFinite(value) && value >= 0 && value <= 1;
}
