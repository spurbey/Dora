import {
  AbsoluteFill,
  Img,
  Sequence,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import {
  getPlaceImageUrl,
  resolveTimelinePlaces,
  resolveTimelineRoutes,
} from './render-data.js';

const INTRO_SEC = 2.2;
const OUTRO_SEC = 1.2;
const MIN_SCENE_SEC = 2.6;
const LETTERBOX_HEIGHT = '8%';

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

function getRouteCoordinates(route) {
  const geo = route?.route_geojson;
  if (!geo || geo.type !== 'LineString' || !Array.isArray(geo.coordinates)) {
    return [];
  }
  return geo.coordinates.filter(
    (c) => Array.isArray(c) && c.length >= 2 && Number.isFinite(c[0]) && Number.isFinite(c[1]),
  );
}

function normalizeCoordinates(coords, width = 100, height = 42) {
  if (coords.length < 2) {
    return [];
  }
  let minLng = Infinity;
  let maxLng = -Infinity;
  let minLat = Infinity;
  let maxLat = -Infinity;

  coords.forEach(([lng, lat]) => {
    minLng = Math.min(minLng, lng);
    maxLng = Math.max(maxLng, lng);
    minLat = Math.min(minLat, lat);
    maxLat = Math.max(maxLat, lat);
  });

  const lngSpan = maxLng - minLng || 1;
  const latSpan = maxLat - minLat || 1;

  return coords.map(([lng, lat]) => {
    const x = ((lng - minLng) / lngSpan) * width;
    // Invert Y so higher latitude is visually higher on screen.
    const y = height - ((lat - minLat) / latSpan) * height;
    return { x, y };
  });
}

function polylineLength(points) {
  if (points.length < 2) {
    return 0;
  }
  let total = 0;
  for (let i = 1; i < points.length; i += 1) {
    const dx = points[i].x - points[i - 1].x;
    const dy = points[i].y - points[i - 1].y;
    total += Math.hypot(dx, dy);
  }
  return total;
}

function pointAtProgress(points, progress) {
  if (points.length === 0) {
    return { x: 50, y: 21 };
  }
  if (points.length === 1) {
    return points[0];
  }
  const target = polylineLength(points) * clamp(progress, 0, 1);
  let walked = 0;
  for (let i = 1; i < points.length; i += 1) {
    const a = points[i - 1];
    const b = points[i];
    const seg = Math.hypot(b.x - a.x, b.y - a.y);
    if (walked + seg >= target) {
      const t = seg === 0 ? 0 : (target - walked) / seg;
      return {
        x: a.x + (b.x - a.x) * t,
        y: a.y + (b.y - a.y) * t,
      };
    }
    walked += seg;
  }
  return points[points.length - 1];
}

function pointsToPath(points) {
  if (points.length < 2) {
    return '';
  }
  return points
    .map((p, idx) => `${idx === 0 ? 'M' : 'L'} ${p.x.toFixed(2)} ${p.y.toFixed(2)}`)
    .join(' ');
}

function RouteOverlay({ route, progress }) {
  const coords = getRouteCoordinates(route);
  const points = normalizeCoordinates(coords);
  const path = pointsToPath(points);
  if (!path) {
    return null;
  }

  const marker = pointAtProgress(points, progress);

  return (
    <AbsoluteFill
      style={{
        justifyContent: 'flex-end',
        padding: '0 28px 26%',
      }}
    >
      <svg viewBox="0 0 100 42" style={{ width: '52%', opacity: 0.95 }}>
        <path
          d={path}
          fill="none"
          stroke="rgba(255,255,255,0.25)"
          strokeWidth="1.4"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <path
          d={path}
          pathLength="1"
          fill="none"
          stroke="#f9d37a"
          strokeWidth="2.1"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeDasharray={`${clamp(progress, 0.01, 1)} 1`}
        />
        <circle cx={marker.x} cy={marker.y} r="2.1" fill="#ffffff" />
      </svg>
    </AbsoluteFill>
  );
}

function CinematicIntro({ trip, fps }) {
  const frame = useCurrentFrame();
  const fadeFrames = Math.max(1, Math.floor(fps * 0.45));

  const opacity = interpolate(frame, [0, fadeFrames], [0, 1], {
    extrapolateRight: 'clamp',
  });
  const slide = interpolate(frame, [0, fadeFrames], [22, 0], {
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background:
          'radial-gradient(90% 120% at 70% 20%, #1f304a 0%, #151f32 45%, #0c111b 100%)',
        opacity,
        fontFamily: 'sans-serif',
      }}
    >
      <div
        style={{
          margin: 'auto',
          textAlign: 'center',
          transform: `translateY(${slide}px)`,
          padding: '0 32px',
        }}
      >
        <div
          style={{
            color: 'rgba(255,255,255,0.65)',
            letterSpacing: 5,
            fontSize: 16,
            textTransform: 'uppercase',
            marginBottom: 14,
          }}
        >
          Cinematic Journey
        </div>
        <div style={{ color: '#ffffff', fontSize: 58, fontWeight: 700, lineHeight: 1.1 }}>
          {trip.title || 'My Journey'}
        </div>
        {(trip.destination || trip.city) && (
          <div style={{ color: 'rgba(255,255,255,0.78)', fontSize: 24, marginTop: 12 }}>
            {trip.destination || trip.city}
          </div>
        )}
      </div>

      <AbsoluteFill pointerEvents="none">
        <div style={{ height: LETTERBOX_HEIGHT, background: '#000000' }} />
        <div style={{ flex: 1 }} />
        <div style={{ height: LETTERBOX_HEIGHT, background: '#000000' }} />
      </AbsoluteFill>
    </AbsoluteFill>
  );
}

