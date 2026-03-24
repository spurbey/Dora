export const CAMERA_LIMITS = {
  minZoom: 1,
  maxZoom: 18,
  minPitch: 0,
  maxPitch: 70,
  maxBearingDeltaPerFrame: 12,
};

export const EASING = {
  camera: 'easeInOutSine',
  route: 'easeOutCubic',
  marker: 'easeInOutSine',
  label: 'easeOutQuad',
  opacity: 'easeInOutSine',
};

export const SEAM_THRESHOLDS = {
  maxCameraJumpDeg: 0.0005,
  maxMarkerJumpPx1080: 3,
};

export const OVERLAY_SAFE_AREA = {
  leftPct: 0.04,
  rightPct: 0.92,
  topPct: 0.1,
  bottomPct: 0.85,
};

export const ROUTE_STYLE_DEFAULTS = {
  strokeWidth: 4,
  glowWidth: 8,
};
