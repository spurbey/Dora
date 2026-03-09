import {
  AbsoluteFill,
  Easing,
  Img,
  Sequence,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import { useMemo } from 'react';
import {
  buildSceneMapContext,
  getPlaceImageUrl,
  pointAtProgress,
  pointsToPath,
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

function lerpPoint(a, b, t) {
  return {
    x: a.x + (b.x - a.x) * t,
    y: a.y + (b.y - a.y) * t,
  };
}

function buildCameraPlan(mapContext, width, height, sceneIndex) {
  const points = mapContext?.routePoints || [];
  const placePoint = mapContext?.placePoint || null;
  const center = { x: width / 2, y: height / 2 };
  const start = points[0] || placePoint || center;
  const end = points[points.length - 1] || placePoint || center;
  const emphasis = placePoint || pointAtProgress(points, 0.64) || center;
  const sceneBias = sceneIndex % 2 === 0 ? 1 : -1;

  return {
    focusA: lerpPoint(start, emphasis, 0.32),
    focusB: emphasis,
    focusC: lerpPoint(emphasis, end, 0.58),
    targetA: { x: width * (0.56 + sceneBias * 0.03), y: height * 0.62 },
    targetB: { x: width * (0.47 - sceneBias * 0.02), y: height * 0.6 },
    targetC: { x: width * (0.52 + sceneBias * 0.015), y: height * 0.57 },
    scaleA: 1.05,
    scaleB: 1.16,
    scaleC: 1.11,
  };
}

function RouteOverlay({ width, height, points, placePoint, progress, frame }) {
  const path = pointsToPath(points);
  if (!path) {
    return null;
  }

  const marker = pointAtProgress(points, progress);
  const pulse = 0.72 + 0.28 * Math.sin(frame * 0.28);
  const trailProgress = clamp(progress, 0.02, 1);
  const glowProgress = clamp(progress + 0.06, 0.03, 1);

  return (
    <AbsoluteFill pointerEvents="none">
      <svg
        viewBox={`0 0 ${width} ${height}`}
        style={{ width: '100%', height: '100%', opacity: 0.94 }}
      >
        <path
          d={path}
          fill="none"
          stroke="rgba(255,255,255,0.2)"
          strokeWidth="2.1"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <path
          d={path}
          pathLength="1"
          fill="none"
          stroke="rgba(249,211,122,0.42)"
          strokeWidth="7.4"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeDasharray={`${glowProgress} 1`}
        />
        <path
          d={path}
          pathLength="1"
          fill="none"
          stroke="#f9d37a"
          strokeWidth="3.2"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeDasharray={`${trailProgress} 1`}
        />
        {placePoint && (
          <>
            <circle
              cx={placePoint.x}
              cy={placePoint.y}
              r="8"
              fill="rgba(255,255,255,0.2)"
              stroke="rgba(255,255,255,0.55)"
              strokeWidth="1.2"
            />
            <circle cx={placePoint.x} cy={placePoint.y} r="3.5" fill="#ffffff" />
          </>
        )}
        <circle cx={marker.x} cy={marker.y} r={7.2 * pulse} fill="rgba(249,211,122,0.28)" />
        <circle cx={marker.x} cy={marker.y} r="5" fill="rgba(249,211,122,0.24)" />
        <circle cx={marker.x} cy={marker.y} r="3.1" fill="#ffffff" />
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

function CinematicScene({ snapshot, place, route, sceneIndex, fps, totalFrames, width, height }) {
  const frame = useCurrentFrame();
  const progress = totalFrames > 1 ? frame / (totalFrames - 1) : 0;
  const easedProgress = interpolate(progress, [0, 1], [0, 1], {
    easing: Easing.inOut(Easing.cubic),
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
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
  const imageUrl = getPlaceImageUrl(place);
  const nameSeed = (place?.name || 'Cinematic').split('').reduce((acc, c) => acc + c.charCodeAt(0), 0);
  const fallbackHue = nameSeed % 360;
  const mapContext = useMemo(
    () =>
      buildSceneMapContext({
        snapshot,
        route,
        place,
        width,
        height,
      }),
    [snapshot, route, place, width, height],
  );

  const routePoints = mapContext?.routePoints || [];
  const placePoint = mapContext?.placePoint || null;
  const routeVector = mapContext?.routeVector || { x: 0, y: 0 };
  const hasMap = Boolean(mapContext?.mapUrl);
  const cameraPlan = useMemo(
    () => buildCameraPlan(mapContext, width, height, sceneIndex),
    [mapContext, width, height, sceneIndex],
  );
  const maxMapDrift = 42;
  const routeDriftX = clamp(-routeVector.x * 0.12, -maxMapDrift, maxMapDrift);
  const routeDriftY = clamp(-routeVector.y * 0.12, -maxMapDrift, maxMapDrift);

  const focusX = interpolate(
    easedProgress,
    [0, 0.58, 1],
    [cameraPlan.focusA.x, cameraPlan.focusB.x, cameraPlan.focusC.x],
    { easing: Easing.inOut(Easing.cubic), extrapolateLeft: 'clamp', extrapolateRight: 'clamp' },
  );
  const focusY = interpolate(
    easedProgress,
    [0, 0.58, 1],
    [cameraPlan.focusA.y, cameraPlan.focusB.y, cameraPlan.focusC.y],
    { easing: Easing.inOut(Easing.cubic), extrapolateLeft: 'clamp', extrapolateRight: 'clamp' },
  );
  const targetX = interpolate(
    easedProgress,
    [0, 0.58, 1],
    [cameraPlan.targetA.x, cameraPlan.targetB.x, cameraPlan.targetC.x],
    { easing: Easing.inOut(Easing.cubic), extrapolateLeft: 'clamp', extrapolateRight: 'clamp' },
  );
  const targetY = interpolate(
    easedProgress,
    [0, 0.58, 1],
    [cameraPlan.targetA.y, cameraPlan.targetB.y, cameraPlan.targetC.y],
    { easing: Easing.inOut(Easing.cubic), extrapolateLeft: 'clamp', extrapolateRight: 'clamp' },
  );
  const mapScale = interpolate(
    easedProgress,
    [0, 0.58, 1],
    [cameraPlan.scaleA, cameraPlan.scaleB, cameraPlan.scaleC],
    { easing: Easing.inOut(Easing.cubic), extrapolateLeft: 'clamp', extrapolateRight: 'clamp' },
  );
  const mapTranslateX = clamp(targetX - focusX + routeDriftX * 0.35, -width * 0.24, width * 0.24);
  const mapTranslateY = clamp(targetY - focusY + routeDriftY * 0.35, -height * 0.2, height * 0.2);
  const photoScale = interpolate(easedProgress, [0, 1], [1.02, 1.1]);
  const photoTranslateX = interpolate(easedProgress, [0, 1], [0, panDirection * 30]);
  const routeProgress = interpolate(easedProgress, [0, 1], [0.02, 1], {
    easing: Easing.out(Easing.cubic),
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const labelOpacity = interpolate(easedProgress, [0, 0.18, 0.9, 1], [0.35, 1, 1, 0.72], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const labelLift = interpolate(easedProgress, [0, 1], [10, -2], {
    easing: Easing.inOut(Easing.quad),
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill style={{ opacity: sceneOpacity }}>
      {hasMap ? (
        <AbsoluteFill style={{ overflow: 'hidden' }}>
          <Img
            src={mapContext.mapUrl}
            style={{
              width: '100%',
              height: '100%',
              objectFit: 'cover',
              transform: `scale(${mapScale}) translate(${mapTranslateX}px, ${mapTranslateY}px)`,
              transformOrigin: 'center center',
            }}
          />
        </AbsoluteFill>
      ) : imageUrl ? (
        <AbsoluteFill style={{ overflow: 'hidden' }}>
          <Img
            src={imageUrl}
            style={{
              width: '100%',
              height: '100%',
              objectFit: 'cover',
              transform: `scale(${photoScale}) translateX(${photoTranslateX}px)`,
              transformOrigin: 'center center',
            }}
          />
        </AbsoluteFill>
      ) : (
        <AbsoluteFill style={{ background: `hsl(${fallbackHue}, 26%, 14%)` }} />
      )}

      {hasMap && imageUrl && (
        <AbsoluteFill style={{ overflow: 'hidden', opacity: 0.28 }}>
          <Img
            src={imageUrl}
            style={{
              width: '100%',
              height: '100%',
              objectFit: 'cover',
              transform: `scale(${photoScale}) translateX(${photoTranslateX}px)`,
              transformOrigin: 'center center',
            }}
          />
        </AbsoluteFill>
      )}

      <AbsoluteFill
        style={{
          background:
            'linear-gradient(to top, rgba(0,0,0,0.82) 0%, rgba(0,0,0,0.18) 50%, rgba(0,0,0,0.35) 100%)',
        }}
      />

      <AbsoluteFill
        style={{
          background:
            'linear-gradient(to right, rgba(0,0,0,0.38) 0%, rgba(0,0,0,0.1) 35%, rgba(0,0,0,0.28) 100%)',
        }}
      />
      <AbsoluteFill
        style={{
          background:
            'radial-gradient(120% 120% at 50% 50%, rgba(0,0,0,0) 45%, rgba(0,0,0,0.34) 100%)',
        }}
      />

      <RouteOverlay
        width={width}
        height={height}
        points={routePoints}
        placePoint={placePoint}
        progress={routeProgress}
        frame={frame}
      />

      <AbsoluteFill pointerEvents="none">
        <div style={{ height: LETTERBOX_HEIGHT, background: '#000000' }} />
        <div style={{ flex: 1 }} />
        <div style={{ height: LETTERBOX_HEIGHT, background: '#000000' }} />
      </AbsoluteFill>

      <AbsoluteFill
        style={{
          justifyContent: 'flex-end',
          padding: '0 32px 10%',
          transform: `translateY(${labelLift}px)`,
          opacity: labelOpacity,
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
  const { fps, durationInFrames, width, height } = useVideoConfig();
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
            snapshot={snapshot}
            place={segment.place}
            route={segment.route}
            sceneIndex={segment.index}
            fps={fps}
            totalFrames={segment.frames}
            width={width}
            height={height}
          />
        </Sequence>
      ))}

      <Sequence from={durationInFrames - outroFrames} durationInFrames={outroFrames}>
        <CinematicOutro fps={fps} />
      </Sequence>
    </AbsoluteFill>
  );
}
