import {
  AbsoluteFill,
  Easing,
  Img,
  Sequence,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import { useMemo } from 'react';
import {
  airArcPath,
  buildGlobalMapContext,
  cardScreenPosition,
  getPlaceImageUrls,
  getRouteStyle,
  ICON_VIEWBOX,
  pointsToPath,
  resolveTimelinePlaces,
  resolveTimelineRoutes,
  TRAVEL_MODE_ICONS,
} from './render-data.js';
import { buildRenderPlan, getFrameState } from './gl/render-plan-builder.js';
import { resolveCardPlacement } from './gl/overlay-planner.js';

const INTRO_SEC = 1.5;
const OUTRO_SEC = 1.0;
const LETTERBOX_HEIGHT = '7%';

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

function RouteLayer({
  projectedRoutes,
  routeProgressByIndex,
  mapWidth,
  mapHeight,
}) {
  return (
    <svg
      viewBox={`0 0 ${mapWidth} ${mapHeight}`}
      style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', pointerEvents: 'none' }}
    >
      {(projectedRoutes || []).map((projectedRoute, routeIndex) => {
        const drawProgress = routeProgressByIndex?.[routeIndex] ?? 0;
        if (drawProgress <= 0) return null;

        const style = getRouteStyle(projectedRoute.route);

        if (projectedRoute.isArc) {
          const arcD = airArcPath(projectedRoute.startPoint, projectedRoute.endPoint);
          if (!arcD) return null;
          return (
            <g key={`route-${routeIndex}`}>
              <path
                d={arcD}
                fill="none"
                stroke={style.color}
                strokeWidth={style.width}
                strokeLinecap="round"
                strokeDasharray="6,4"
                opacity={0.45}
              />
              <path
                d={arcD}
                pathLength="1"
                fill="none"
                stroke={style.color}
                strokeWidth={style.width + 2}
                strokeLinecap="round"
                strokeDasharray={`${drawProgress} 1`}
                opacity={0.35}
              />
            </g>
          );
        }

        const pathD = pointsToPath(projectedRoute.points);
        if (!pathD) return null;
        return (
          <g key={`route-${routeIndex}`}>
            <path
              d={pathD}
              pathLength="1"
              fill="none"
              stroke={style.color}
              strokeWidth={style.width + 4}
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeDasharray={`${drawProgress} 1`}
              opacity={0.2}
            />
            <path
              d={pathD}
              pathLength="1"
              fill="none"
              stroke={style.color}
              strokeWidth={style.width}
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeDasharray={`${drawProgress} 1`}
              opacity={0.9}
            />
          </g>
        );
      })}
    </svg>
  );
}

function PlaceDots({
  projectedPlaces,
  segments,
  journeyFrame,
  mapWidth,
  mapHeight,
  activeSegment,
}) {
  const visited = useMemo(() => {
    const set = new Set();
    (segments || []).forEach((segment) => {
      if (segment.type === 'arrive' && journeyFrame >= segment.startFrame) {
        set.add(segment.placeIndex);
      }
    });
    return set;
  }, [segments, journeyFrame]);

  return (
    <svg
      viewBox={`0 0 ${mapWidth} ${mapHeight}`}
      style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', pointerEvents: 'none' }}
    >
      {(projectedPlaces || []).map((projectedPlace, placeIndex) => {
        if (!visited.has(placeIndex)) return null;
        const isActive = activeSegment?.type === 'arrive' && activeSegment.placeIndex === placeIndex;
        const radius = isActive ? 6 : 4;
        return (
          <g key={`place-dot-${placeIndex}`}>
            <circle cx={projectedPlace.x} cy={projectedPlace.y} r={radius + 3} fill="rgba(255,255,255,0.15)" />
            <circle cx={projectedPlace.x} cy={projectedPlace.y} r={radius} fill="#ffffff" opacity={isActive ? 1 : 0.7} />
          </g>
        );
      })}
    </svg>
  );
}

function TravelMarker({
  screenX,
  screenY,
  heading,
  transportMode,
  routeColor,
  frame,
  isAtPlace,
}) {
  if (!Number.isFinite(screenX) || !Number.isFinite(screenY)) return null;

  const mode = (transportMode || '').toLowerCase();
  const iconPath = TRAVEL_MODE_ICONS[mode] || TRAVEL_MODE_ICONS.car || '';
  const color = routeColor || '#FFD700';
  const size = isAtPlace ? 52 : 64;
  const center = size / 2;
  const pulse = 0.75 + 0.25 * Math.sin(frame * 0.3);
  const iconSize = isAtPlace ? 20 : 30;

  let bobY = 0;
  let driftX = 0;
  let driftY = 0;
  let iconScale = 1;

  if (!isAtPlace) {
    if (mode === 'air') {
      bobY = Math.sin(frame * 0.18) * 3;
      iconScale = 1.05;
    } else if (mode === 'car' || mode === 'bus') {
      driftX = Math.sin(frame * 1.8) * 0.8;
      driftY = Math.cos(frame * 2.1) * 0.5;
    } else if (mode === 'train') {
      driftX = Math.sin(frame * 0.6) * 1.2;
    }
  }

  return (
    <div
      style={{
        position: 'absolute',
        left: screenX - center + driftX,
        top: screenY - center + bobY + driftY,
        width: size,
        height: size,
        pointerEvents: 'none',
        zIndex: 20,
        filter: 'drop-shadow(0 2px 8px rgba(0,0,0,0.5))',
      }}
    >
      <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
        <circle cx={center} cy={center} r={(center - 2) * pulse} fill={color} opacity={0.15} />
        <circle cx={center} cy={center} r={center - 6} fill={color} opacity={0.92} />
        <circle cx={center} cy={center} r={center - 6} fill="none" stroke="#ffffff" strokeWidth={2} opacity={0.6} />
        {isAtPlace ? (
          <g transform={`translate(${center - 7}, ${center - 10})`}>
            <path
              d="M7 0C3.13 0 0 3.13 0 7c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5a2.5 2.5 0 1 1 0-5 2.5 2.5 0 0 1 0 5z"
              fill="#ffffff"
              opacity={0.95}
            />
          </g>
        ) : (
          <g
            transform={`translate(${center}, ${center}) rotate(${heading}) translate(${-iconSize / 2}, ${-iconSize / 2}) scale(${(iconSize / ICON_VIEWBOX) * iconScale})`}
          >
            <path d={iconPath} fill="#ffffff" fillRule="evenodd" opacity={0.95} />
          </g>
        )}
      </svg>
    </div>
  );
}

function Vignette() {
  return (
    <AbsoluteFill style={{ pointerEvents: 'none' }}>
      <AbsoluteFill
        style={{
          background: 'radial-gradient(ellipse 130% 130% at 50% 50%, rgba(0,0,0,0) 40%, rgba(0,0,0,0.45) 100%)',
        }}
      />
      <AbsoluteFill
        style={{
          background: 'linear-gradient(to top, rgba(0,0,0,0.5) 0%, rgba(0,0,0,0) 30%)',
        }}
      />
    </AbsoluteFill>
  );
}

function Letterbox() {
  return (
    <AbsoluteFill style={{ pointerEvents: 'none' }}>
      <div style={{ height: LETTERBOX_HEIGHT, background: '#000000' }} />
      <div style={{ flex: 1 }} />
      <div style={{ height: LETTERBOX_HEIGHT, background: '#000000' }} />
    </AbsoluteFill>
  );
}

function PlaceLabel({ place, opacity }) {
  if (!place || opacity <= 0) return null;
  return (
    <div
      style={{
        position: 'absolute',
        bottom: '12%',
        left: '6%',
        right: '6%',
        pointerEvents: 'none',
        opacity,
        fontFamily: 'sans-serif',
      }}
    >
      <div
        style={{
          color: '#ffffff',
          fontSize: 36,
          fontWeight: 700,
          lineHeight: 1.15,
          textShadow: '0 2px 16px rgba(0,0,0,0.8), 0 1px 4px rgba(0,0,0,0.6)',
        }}
      >
        {place.name || 'A Place'}
      </div>
      {(place.destination || place.city) && (
        <div
          style={{
            color: 'rgba(255,255,255,0.8)',
            fontSize: 18,
            marginTop: 6,
            textShadow: '0 1px 8px rgba(0,0,0,0.7)',
          }}
        >
          {place.destination || place.city}
        </div>
      )}
    </div>
  );
}

function ArrivalPhotoCards({
  activeArrivalSegment,
  segments,
  projectedPlaces,
  journeyFrame,
  fps,
  totalScale,
  translateX,
  translateY,
  frameWidth,
  frameHeight,
}) {
  const derivedActiveArrivalSegment = useMemo(
    () => (segments || []).find(
      (segment) => segment.type === 'arrive'
        && journeyFrame >= segment.startFrame
        && journeyFrame <= segment.endFrame,
    ) || null,
    [segments, journeyFrame],
  );

  const active = activeArrivalSegment || derivedActiveArrivalSegment;
  if (!active) return null;
  const projectedPlace = projectedPlaces?.[active.placeIndex];
  if (!projectedPlace) return null;

  const imageUrls = getPlaceImageUrls(projectedPlace.place, 3);
  if (imageUrls.length === 0) return null;

  const segmentFrames = active.endFrame - active.startFrame + 1;
  const localFrame = journeyFrame - active.startFrame;

  const anchor = {
    x: projectedPlace.x * totalScale + translateX,
    y: projectedPlace.y * totalScale + translateY,
  };
  const planned = resolveCardPlacement({
    anchor,
    cardSize: { width: 170, height: 200 },
    viewport: { width: frameWidth, height: frameHeight },
    routePolyline: [],
  });
  const fallback = cardScreenPosition(
    projectedPlace.x,
    projectedPlace.y,
    totalScale,
    translateX,
    translateY,
    frameWidth,
    frameHeight,
  );
  const cardPos = planned || fallback;

  return (
    <div
      style={{
        position: 'absolute',
        left: cardPos.x,
        top: cardPos.y,
        display: 'flex',
        alignItems: 'flex-end',
        pointerEvents: 'none',
        zIndex: 10,
      }}
    >
      {imageUrls.map((imageUrl, idx) => {
        const stagger = idx * Math.floor(fps * 0.12);
        if (localFrame < stagger) return null;

        const enter = spring({
          frame: localFrame - stagger,
          fps,
          config: { damping: 12, stiffness: 170, mass: 0.8 },
          durationInFrames: Math.max(1, Math.floor(fps * 0.5)),
        });
        const exitStart = Math.max(1, segmentFrames - Math.floor(fps * 0.35));
        const exitProgress = interpolate(
          localFrame,
          [exitStart, segmentFrames - 1],
          [0, 1],
          { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' },
        );
        const scale = interpolate(enter, [0, 1], [0.85, 1])
          * interpolate(exitProgress, [0, 1], [1, 0.75]);
        const opacity = interpolate(exitProgress, [0, 1], [1, 0]);
        const rotation = imageUrls.length === 1 ? 0 : (idx - (imageUrls.length - 1) / 2) * 4;

        return (
          <div
            key={`${active.placeIndex}-${idx}`}
            style={{
              width: 160,
              borderRadius: 10,
              overflow: 'hidden',
              border: '2px solid rgba(255,255,255,0.25)',
              boxShadow: '0 6px 28px rgba(0,0,0,0.55), 0 2px 8px rgba(0,0,0,0.3)',
              transform: `scale(${scale}) rotate(${rotation}deg)`,
              transformOrigin: 'bottom center',
              opacity,
              marginLeft: idx > 0 ? -30 : 0,
            }}
          >
            <Img src={imageUrl} style={{ width: '100%', height: 120, objectFit: 'cover', display: 'block' }} />
          </div>
        );
      })}
    </div>
  );
}

function MapJourney({
  snapshot,
  places,
  routes,
  journeyFrames,
  fps,
  width,
  height,
  globalFrameOffset,
}) {
  const frame = useCurrentFrame();
  const journeyFrame = frame - globalFrameOffset;

  const mapCtx = useMemo(
    () => buildGlobalMapContext({ snapshot, width, height }),
    [snapshot, width, height],
  );

  const plan = useMemo(
    () => buildRenderPlan({
      snapshot,
      places,
      routes,
      fps,
      durationInFrames: journeyFrames,
      projectedRoutes: mapCtx?.projectedRoutes || [],
      projectedPlaces: mapCtx?.projectedPlaces || [],
      width,
      height,
    }),
    [snapshot, places, routes, fps, journeyFrames, mapCtx, width, height],
  );

  const frameState = useCinematicFrameState(plan, journeyFrame);
  const segments = plan.segments || [];
  const activeSegment = frameState.activeSegment;
  const markerState = frameState.markerState;
  const labelState = frameState.overlay?.label || { place: null, opacity: 0 };
  const plannedCamera = frameState.camera;

  const cameraScale = plannedCamera?.scale || 1;
  const focusX = plannedCamera?.center?.x ?? markerState?.mapX ?? (mapCtx ? mapCtx.mapWidth / 2 : width / 2);
  const focusY = plannedCamera?.center?.y ?? markerState?.mapY ?? (mapCtx ? mapCtx.mapHeight / 2 : height / 2);

  const baseScale = mapCtx ? Math.max(width / mapCtx.mapWidth, height / mapCtx.mapHeight) : 1;
  const totalScale = baseScale * cameraScale;
  const translateX = width / 2 - focusX * totalScale;
  const translateY = height / 2 - focusY * totalScale;

  const scaledMapW = mapCtx ? mapCtx.mapWidth * totalScale : width;
  const scaledMapH = mapCtx ? mapCtx.mapHeight * totalScale : height;
  const clampedTX = clamp(translateX, width - scaledMapW, 0);
  const clampedTY = clamp(translateY, height - scaledMapH, 0);

  if (!mapCtx || (mapCtx.projectedPlaces || []).length === 0) {
    return (
      <AbsoluteFill style={{ background: 'linear-gradient(160deg, #0f1421 0%, #1a2740 60%, #0b111c 100%)' }}>
        <Vignette />
        <Letterbox />
      </AbsoluteFill>
    );
  }

  return (
    <AbsoluteFill style={{ background: '#0a0e14' }}>
      <div
        style={{
          position: 'absolute',
          inset: 0,
          overflow: 'hidden',
        }}
      >
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            width: mapCtx.mapWidth,
            height: mapCtx.mapHeight,
            transform: `translate(${clampedTX}px, ${clampedTY}px) scale(${totalScale})`,
            transformOrigin: '0 0',
            willChange: 'transform',
          }}
        >
          {mapCtx.mapUrl ? (
            <Img src={mapCtx.mapUrl} style={{ width: mapCtx.mapWidth, height: mapCtx.mapHeight, display: 'block' }} />
          ) : (
            <div
              style={{
                width: mapCtx.mapWidth,
                height: mapCtx.mapHeight,
                background: 'linear-gradient(160deg, #0f1421 0%, #1a2740 60%, #0b111c 100%)',
              }}
            />
          )}
          <RouteLayer
            projectedRoutes={mapCtx.projectedRoutes}
            routeProgressByIndex={frameState.routeProgressByIndex}
            mapWidth={mapCtx.mapWidth}
            mapHeight={mapCtx.mapHeight}
          />
          <PlaceDots
            projectedPlaces={mapCtx.projectedPlaces}
            segments={segments}
            journeyFrame={journeyFrame}
            mapWidth={mapCtx.mapWidth}
            mapHeight={mapCtx.mapHeight}
            activeSegment={activeSegment}
          />
        </div>
      </div>

      {markerState && (
        <TravelMarker
          screenX={markerState.mapX * totalScale + clampedTX}
          screenY={markerState.mapY * totalScale + clampedTY}
          heading={markerState.heading}
          transportMode={activeSegment?.route?.transport_mode || ''}
          routeColor={activeSegment?.route ? getRouteStyle(activeSegment.route).color : '#FFD700'}
          frame={frame}
          isAtPlace={markerState.isAtPlace}
        />
      )}

      <ArrivalPhotoCards
        activeArrivalSegment={frameState.overlay?.activeArrivalSegment || null}
        segments={segments}
        projectedPlaces={mapCtx.projectedPlaces}
        journeyFrame={journeyFrame}
        fps={fps}
        totalScale={totalScale}
        translateX={clampedTX}
        translateY={clampedTY}
        frameWidth={width}
        frameHeight={height}
      />

      <Vignette />
      <PlaceLabel place={labelState.place} opacity={labelState.opacity} />
      <Letterbox />
    </AbsoluteFill>
  );
}

