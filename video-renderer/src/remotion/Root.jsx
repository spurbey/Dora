import { Composition } from 'remotion';
import { Classic } from './Classic.jsx';

// Default dimensions match 720p 9:16 (portrait).
// renderMedia() overrides width/height/fps/durationInFrames per manifest.
export function RemotionRoot() {
  return (
    <Composition
      id="Classic"
      component={Classic}
      durationInFrames={450}
      fps={30}
      width={720}
      height={1280}
      defaultProps={{ snapshot: {} }}
    />
  );
}
