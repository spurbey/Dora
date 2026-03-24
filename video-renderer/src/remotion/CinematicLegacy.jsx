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
  buildJourneyTimeline,
  cardScreenPosition,
  getHeadingAtProgress,
  getPlaceImageUrls,
  getRouteStyle,
  ICON_VIEWBOX,
  pointAtProgress,
  pointOnArc,
  pointsToPath,
  resolveTimelinePlaces,
  resolveTimelineRoutes,
  TRAVEL_MODE_ICONS,
} from './render-data.js';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------
const INTRO_SEC = 1.5;
const OUTRO_SEC = 1.0;
const LETTERBOX_HEIGHT = '7%';
// Camera zoom per segment type. baseScale ≈ 1.0 with OVERSIZE 2.5.
const CAMERA_SCALE_GROUND = 4.0;   // tight follow on road — see the city
const CAMERA_SCALE_AIR = 2.0;      // wider for flight arcs
const CAMERA_SCALE_ARRIVE = 5.0;   // zoomed into place

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

// ---------------------------------------------------------------------------
// computeCameraScale — returns the zoom scale for the current frame.
// Camera POSITION is handled separately (always follows the marker).
// Only the zoom level transitions between segments.
// ---------------------------------------------------------------------------
function computeCameraScale(segments, journeyFrame) {
  if (segments.length === 0) return 1;

  const seg = findActiveSegment(segments, journeyFrame);
  if (!seg) return 1;

  function scaleForSegment(s) {
    if (s.type === 'arrive') return CAMERA_SCALE_ARRIVE;
    const mode = (s.route?.transport_mode || '').toLowerCase();
    return mode === 'air' ? CAMERA_SCALE_AIR : CAMERA_SCALE_GROUND;
  }

  const targetScale = scaleForSegment(seg);

  // Smooth scale transition at segment boundaries (first 20% of segment).
  const segIdx = segments.indexOf(seg);
  if (segIdx > 0) {
    const segFrames = seg.endFrame - seg.startFrame + 1;
    const easeWindow = Math.max(4, Math.floor(segFrames * 0.2));
    const framesIn = journeyFrame - seg.startFrame;
    if (framesIn < easeWindow) {
      const prevScale = scaleForSegment(segments[segIdx - 1]);
      const t = interpolate(framesIn, [0, easeWindow], [0, 1], {
        easing: Easing.inOut(Easing.sin),
        extrapolateLeft: 'clamp',
        extrapolateRight: 'clamp',
      });
      return prevScale + (targetScale - prevScale) * t;
    }
  }

  return targetScale;
}

// ---------------------------------------------------------------------------
// findActiveSegment — returns the journey segment active at `frame`
// ---------------------------------------------------------------------------
function findActiveSegment(segments, frame) {
  for (let i = segments.length - 1; i >= 0; i--) {
    if (frame >= segments[i].startFrame) return segments[i];
  }
  return segments[0] || null;
}