function IntroOverlay({ trip, fps }) {
  const frame = useCurrentFrame();
  const fadeFrames = Math.max(1, Math.floor(fps * 0.4));
  const opacity = interpolate(frame, [0, fadeFrames], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const translateY = interpolate(frame, [0, fadeFrames], [20, 0], {
    easing: Easing.out(Easing.cubic),
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: 'radial-gradient(90% 120% at 70% 20%, rgba(31,48,74,0.88) 0%, rgba(21,31,50,0.92) 45%, rgba(12,17,27,0.95) 100%)',
        opacity,
        fontFamily: 'sans-serif',
      }}
    >
      <div
        style={{
          margin: 'auto',
          textAlign: 'center',
          transform: `translateY(${translateY}px)`,
          padding: '0 32px',
        }}
      >
        <div
          style={{
            color: 'rgba(255,255,255,0.6)',
            letterSpacing: 5,
            fontSize: 15,
            textTransform: 'uppercase',
            marginBottom: 14,
          }}
        >
          Cinematic Journey
        </div>
        <div style={{ color: '#ffffff', fontSize: 52, fontWeight: 700, lineHeight: 1.1 }}>
          {trip.title || 'My Journey'}
        </div>
        {(trip.destination || trip.city) && (
          <div style={{ color: 'rgba(255,255,255,0.75)', fontSize: 22, marginTop: 10 }}>
            {trip.destination || trip.city}
          </div>
        )}
      </div>
      <Letterbox />
    </AbsoluteFill>
  );
}

