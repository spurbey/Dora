import { clamp, lerp } from './geometry-math.js';

function normalizePoint(point) {
  if (!point || typeof point !== 'object') return null;
  const x = Number(point.x);
  const y = Number(point.y);
  if (!Number.isFinite(x) || !Number.isFinite(y)) return null;
  return { x, y };
}

function cumulativePolylineLength(points) {
  if (!Array.isArray(points) || points.length < 2) return { cumulative: [0], total: 0 };
  const cumulative = [0];
  let total = 0;
  for (let i = 1; i < points.length; i++) {
    const a = points[i - 1];
    const b = points[i];
    total += Math.hypot(b.x - a.x, b.y - a.y);
    cumulative.push(total);
  }
  return { cumulative, total };
}

export function buildAirArc(start, end, curvature = 0.3) {
  const startPt = normalizePoint(start);
  const endPt = normalizePoint(end);
  if (!startPt || !endPt) return null;
  const midX = (startPt.x + endPt.x) / 2;
  const midY = (startPt.y + endPt.y) / 2;
  const distance = Math.hypot(endPt.x - startPt.x, endPt.y - startPt.y);
  return {
    start: startPt,
    end: endPt,
    control: { x: midX, y: midY - distance * curvature },
  };
}

export function pointOnAirArc(arc, sNorm) {
  if (!arc || !arc.start || !arc.end || !arc.control) return null;
  const t = clamp(sNorm, 0, 1);
  const inv = 1 - t;
  return {
    x: inv * inv * arc.start.x + 2 * inv * t * arc.control.x + t * t * arc.end.x,
    y: inv * inv * arc.start.y + 2 * inv * t * arc.control.y + t * t * arc.end.y,
  };
}

export function buildRouteCurves(input) {
  const projectedRoutes = Array.isArray(input?.projectedRoutes) ? input.projectedRoutes : [];
  return projectedRoutes.map((pr) => {
    if (pr?.isArc && pr.startPoint && pr.endPoint) {
      const arc = buildAirArc(pr.startPoint, pr.endPoint);
      return {
        kind: 'arc',
        arc,
      };
    }

    const points = Array.isArray(pr?.points) ? pr.points.map(normalizePoint).filter(Boolean) : [];
    const { cumulative, total } = cumulativePolylineLength(points);
    return {
      kind: 'polyline',
      points,
      cumulative,
      total,
    };
  });
}

export function pointAtS(curve, sNorm) {
  if (!curve) return null;
  const s = clamp(sNorm, 0, 1);

  if (curve.kind === 'arc') {
    return pointOnAirArc(curve.arc, s);
  }

  if (curve.kind !== 'polyline' || !Array.isArray(curve.points) || curve.points.length === 0) {
    return null;
  }

  if (curve.points.length === 1 || !Array.isArray(curve.cumulative) || curve.total <= 0) {
    return curve.points[0];
  }

  const target = curve.total * s;
  let idx = 1;
  while (idx < curve.cumulative.length && curve.cumulative[idx] < target) {
    idx += 1;
  }
  const i1 = Math.min(idx, curve.points.length - 1);
  const i0 = Math.max(0, i1 - 1);
  const d0 = curve.cumulative[i0] ?? 0;
  const d1 = curve.cumulative[i1] ?? d0;
  const local = d1 > d0 ? (target - d0) / (d1 - d0) : 0;
  return {
    x: lerp(curve.points[i0].x, curve.points[i1].x, local),
    y: lerp(curve.points[i0].y, curve.points[i1].y, local),
  };
}

export function headingAtS(curve, sNorm, eps = 0.01) {
  const low = pointAtS(curve, Math.max(0, sNorm - eps));
  const high = pointAtS(curve, Math.min(1, sNorm + eps));
  if (!low || !high) return 0;
  return (Math.atan2(high.y - low.y, high.x - low.x) * 180) / Math.PI;
}
