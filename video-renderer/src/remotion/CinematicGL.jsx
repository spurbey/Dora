import {
  AbsoluteFill,
  continueRender,
  delayRender,
  Easing,
  Img,
  Sequence,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import { useEffect, useMemo, useRef, useState } from 'react';
import {
  airArcPath,
  buildGlobalMapContext,
  cardScreenPosition,
  getPlaceImageUrls,
  getRouteStyle,
  ICON_VIEWBOX,
  pointAtProgress,
  pointsToPath,
  pointOnArc,
  resolveTimelinePlaces,
  resolveTimelineRoutes,
  TRAVEL_MODE_ICONS,
} from './render-data.js';
import { buildRenderPlan, getFrameState } from './gl/render-plan-builder.js';
import { destroyMap, initMapWithGate } from './gl/map-init.js';
import { applyFrameToMap } from './gl/map-runtime.js';
import { resolveCardPlacement } from './gl/overlay-planner.js';
import { resolveTransportMode } from './gl/transport-mode.js';

const INTRO_SEC = 1.5;
const OUTRO_SEC = 1.0;
const LETTERBOX_HEIGHT = '7%';
const UI_FONT_STACK = '"Sora", "Avenir Next", "Segoe UI", sans-serif';

function clampNum(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function toScreenPoint(point, totalScale, translateX, translateY) {
  if (!point || !Number.isFinite(point.x) || !Number.isFinite(point.y)) return null;
  return {
    x: point.x * totalScale + translateX,
    y: point.y * totalScale + translateY,
  };
}

function buildOverlayRoutePolyline({
  placeIndex,
  projectedRoutes,
  totalScale,
  translateX,
  translateY,
}) {
  const routes = Array.isArray(projectedRoutes) ? projectedRoutes : [];
  if (!Number.isFinite(placeIndex) || routes.length === 0) return [];

  const incomingIndex = Math.max(0, placeIndex - 1);
  const outgoingIndex = Math.min(routes.length - 1, placeIndex);
  const candidatePool = [routes[incomingIndex], routes[outgoingIndex]].filter(Boolean);
  const candidate = candidatePool.find(
    (route) => Array.isArray(route.points) && route.points.length > 0,
  ) || candidatePool.find(
    (route) => route.isArc && route.startPoint && route.endPoint,
  ) || candidatePool[0];
  if (!candidate) return [];

  let mapPoints = [];
  if (Array.isArray(candidate.points) && candidate.points.length > 0) {
    mapPoints = candidate.points;
  } else if (candidate.isArc && candidate.startPoint && candidate.endPoint) {
    const samples = 16;
    mapPoints = Array.from({ length: samples }, (_, idx) => pointOnArc(
      candidate.startPoint,
      candidate.endPoint,
      idx / Math.max(1, samples - 1),
    )).filter(Boolean);
  }

  return mapPoints
    .map((point) => toScreenPoint(point, totalScale, translateX, translateY))
    .filter(Boolean);
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
        const mode = resolveTransportMode(projectedRoute.route);
        const isAir = projectedRoute.isArc || mode === 'air';
        const clampedProgress = Math.max(0, Math.min(1, drawProgress));
        const headPoint = projectedRoute.isArc
          ? pointOnArc(projectedRoute.startPoint, projectedRoute.endPoint, clampedProgress)
          : pointAtProgress(projectedRoute.points, clampedProgress);

        if (projectedRoute.isArc) {
          const arcD = airArcPath(projectedRoute.startPoint, projectedRoute.endPoint);
          if (!arcD) return null;
          return (
            <g key={`route-${routeIndex}`}>
              <path
                d={arcD}
                fill="none"
                stroke={isAir ? 'rgba(117,214,255,0.35)' : style.color}
                strokeWidth={style.width}
                strokeLinecap="round"
                strokeDasharray={style.dash || '6,4'}
                opacity={isAir ? 0.45 : 0.34}
              />
              <path
                d={arcD}
                pathLength="1"
                fill="none"
                stroke={style.color}
                strokeWidth={style.width + 7}
                strokeLinecap="round"
                strokeDasharray={`${clampedProgress} 1`}
                opacity={isAir ? 0.22 : 0.14}
              />
              <path
                d={arcD}
                pathLength="1"
                fill="none"
                stroke={style.color}
                strokeWidth={style.width + 2}
                strokeLinecap="round"
                strokeDasharray={`${clampedProgress} 1`}
                opacity={isAir ? 0.88 : 0.58}
              />
              {headPoint && (
                <>
                  <circle cx={headPoint.x} cy={headPoint.y} r={style.width * 2.5} fill={style.color} opacity={isAir ? 0.24 : 0.2} />
                  <circle cx={headPoint.x} cy={headPoint.y} r={style.width * 1.25} fill="#FFFFFF" opacity={isAir ? 0.9 : 0.65} />
                </>
              )}
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
                strokeDasharray={`${clampedProgress} 1`}
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
                strokeDasharray={`${clampedProgress} 1`}
                opacity={0.9}
              />
              {headPoint && (
                <>
                  <circle cx={headPoint.x} cy={headPoint.y} r={style.width * 2.4} fill={style.color} opacity={0.18} />
                  <circle cx={headPoint.x} cy={headPoint.y} r={style.width * 1.35} fill={style.color} opacity={0.7} />
                </>
              )}
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

  const mode = resolveTransportMode({ transport_mode: transportMode }, transportMode);
  const iconPath = TRAVEL_MODE_ICONS[mode] || TRAVEL_MODE_ICONS.car || '';
  const color = routeColor || '#66D9FF';
  const size = isAtPlace ? 52 : 64;
  const center = size / 2;
  const pulse = 0.9 + 0.1 * Math.sin(frame * 0.22);
  const iconSize = isAtPlace ? 20 : 30;

  let bobY = 0;
  let driftX = 0;
  let driftY = 0;
  let iconScale = 1;

  if (!isAtPlace) {
    if (mode === 'air') {
      bobY = Math.sin(frame * 0.1) * 1.1;
      iconScale = 1.08;
    } else if (mode === 'car' || mode === 'bus') {
      driftX = Math.sin(frame * 0.38) * 0.35;
      driftY = Math.cos(frame * 0.33) * 0.25;
    } else if (mode === 'train') {
      driftX = Math.sin(frame * 0.26) * 0.5;
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

function PlaceLabel({ place, opacity, frameWidth, frameHeight }) {
  if (!place || opacity <= 0) return null;
  const titleSize = clampNum(Math.round(frameWidth * 0.052), 30, 52);
  const subtitleSize = clampNum(Math.round(titleSize * 0.5), 16, 24);
  const panelWidth = clampNum(frameWidth * 0.78, 280, frameWidth * 0.9);
  const bottom = clampNum(frameHeight * 0.11, 72, 170);

  return (
    <div
      style={{
        position: 'absolute',
        bottom,
        left: '6%',
        width: panelWidth,
        pointerEvents: 'none',
        opacity,
        fontFamily: UI_FONT_STACK,
        zIndex: 18,
      }}
    >
      <div
        style={{
          display: 'inline-block',
          color: 'rgba(255,255,255,0.78)',
          background: 'rgba(9,12,18,0.52)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: 999,
          padding: '5px 12px',
          fontSize: clampNum(Math.round(subtitleSize * 0.72), 12, 16),
          letterSpacing: 1.6,
          textTransform: 'uppercase',
          marginBottom: 10,
          backdropFilter: 'blur(4px)',
        }}
      >
        Arrival
      </div>
      <div
        style={{
          color: '#ffffff',
          fontSize: titleSize,
          fontWeight: 700,
          lineHeight: 1.08,
          letterSpacing: -0.5,
          textShadow: '0 3px 18px rgba(0,0,0,0.78), 0 1px 5px rgba(0,0,0,0.72)',
        }}
      >
        {place.name || 'A Place'}
      </div>
      {(place.destination || place.city) && (
        <div
          style={{
            color: 'rgba(255,255,255,0.88)',
            fontSize: subtitleSize,
            marginTop: 6,
            textShadow: '0 1px 10px rgba(0,0,0,0.72)',
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
  projectedRoutes,
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
  const cardWidth = clampNum(Math.round(frameWidth * 0.22), 150, 210);
  const cardHeight = clampNum(Math.round(cardWidth * 1.18), 180, 250);
  const cardImageHeight = Math.round(cardHeight * 0.62);

  const anchor = {
    x: projectedPlace.x * totalScale + translateX,
    y: projectedPlace.y * totalScale + translateY,
  };
  const routePolyline = buildOverlayRoutePolyline({
    placeIndex: active.placeIndex,
    projectedRoutes,
    totalScale,
    translateX,
    translateY,
  });
  const planned = resolveCardPlacement({
    anchor,
    cardSize: { width: cardWidth, height: cardHeight },
    viewport: { width: frameWidth, height: frameHeight },
    routePolyline,
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
              width: cardWidth,
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
            <Img
              src={imageUrl}
              style={{ width: '100%', height: cardImageHeight, objectFit: 'cover', display: 'block' }}
            />
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
  const mapContainerRef = useRef(null);
  const gateHandleRef = useRef(null);
  const gateReleasedRef = useRef(false);
  const [mapRuntime, setMapRuntime] = useState(null);
  const [mapInitError, setMapInitError] = useState(null);

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

  if (gateHandleRef.current === null) {
    gateHandleRef.current = delayRender('cinematic_gl_map_init_gate');
  }

  const releaseGate = () => {
    if (gateReleasedRef.current || gateHandleRef.current === null) return;
    continueRender(gateHandleRef.current);
    gateReleasedRef.current = true;
  };

  const mapStyle = plan?.rendererConfig?.map_style || null;
  const styleRevision = plan?.rendererConfig?.style_revision || null;
  const styleHash = plan?.rendererConfig?.style_hash || null;
  const mapboxToken = plan?.rendererConfig?.mapbox_token || null;
  const enableNativeGl = Boolean(plan?.rendererConfig?.mapbox_gl_enabled);
  const strictNativeGl = Boolean(plan?.rendererConfig?.mapbox_gl_strict);

  useEffect(() => {
    let cancelled = false;
    let activeMap = null;
    let releaseMap = () => {};

    if (!mapCtx || !plan?.rendererConfig) {
      setMapRuntime(null);
      setMapInitError(null);
      releaseGate();
      return () => {};
    }

    (async () => {
      try {
        const initResult = await initMapWithGate({
          container: mapContainerRef.current,
          mapStyle,
          styleRevision,
          styleHash,
          mapboxToken,
          enableNativeGl,
          allowCompatFallback: !strictNativeGl,
          initialCenter: mapCtx?.viewport?.center
            ? [mapCtx.viewport.center.lng, mapCtx.viewport.center.lat]
            : [0, 0],
          initialZoom: Number.isFinite(mapCtx?.viewport?.zoom) ? mapCtx.viewport.zoom : 1,
          delayRenderLabel: 'cinematic_gl_map_init_gate',
        });

        activeMap = initResult?.map || null;
        releaseMap = typeof initResult?.release === 'function' ? initResult.release : () => {};

        if (cancelled) {
          releaseMap();
          destroyMap(activeMap);
          return;
        }

        setMapRuntime(activeMap);
        setMapInitError(null);
      } catch (err) {
        if (!cancelled) {
          setMapRuntime(null);
          setMapInitError(err?.message || 'map_init_failed');
        }
      } finally {
        if (!cancelled) {
          releaseGate();
        }
      }
    })();

    return () => {
      cancelled = true;
      try {
        releaseMap();
      } catch {
        // no-op
      }
      destroyMap(activeMap);
    };
  }, [mapCtx, mapStyle, styleRevision, styleHash, mapboxToken, enableNativeGl, strictNativeGl]);

  useEffect(() => () => {
    releaseGate();
  }, []);

  const frameState = useCinematicFrameState(plan, journeyFrame);
  const mapApplyState = useMemo(
    () => applyFrameToMap(mapRuntime, frameState, {
      mapContext: mapCtx || {},
      frameSize: { width, height },
    }),
    [mapRuntime, frameState, mapCtx, width, height],
  );

  const segments = plan.segments || [];
  const activeSegment = frameState.activeSegment;
  const markerState = mapApplyState.markerState || frameState.markerState;
  const labelState = frameState.overlay?.label || { place: null, opacity: 0 };
  const viewport = mapApplyState.viewport || {};
  const totalScale = viewport.totalScale || 1;
  const clampedTX = viewport.translateX || 0;
  const clampedTY = viewport.translateY || 0;
  const isNativeMap = mapRuntime?.mode === 'native_gl';
  const nativeOverlay = mapApplyState.nativeOverlay || null;
  const overlayProjectedRoutes = isNativeMap
    ? (nativeOverlay?.routes || [])
    : (mapCtx?.projectedRoutes || []);
  const overlayProjectedPlaces = isNativeMap
    ? (nativeOverlay?.places || [])
    : (mapCtx?.projectedPlaces || []);
  const overlayScale = isNativeMap ? 1 : totalScale;
  const overlayTX = isNativeMap ? 0 : clampedTX;
  const overlayTY = isNativeMap ? 0 : clampedTY;
  const overlayMapWidth = isNativeMap ? width : (mapCtx?.mapWidth || width);
  const overlayMapHeight = isNativeMap ? height : (mapCtx?.mapHeight || height);
  const markerScreen = markerState
    ? (isNativeMap
      ? (nativeOverlay?.marker
        ? { x: nativeOverlay.marker.x, y: nativeOverlay.marker.y }
        : null)
      : {
        x: markerState.mapX * totalScale + clampedTX,
        y: markerState.mapY * totalScale + clampedTY,
      })
    : null;

  if (mapInitError) {
    throw new Error(mapInitError);
  }

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
        ref={mapContainerRef}
        style={{
          position: 'absolute',
          inset: 0,
          opacity: isNativeMap ? 1 : 0,
          zIndex: isNativeMap ? 1 : 0,
          pointerEvents: 'none',
        }}
      />
      <div
        style={{
          position: 'absolute',
          inset: 0,
          overflow: 'hidden',
          zIndex: 2,
        }}
      >
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            width: overlayMapWidth,
            height: overlayMapHeight,
            transform: isNativeMap ? 'none' : `translate(${overlayTX}px, ${overlayTY}px) scale(${overlayScale})`,
            transformOrigin: '0 0',
            willChange: 'transform',
          }}
        >
          {!isNativeMap && (mapCtx.mapUrl ? (
            <Img src={mapCtx.mapUrl} style={{ width: mapCtx.mapWidth, height: mapCtx.mapHeight, display: 'block' }} />
          ) : (
            <div
              style={{
                width: mapCtx.mapWidth,
                height: mapCtx.mapHeight,
                background: 'linear-gradient(160deg, #0f1421 0%, #1a2740 60%, #0b111c 100%)',
              }}
            />
          ))}
          <RouteLayer
            projectedRoutes={overlayProjectedRoutes}
            routeProgressByIndex={mapApplyState.routeProgressByIndex || frameState.routeProgressByIndex}
            mapWidth={overlayMapWidth}
            mapHeight={overlayMapHeight}
          />
          <PlaceDots
            projectedPlaces={overlayProjectedPlaces}
            segments={segments}
            journeyFrame={journeyFrame}
            mapWidth={overlayMapWidth}
            mapHeight={overlayMapHeight}
            activeSegment={activeSegment}
          />
        </div>
      </div>

      {markerScreen && (
        <TravelMarker
          screenX={markerScreen.x}
          screenY={markerScreen.y}
          heading={markerState.heading}
          transportMode={resolveTransportMode(activeSegment?.route)}
          routeColor={activeSegment?.route ? getRouteStyle(activeSegment.route).color : '#66D9FF'}
          frame={frame}
          isAtPlace={markerState.isAtPlace}
        />
      )}

      <ArrivalPhotoCards
        activeArrivalSegment={frameState.overlay?.activeArrivalSegment || null}
        segments={segments}
        projectedPlaces={overlayProjectedPlaces}
        journeyFrame={journeyFrame}
        fps={fps}
        totalScale={overlayScale}
        translateX={overlayTX}
        translateY={overlayTY}
        frameWidth={width}
        frameHeight={height}
        projectedRoutes={overlayProjectedRoutes}
      />

      <Vignette />
      <PlaceLabel
        place={labelState.place}
        opacity={labelState.opacity}
        frameWidth={width}
        frameHeight={height}
      />
      <Letterbox />
    </AbsoluteFill>
  );
}

function IntroOverlay({ trip, fps }) {
  const frame = useCurrentFrame();
  const introTotalFrames = Math.max(1, Math.floor(INTRO_SEC * fps));
  const fadeOutStart = Math.max(1, Math.floor(fps * 0.9));
  const opacity = interpolate(frame, [0, fadeOutStart, introTotalFrames - 1], [1, 1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const translateY = interpolate(frame, [0, fadeOutStart, introTotalFrames - 1], [0, 0, -16], {
    easing: Easing.inOut(Easing.cubic),
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: 'radial-gradient(90% 120% at 70% 20%, #1f304a 0%, #152036 45%, #0c111b 100%)',
        opacity,
        fontFamily: UI_FONT_STACK,
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
        fontFamily: UI_FONT_STACK,
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
