import {
  AbsoluteFill,
  Img,
  Sequence,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';

// Fixed segment durations (seconds). Place slides fill the remaining time.
const TITLE_SEC = 2;
const END_SEC = 1;
const MIN_PLACE_SEC = 2;

// ─── Title Card ──────────────────────────────────────────────────────────────

function TitleCard({ trip, fps, totalFrames }) {
  const frame = useCurrentFrame();
  const fadeEnd = Math.floor(fps * 0.5);

  const opacity = interpolate(frame, [0, fadeEnd], [0, 1], {
    extrapolateRight: 'clamp',
  });
  const slideUp = interpolate(frame, [0, fadeEnd], [30, 0], {
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
        justifyContent: 'center',
        alignItems: 'center',
        padding: 40,
        fontFamily: 'sans-serif',
      }}
    >
      <div
        style={{
          textAlign: 'center',
          opacity,
          transform: `translateY(${slideUp}px)`,
        }}
      >
        <div
          style={{
            color: '#e8c87a',
            fontSize: 20,
            letterSpacing: 6,
            textTransform: 'uppercase',
            marginBottom: 18,
          }}
        >
          TRAVEL DIARY
        </div>
        <div
          style={{
            color: '#ffffff',
            fontSize: 52,
            fontWeight: 700,
            lineHeight: 1.15,
            marginBottom: 20,
          }}
        >
          {trip.title || 'My Journey'}
        </div>
        {(trip.destination || trip.city) && (
          <div
            style={{
              color: 'rgba(255,255,255,0.7)',
              fontSize: 24,
            }}
          >
            {trip.destination || trip.city}
          </div>
        )}
      </div>
    </AbsoluteFill>
  );
}

// ─── Place Slide (Ken Burns photo + text overlay) ────────────────────────────

function PlaceSlide({ place, fps, totalFrames }) {
  const frame = useCurrentFrame();
  const progress = totalFrames > 1 ? frame / (totalFrames - 1) : 0;
  const fadeEnd = Math.floor(fps * 0.4);

  // Ken Burns: gentle zoom + horizontal pan
  const scale = interpolate(progress, [0, 1], [1.05, 1.13]);
  const translateX = interpolate(progress, [0, 1], [0, -10]);

  // Text fades in over the first 0.4 s
  const textOpacity = interpolate(frame, [0, fadeEnd], [0, 1], {
    extrapolateRight: 'clamp',
  });

  const photoUrl = place.media?.[0]?.url ?? null;

  // Deterministic hue from the place name for the fallback background
  const nameSeed = (place.name || '').split('').reduce((acc, c) => acc + c.charCodeAt(0), 0);
  const fallbackHue = nameSeed % 360;

  return (
    <AbsoluteFill>
      {/* Background: photo with Ken Burns or solid colour fallback */}
      {photoUrl ? (
        <AbsoluteFill style={{ overflow: 'hidden' }}>
          <Img
            src={photoUrl}
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
        <AbsoluteFill
          style={{
            background: `hsl(${fallbackHue}, 25%, 15%)`,
          }}
        />
      )}

      {/* Gradient scrim at the bottom for text legibility */}
      <AbsoluteFill
        style={{
          background:
            'linear-gradient(to top, rgba(0,0,0,0.78) 0%, rgba(0,0,0,0) 55%)',
        }}
      />

      {/* Place name + optional sub-label */}
      <AbsoluteFill
        style={{
          justifyContent: 'flex-end',
          padding: '0 28px 44px',
          opacity: textOpacity,
          fontFamily: 'sans-serif',
        }}
      >
        <div>
          <div
            style={{
              color: '#ffffff',
              fontSize: 34,
              fontWeight: 700,
              lineHeight: 1.2,
              textShadow: '0 2px 10px rgba(0,0,0,0.7)',
            }}
          >
            {place.name || 'A Place'}
          </div>
          {(place.destination || place.address || place.city) && (
            <div
              style={{
                color: 'rgba(255,255,255,0.72)',
                fontSize: 19,
                marginTop: 6,
                textShadow: '0 1px 6px rgba(0,0,0,0.6)',
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

// ─── End Card ────────────────────────────────────────────────────────────────

function EndCard({ trip, fps, totalFrames }) {
  const frame = useCurrentFrame();
  const fadeEnd = Math.floor(fps * 0.4);

  const opacity = interpolate(frame, [0, fadeEnd], [0, 1], {
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(135deg, #0f3460 0%, #16213e 100%)',
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
            fontSize: 16,
            letterSpacing: 5,
            textTransform: 'uppercase',
            marginBottom: 10,
          }}
        >
          Made with
        </div>
        <div
          style={{
            color: '#ffffff',
            fontSize: 52,
            fontWeight: 700,
            letterSpacing: 3,
          }}
        >
          Dora
        </div>
      </div>
    </AbsoluteFill>
  );
}

// ─── Classic root composition ────────────────────────────────────────────────

export function Classic({ snapshot = {} }) {
  const { fps, durationInFrames } = useVideoConfig();

  const trip = snapshot.trip || {};
  const timeline = Array.isArray(snapshot.timeline) ? snapshot.timeline : [];

  // Accept any timeline item that has a name (places, waypoints, etc.)
  const places = timeline.filter((item) => item && item.name);

  const titleFrames = TITLE_SEC * fps;
  const endFrames = END_SEC * fps;
  const availableFrames = Math.max(0, durationInFrames - titleFrames - endFrames);

  // Distribute available time evenly across places; never shorter than MIN_PLACE_SEC
  const placeSegments =
    places.length > 0
      ? places.map((place, i) => {
          const framesPerPlace = Math.max(
            MIN_PLACE_SEC * fps,
            Math.floor(availableFrames / places.length),
          );
          return { place, from: titleFrames + i * framesPerPlace, frames: framesPerPlace };
        })
      : [];

  return (
    <AbsoluteFill style={{ background: '#0f0f0f' }}>
      {/* Title card */}
      <Sequence from={0} durationInFrames={titleFrames}>
        <TitleCard trip={trip} fps={fps} totalFrames={titleFrames} />
      </Sequence>

      {/* One slide per place */}
      {placeSegments.map(({ place, from, frames }, i) => (
        <Sequence key={place.id || i} from={from} durationInFrames={frames}>
          <PlaceSlide place={place} fps={fps} totalFrames={frames} />
        </Sequence>
      ))}

      {/* End card */}
      <Sequence from={durationInFrames - endFrames} durationInFrames={endFrames}>
        <EndCard trip={trip} fps={fps} totalFrames={endFrames} />
      </Sequence>
    </AbsoluteFill>
  );
}