// ---------------------------------------------------------------------------
// RouteTrail — SVG progressive route drawing
// ---------------------------------------------------------------------------
function RouteTrail({ projectedRoutes, segments, journeyFrame, mapWidth, mapHeight }) {
  // Determine which route segments are completed, active, or future.
  const activeSegment = findActiveSegment(segments, journeyFrame);

  return (
    <svg
      viewBox={`0 0 ${mapWidth} ${mapHeight}`}
      style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%', pointerEvents: 'none' }}
    >
      {projectedRoutes.map((pr, idx) => {
        const style = getRouteStyle(pr.route);
        const travelSeg = segments.find((s) => s.type === 'travel' && s.routeIndex === idx);

        // Determine draw progress for this route.
        let drawProgress = 0;
        if (!travelSeg) {
          // No travel segment allocated (excess routes) — don't draw.
          return null;
        }
        if (journeyFrame >= travelSeg.endFrame) {
          drawProgress = 1; // Fully drawn (past segment).
        } else if (journeyFrame >= travelSeg.startFrame) {
          const segFrames = travelSeg.endFrame - travelSeg.startFrame + 1;
          const local = (journeyFrame - travelSeg.startFrame) / Math.max(1, segFrames - 1);
          drawProgress = interpolate(local, [0, 1], [0.01, 1], {
            easing: Easing.inOut(Easing.cubic),
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp',
          });
        }
        // Future route — drawProgress stays 0.
        if (drawProgress <= 0) return null;

        // Air routes: curved arc — show full dashed arc, progressive glow.
        if (pr.isArc) {
          const start = pr.startPoint;
          const end = pr.endPoint;
          if (!start || !end) return null;
          const arcD = airArcPath(start, end);
          if (!arcD) return null;
          return (
            <g key={`route-${idx}`}>
              {/* Full dashed arc (flight path visual) */}
              <path
                d={arcD}
                fill="none"
                stroke={style.color}
                strokeWidth={style.width}
                strokeLinecap="round"
                strokeDasharray="6,4"
                opacity={0.5}
              />
              {/* Progressive solid glow showing traveled portion */}
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

        // Ground routes: polyline with progressive draw.
        const pathD = pointsToPath(pr.points);
        if (!pathD) return null;

        return (
          <g key={`route-${idx}`}>
            {/* Glow layer */}
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
            {/* Main trail — always progressive solid draw */}
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

// ---------------------------------------------------------------------------
// PlaceDots — small dots at each place on the map
// ---------------------------------------------------------------------------
function PlaceDots({ projectedPlaces, mapWidth, mapHeight, segments, journeyFrame }) {
  return (
    <svg
      viewBox={`0 0 ${mapWidth} ${mapHeight}`}
      style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%', pointerEvents: 'none' }}
    >
      {projectedPlaces.map((pp, idx) => {
        // Only show dots for places already visited.
        const arrSeg = segments.find((s) => s.type === 'arrive' && s.placeIndex === idx);
        if (!arrSeg || journeyFrame < arrSeg.startFrame) return null;
        const isActive = arrSeg && journeyFrame >= arrSeg.startFrame && journeyFrame <= arrSeg.endFrame;
        const radius = isActive ? 6 : 4;
        return (
          <g key={`dot-${idx}`}>
            <circle cx={pp.x} cy={pp.y} r={radius + 3} fill="rgba(255,255,255,0.15)" />
            <circle cx={pp.x} cy={pp.y} r={radius} fill="#ffffff" opacity={isActive ? 1 : 0.7} />
          </g>
        );
      })}
    </svg>
  );
}

// ---------------------------------------------------------------------------
// TravelMarker — screen-space vehicle marker with mode-specific animation
// ---------------------------------------------------------------------------
function TravelMarker({ screenX, screenY, heading, frame, isAtPlace, transportMode, routeColor }) {
  if (screenX == null || screenY == null) return null;

  const mode = (transportMode || '').toLowerCase();
  const color = routeColor || '#FFD700';
  const iconPath = TRAVEL_MODE_ICONS[mode] || TRAVEL_MODE_ICONS.car || '';
  const VB = ICON_VIEWBOX; // 24

  // --- Mode-specific micro-animations ---
  let bobY = 0;
  let vibrateX = 0;
  let vibrateY = 0;
  let extraScale = 1;

  if (!isAtPlace) {
    if (mode === 'air') {
      // Gentle vertical bob for flying
      bobY = Math.sin(frame * 0.18) * 3;
      extraScale = 1.05;
    } else if (mode === 'car' || mode === 'bus') {
      // Subtle rumble for ground vehicles
      vibrateX = (Math.sin(frame * 1.8) * 0.8);
      vibrateY = (Math.cos(frame * 2.1) * 0.5);
    } else if (mode === 'train') {
      // Gentle sway for train
      vibrateX = Math.sin(frame * 0.6) * 1.2;
    }
  }

  const SIZE = isAtPlace ? 52 : 64;
  const cx = SIZE / 2;
  const cy = SIZE / 2;
  const pulse = 0.75 + 0.25 * Math.sin(frame * 0.3);
  const ICON_SIZE = isAtPlace ? 20 : 30;

  return (
    <div
      style={{
        position: 'absolute',
        left: screenX - cx + vibrateX,
        top: screenY - cy + bobY + vibrateY,
        width: SIZE,
        height: SIZE,
        pointerEvents: 'none',
        zIndex: 20,
        filter: `drop-shadow(0 2px 8px rgba(0,0,0,0.5))`,
      }}
    >
      <svg width={SIZE} height={SIZE} viewBox={`0 0 ${SIZE} ${SIZE}`}>
        {/* Outer glow ring */}
        <circle cx={cx} cy={cy} r={(cx - 2) * pulse} fill={color} opacity={0.15} />
        {/* Colored background circle */}
        <circle cx={cx} cy={cy} r={cx - 6} fill={color} opacity={0.92} />
        <circle cx={cx} cy={cy} r={cx - 6} fill="none" stroke="#ffffff" strokeWidth={2} opacity={0.6} />

        {isAtPlace ? (
          /* Location pin icon when at a place */
          <g transform={`translate(${cx - 7}, ${cx - 10})`}>
            <path
              d="M7 0C3.13 0 0 3.13 0 7c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5a2.5 2.5 0 1 1 0-5 2.5 2.5 0 0 1 0 5z"
              fill="#ffffff"
              opacity="0.95"
            />
          </g>
        ) : (
          /* Transport mode icon — rotated to heading */
          <g transform={`translate(${cx}, ${cy}) rotate(${heading}) translate(${-ICON_SIZE / 2}, ${-ICON_SIZE / 2}) scale(${(ICON_SIZE / VB) * extraScale})`}>
            <path d={iconPath} fill="#ffffff" fillRule="evenodd" opacity="0.95" />
          </g>
        )}
      </svg>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Vignette
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// PhotoCard — single photo card with spring enter / fade exit
// ---------------------------------------------------------------------------
function PhotoCard({ imageUrl, fps, localFrame, totalFrames, index, totalCards }) {
  if (!imageUrl) return null;

  const enterDuration = Math.floor(fps * 0.5);
  const exitStart = Math.max(enterDuration + 1, totalFrames - Math.floor(fps * 0.35));

  // Spring scale for enter.
  const enterScale = spring({
    frame: localFrame,
    fps,
    config: { damping: 12, stiffness: 170, mass: 0.8 },
    durationInFrames: enterDuration,
  });

  // Exit fade + scale.
  const exitProgress = localFrame >= exitStart
    ? interpolate(localFrame, [exitStart, totalFrames - 1], [0, 1], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' })
    : 0;
  const exitScale = interpolate(exitProgress, [0, 1], [1, 0.6]);
  const exitOpacity = interpolate(exitProgress, [0, 1], [1, 0]);

  const scale = enterScale * exitScale;
  const opacity = exitOpacity;

  // Stagger entry for multiple cards.
  const staggerDelay = index * Math.floor(fps * 0.12);
  if (localFrame < staggerDelay) return null;

  // Fan rotation for multi-card layout.
  const rotation = totalCards === 1 ? 0 : (index - (totalCards - 1) / 2) * 4;

  return (
    <div
      style={{
        width: 160,
        borderRadius: 10,
        overflow: 'hidden',
        boxShadow: '0 6px 28px rgba(0,0,0,0.55), 0 2px 8px rgba(0,0,0,0.3)',
        border: '2px solid rgba(255,255,255,0.25)',
        transform: `scale(${scale}) rotate(${rotation}deg)`,
        opacity,
        transformOrigin: 'bottom center',
        marginLeft: index > 0 ? -30 : 0,
      }}
    >
      <Img
        src={imageUrl}
        style={{ width: '100%', height: 120, objectFit: 'cover', display: 'block' }}
      />
    </div>
  );
}

// ---------------------------------------------------------------------------
// PlacePhotoCards — renders photo cards during a place's arrive segment
// ---------------------------------------------------------------------------
function PlacePhotoCards({
  segments, projectedPlaces, journeyFrame, fps,
  totalScale, translateX, translateY, frameWidth, frameHeight,
}) {
  // Find all active "arrive" segments and render their cards.
  const activeArrive = segments.find(
    (s) => s.type === 'arrive' && journeyFrame >= s.startFrame && journeyFrame <= s.endFrame,
  );
  if (!activeArrive) return null;

  const pp = projectedPlaces[activeArrive.placeIndex];
  if (!pp) return null;

  const imageUrls = getPlaceImageUrls(pp.place, 3);
  if (imageUrls.length === 0) return null;

  const segFrames = activeArrive.endFrame - activeArrive.startFrame + 1;
  const localFrame = journeyFrame - activeArrive.startFrame;

  // Position card in screen space.
  const cardPos = cardScreenPosition(
    pp.x, pp.y, totalScale, translateX, translateY, frameWidth, frameHeight,
  );

  return (
    <div
      style={{
        position: 'absolute',
        left: cardPos.x,
        top: cardPos.y,
        display: 'flex',
        flexDirection: 'row',
        alignItems: 'flex-end',
        pointerEvents: 'none',
        zIndex: 10,
      }}
    >
      {imageUrls.map((url, idx) => (
        <PhotoCard
          key={`${activeArrive.placeIndex}-${idx}`}
          imageUrl={url}
          fps={fps}
          localFrame={localFrame}
          totalFrames={segFrames}
          index={idx}
          totalCards={imageUrls.length}
        />
      ))}
    </div>
  );
}

// ---------------------------------------------------------------------------
// Letterbox
// ---------------------------------------------------------------------------
function Letterbox() {
  return (
    <AbsoluteFill style={{ pointerEvents: 'none' }}>
      <div style={{ height: LETTERBOX_HEIGHT, background: '#000000' }} />
      <div style={{ flex: 1 }} />
      <div style={{ height: LETTERBOX_HEIGHT, background: '#000000' }} />
    </AbsoluteFill>
  );
}

// ---------------------------------------------------------------------------
// PlaceNameLabel — shows name of the active place at the bottom
// ---------------------------------------------------------------------------
function PlaceNameLabel({ place, opacity }) {
  if (!place || opacity <= 0) return null;
  return (
    <div
      style={{
        position: 'absolute',
        bottom: '12%',
        left: '6%',
        right: '6%',
        opacity,
        fontFamily: 'sans-serif',
        pointerEvents: 'none',
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

// ---------------------------------------------------------------------------
// MapJourney — the continuous map composition
// ---------------------------------------------------------------------------
function MapJourney({ snapshot, places, routes, journeyFrames, fps, width, height, globalFrameOffset }) {
  const frame = useCurrentFrame();
  const journeyFrame = frame - globalFrameOffset;

  // Build global map context (one static map for the entire trip).
  const mapCtx = useMemo(
    () => buildGlobalMapContext({ snapshot, width, height }),
    [snapshot, width, height],
  );

  // Build journey timeline segments.
  const segments = useMemo(
    () => buildJourneyTimeline(places, routes, journeyFrames, fps),
    [places, routes, journeyFrames, fps],
  );

  const activeSegment = segments.length > 0 ? findActiveSegment(segments, journeyFrame) : null;

  // Compute marker position in MAP-PIXEL space (will be transformed to screen later).
  const markerState = useMemo(() => {
    if (!activeSegment || !mapCtx) return null;

    if (activeSegment.type === 'arrive') {
      const pp = mapCtx.projectedPlaces[activeSegment.placeIndex];
      return pp ? { mapX: pp.x, mapY: pp.y, heading: 0, isAtPlace: true } : null;
    }

    // Travel segment.
    const pr = mapCtx.projectedRoutes[activeSegment.routeIndex];
    if (!pr) return null;

    const segFrames = activeSegment.endFrame - activeSegment.startFrame + 1;
    const localProgress = clamp(
      (journeyFrame - activeSegment.startFrame) / Math.max(1, segFrames - 1),
      0, 1,
    );
    const easedProgress = interpolate(localProgress, [0, 1], [0, 1], {
      easing: Easing.inOut(Easing.cubic),
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    });

    if (pr.isArc && pr.startPoint && pr.endPoint) {
      const arcPt = pointOnArc(pr.startPoint, pr.endPoint, easedProgress);
      if (!arcPt) return null;
      const epsilon = 0.01;
      const ptBefore = pointOnArc(pr.startPoint, pr.endPoint, Math.max(0, easedProgress - epsilon));
      const ptAfter = pointOnArc(pr.startPoint, pr.endPoint, Math.min(1, easedProgress + epsilon));
      const heading = ptBefore && ptAfter
        ? Math.atan2(ptAfter.y - ptBefore.y, ptAfter.x - ptBefore.x) * (180 / Math.PI)
        : 0;
      return { mapX: arcPt.x, mapY: arcPt.y, heading, isAtPlace: false };
    }

    if (pr.points.length >= 2) {
      const pos = pointAtProgress(pr.points, easedProgress);
      const heading = getHeadingAtProgress(pr.points, easedProgress);
      return { mapX: pos.x, mapY: pos.y, heading, isAtPlace: false };
    }

    return null;
  }, [activeSegment, mapCtx, journeyFrame]);

  // Label opacity for active place.
  const labelState = useMemo(() => {
    if (!activeSegment || activeSegment.type !== 'arrive') return { place: null, opacity: 0 };
    const segFrames = activeSegment.endFrame - activeSegment.startFrame + 1;
    const localFrame = journeyFrame - activeSegment.startFrame;
    const fadeIn = Math.max(1, Math.floor(fps * 0.35));
    const fadeOut = Math.max(1, Math.floor(fps * 0.25));
    const opacity = interpolate(
      localFrame,
      [0, fadeIn, segFrames - fadeOut, segFrames - 1],
      [0, 1, 1, 0.3],
      { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' },
    );
    return { place: activeSegment.place, opacity };
  }, [activeSegment, journeyFrame, fps]);

  // Camera: focus = marker position (exact tracking), scale = mode-dependent zoom.
  const cameraScale = computeCameraScale(segments, journeyFrame);
  const focusX = markerState ? markerState.mapX : (mapCtx ? mapCtx.mapWidth / 2 : width / 2);
  const focusY = markerState ? markerState.mapY : (mapCtx ? mapCtx.mapHeight / 2 : height / 2);

  const baseScale = mapCtx ? Math.max(width / mapCtx.mapWidth, height / mapCtx.mapHeight) : 1;
  const totalScale = baseScale * cameraScale;

  // Translate so focus point is centered in the frame.
  const translateX = width / 2 - focusX * totalScale;
  const translateY = height / 2 - focusY * totalScale;

  // Clamp so map edges don't become visible.
  const scaledMapW = mapCtx ? mapCtx.mapWidth * totalScale : width;
  const scaledMapH = mapCtx ? mapCtx.mapHeight * totalScale : height;
  const clampedTX = clamp(translateX, width - scaledMapW, 0);
  const clampedTY = clamp(translateY, height - scaledMapH, 0);

  // Fallback: no map data at all.
  if (!mapCtx || mapCtx.projectedPlaces.length === 0) {
    return (
      <AbsoluteFill style={{ background: 'linear-gradient(160deg, #0f1421 0%, #1a2740 60%, #0b111c 100%)' }}>
        <Vignette />
        <Letterbox />
      </AbsoluteFill>
    );
  }

  return (
    <AbsoluteFill style={{ background: '#0a0e14' }}>
      {/* Camera container — viewport that clips the map */}
      <div
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: '100%',
          overflow: 'hidden',
        }}
      >
        {/* Map layer with camera transform */}
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
            <Img
              src={mapCtx.mapUrl}
              style={{ width: mapCtx.mapWidth, height: mapCtx.mapHeight, display: 'block' }}
            />
          ) : (
            <div
              style={{
                width: mapCtx.mapWidth,
                height: mapCtx.mapHeight,
                background: 'linear-gradient(160deg, #0f1421 0%, #1a2740 60%, #0b111c 100%)',
              }}
            />
          )}

          {/* Route trail layer */}
          <RouteTrail
            projectedRoutes={mapCtx.projectedRoutes}
            segments={segments}
            journeyFrame={journeyFrame}
            mapWidth={mapCtx.mapWidth}
            mapHeight={mapCtx.mapHeight}
          />

          {/* Place dots */}
          <PlaceDots
            projectedPlaces={mapCtx.projectedPlaces}
            mapWidth={mapCtx.mapWidth}
            mapHeight={mapCtx.mapHeight}
            segments={segments}
            journeyFrame={journeyFrame}
          />
        </div>
      </div>

      {/* Travel marker in screen space (fixed size regardless of camera zoom) */}
      {markerState && (
        <TravelMarker
          screenX={markerState.mapX * totalScale + clampedTX}
          screenY={markerState.mapY * totalScale + clampedTY}
          heading={markerState.heading}
          frame={frame}
          isAtPlace={markerState.isAtPlace}
          transportMode={activeSegment?.route?.transport_mode || ''}
          routeColor={activeSegment?.route ? getRouteStyle(activeSegment.route).color : '#FFD700'}
        />
      )}

      {/* Photo cards in screen space */}
      <PlacePhotoCards
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

      {/* Overlays in screen space */}
      <Vignette />
      <PlaceNameLabel place={labelState.place} opacity={labelState.opacity} />
      <Letterbox />
    </AbsoluteFill>
  );
}

// ---------------------------------------------------------------------------
// CinematicIntro
// ---------------------------------------------------------------------------
function CinematicIntro({ trip, fps }) {
  const frame = useCurrentFrame();
  const fadeFrames = Math.max(1, Math.floor(fps * 0.4));

  const opacity = interpolate(frame, [0, fadeFrames], [0, 1], { extrapolateRight: 'clamp' });
  const slide = interpolate(frame, [0, fadeFrames], [20, 0], { extrapolateRight: 'clamp' });

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
          transform: `translateY(${slide}px)`,
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

// ---------------------------------------------------------------------------
// CinematicOutro
// ---------------------------------------------------------------------------
function CinematicOutro({ fps }) {
  const frame = useCurrentFrame();
  const fadeFrames = Math.max(1, Math.floor(fps * 0.35));
  const opacity = interpolate(frame, [0, fadeFrames], [0, 1], { extrapolateRight: 'clamp' });

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

// ---------------------------------------------------------------------------
// Cinematic — root composition
// ---------------------------------------------------------------------------
export function CinematicLegacy({ snapshot = {} }) {
  const { fps, durationInFrames, width, height } = useVideoConfig();
  const trip = snapshot.trip || {};
  const places = resolveTimelinePlaces(snapshot);
  const routes = resolveTimelineRoutes(snapshot);

  const introFrames = Math.floor(INTRO_SEC * fps);
  const outroFrames = Math.floor(OUTRO_SEC * fps);
  const journeyFrames = Math.max(0, durationInFrames - introFrames - outroFrames);

  return (
    <AbsoluteFill style={{ background: '#0a0a0a' }}>
      {/* Map journey spans the full duration (visible behind intro/outro) */}
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

      {/* Intro overlay */}
      <Sequence from={0} durationInFrames={introFrames}>
        <CinematicIntro trip={trip} fps={fps} />
      </Sequence>

      {/* Outro overlay */}
      <Sequence from={durationInFrames - outroFrames} durationInFrames={outroFrames}>
        <CinematicOutro fps={fps} />
      </Sequence>
    </AbsoluteFill>
  );
}