function CinematicScene({ place, route, sceneIndex, fps, totalFrames }) {
  const frame = useCurrentFrame();
  const progress = totalFrames > 1 ? frame / (totalFrames - 1) : 0;
  const fadeFrames = Math.max(2, Math.floor(Math.min(totalFrames * 0.28, fps * 0.45)));

  const sceneOpacity = interpolate(
    frame,
    [0, fadeFrames, totalFrames - fadeFrames, totalFrames - 1],
    [0, 1, 1, 0],
    {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    },
  );

  const panDirection = sceneIndex % 2 === 0 ? -1 : 1;
  const scale = interpolate(progress, [0, 1], [1.02, 1.1]);
  const translateX = interpolate(progress, [0, 1], [0, panDirection * 32]);
  const imageUrl = getPlaceImageUrl(place);
  const nameSeed = (place?.name || 'Cinematic').split('').reduce((acc, c) => acc + c.charCodeAt(0), 0);
  const fallbackHue = nameSeed % 360;

  return (
    <AbsoluteFill style={{ opacity: sceneOpacity }}>
      {imageUrl ? (
        <AbsoluteFill style={{ overflow: 'hidden' }}>
          <Img
            src={imageUrl}
            style={{
              width: '100%',
              height: '100%',
              objectFit: 'cover',
              transform: `scale(${scale}) translateX(${translateX}px)`,
              transformOrigin: 'center center',
            }}
          />
        </AbsoluteFill>
      ) : (
        <AbsoluteFill style={{ background: `hsl(${fallbackHue}, 26%, 14%)` }} />
      )}

      <AbsoluteFill
        style={{
          background:
            'linear-gradient(to top, rgba(0,0,0,0.82) 0%, rgba(0,0,0,0.18) 50%, rgba(0,0,0,0.35) 100%)',
        }}
      />

      <RouteOverlay route={route} progress={progress} />

      <AbsoluteFill pointerEvents="none">
        <div style={{ height: LETTERBOX_HEIGHT, background: '#000000' }} />
        <div style={{ flex: 1 }} />
        <div style={{ height: LETTERBOX_HEIGHT, background: '#000000' }} />
      </AbsoluteFill>

      <AbsoluteFill
        style={{
          justifyContent: 'flex-end',
          padding: '0 32px 10%',
          fontFamily: 'sans-serif',
        }}
      >
        <div style={{ maxWidth: '75%' }}>
          <div
            style={{
              color: '#ffffff',
              fontSize: 40,
              fontWeight: 700,
              lineHeight: 1.1,
              textShadow: '0 2px 12px rgba(0,0,0,0.72)',
            }}
          >
            {place?.name || 'A Place'}
          </div>
          {(place?.destination || place?.address || place?.city) && (
            <div
              style={{
                color: 'rgba(255,255,255,0.82)',
                fontSize: 20,
                marginTop: 8,
                textShadow: '0 1px 8px rgba(0,0,0,0.65)',
              }}
            >
              {place.destination || place.address || place.city}
            </div>
          )}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
}

function CinematicOutro({ fps }) {
  const frame = useCurrentFrame();
  const fadeFrames = Math.max(1, Math.floor(fps * 0.4));
  const opacity = interpolate(frame, [0, fadeFrames], [0, 1], {
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(160deg, #0f1421 0%, #1a2740 60%, #0b111c 100%)',
        justifyContent: 'center',
        alignItems: 'center',
        opacity,
        fontFamily: 'sans-serif',
      }}
    >
      <div style={{ textAlign: 'center' }}>
        <div
          style={{
            color: 'rgba(255,255,255,0.6)',
            textTransform: 'uppercase',
            letterSpacing: 4,
            fontSize: 15,
            marginBottom: 12,
          }}
        >
          Story Captured
        </div>
        <div style={{ color: '#ffffff', fontSize: 52, fontWeight: 700, letterSpacing: 3 }}>
          Dora
        </div>
      </div>
    </AbsoluteFill>
  );
}

export function Cinematic({ snapshot = {} }) {
  const { fps, durationInFrames } = useVideoConfig();
  const trip = snapshot.trip || {};
  const places = resolveTimelinePlaces(snapshot);
  const routes = resolveTimelineRoutes(snapshot);

  const introFrames = Math.floor(INTRO_SEC * fps);
  const outroFrames = Math.floor(OUTRO_SEC * fps);
  const availableFrames = Math.max(0, durationInFrames - introFrames - outroFrames);

  const sceneSegments =
    places.length > 0
      ? places.map((place, i) => {
          const framesPerScene = Math.max(
            Math.floor(MIN_SCENE_SEC * fps),
            Math.floor(availableFrames / places.length),
          );
          return {
            place,
            route: routes[Math.min(i, Math.max(0, routes.length - 1))] || null,
            from: introFrames + i * framesPerScene,
            frames: framesPerScene,
            index: i,
          };
        })
      : [];

  return (
    <AbsoluteFill style={{ background: '#0a0a0a' }}>
      <Sequence from={0} durationInFrames={introFrames}>
        <CinematicIntro trip={trip} fps={fps} />
      </Sequence>

      {sceneSegments.map((segment) => (
        <Sequence key={segment.place?.id || segment.index} from={segment.from} durationInFrames={segment.frames}>
          <CinematicScene
            place={segment.place}
            route={segment.route}
            sceneIndex={segment.index}
            fps={fps}
            totalFrames={segment.frames}
          />
        </Sequence>
      ))}

      <Sequence from={durationInFrames - outroFrames} durationInFrames={outroFrames}>
        <CinematicOutro fps={fps} />
      </Sequence>
    </AbsoluteFill>
  );
}