function OutroOverlay({ fps }) {
  const frame = useCurrentFrame();
  const fadeFrames = Math.max(1, Math.floor(fps * 0.35));
  const opacity = interpolate(frame, [0, fadeFrames], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(160deg, rgba(15,20,33,0.95) 0%, rgba(26,39,64,0.95) 60%, rgba(11,17,28,0.95) 100%)',
        justifyContent: 'center',
        alignItems: 'center',
        opacity,
        fontFamily: 'sans-serif',
      }}
    >
      <div style={{ textAlign: 'center' }}>
        <div
          style={{
            color: 'rgba(255,255,255,0.55)',
            textTransform: 'uppercase',
            letterSpacing: 4,
            fontSize: 14,
            marginBottom: 10,
          }}
        >
          Story Captured
        </div>
        <div style={{ color: '#ffffff', fontSize: 48, fontWeight: 700, letterSpacing: 3 }}>
          Dora
        </div>
      </div>
    </AbsoluteFill>
  );
}

export function useCinematicPlan({
  snapshot = {},
  width,
  height,
  fps,
  durationInFrames,
}) {
  const places = useMemo(() => resolveTimelinePlaces(snapshot), [snapshot]);
  const routes = useMemo(() => resolveTimelineRoutes(snapshot), [snapshot]);
  const mapCtx = useMemo(
    () => buildGlobalMapContext({ snapshot, width, height }),
    [snapshot, width, height],
  );

  return useMemo(
    () => buildRenderPlan({
      snapshot,
      places,
      routes,
      fps,
      durationInFrames,
      projectedRoutes: mapCtx?.projectedRoutes || [],
      projectedPlaces: mapCtx?.projectedPlaces || [],
      width,
      height,
    }),
    [snapshot, places, routes, fps, durationInFrames, mapCtx, width, height],
  );
}

export function useCinematicFrameState(plan, frame) {
  return useMemo(() => getFrameState(plan, frame), [plan, frame]);
}

export function CinematicGL({ snapshot = {} }) {
  const { fps, durationInFrames, width, height } = useVideoConfig();
  const trip = snapshot.trip || {};
  const places = resolveTimelinePlaces(snapshot);
  const routes = resolveTimelineRoutes(snapshot);

  const introFrames = Math.floor(INTRO_SEC * fps);
  const outroFrames = Math.floor(OUTRO_SEC * fps);
  const journeyFrames = Math.max(0, durationInFrames - introFrames - outroFrames);

  return (
    <AbsoluteFill style={{ background: '#0a0a0a' }}>
      <MapJourney
        snapshot={snapshot}
        places={places}
        routes={routes}
        journeyFrames={journeyFrames}
        fps={fps}
        width={width}
        height={height}
        globalFrameOffset={introFrames}
      />
      <Sequence from={0} durationInFrames={introFrames}>
        <IntroOverlay trip={trip} fps={fps} />
      </Sequence>
      <Sequence from={durationInFrames - outroFrames} durationInFrames={outroFrames}>
        <OutroOverlay fps={fps} />
      </Sequence>
    </AbsoluteFill>
  );
}
