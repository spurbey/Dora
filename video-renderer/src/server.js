/**
 * Dora video-renderer service — Phase 6B
 *
 * Starts an Express HTTP server that wraps Remotion's render pipeline.
 * bundle() is called once at startup; renderMedia() is called per render request.
 * The service returns 503 on incoming render requests until the bundle is ready.
 */

import crypto from 'crypto';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

import express from 'express';
import { bundle } from '@remotion/bundler';
import { getCompositions, makeCancelSignal, renderMedia } from '@remotion/renderer';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// ─── Configuration ─────────────────────────────────────────────────────────

const RENDERER_VERSION = '1';
const PORT = parseInt(process.env.PORT || '3100', 10);
const OUTPUT_DIR = process.env.RENDER_OUTPUT_DIR || path.resolve(process.cwd(), 'render_artifacts');
const CHROME_EXECUTABLE = process.env.REMOTION_CHROME_EXECUTABLE || undefined;

const ALLOWED_TEMPLATES = new Set(['classic', 'cinematic']);
const ALLOWED_ASPECT_RATIOS = new Set(['9:16', '1:1', '16:9']);
const ALLOWED_QUALITIES = new Set(['480p', '720p', '1080p']);

// Maps manifest template → Remotion composition ID.
// 'cinematic' falls back to Classic until Phase 6D implements it.
const COMPOSITION_BY_TEMPLATE = {
  classic: 'Classic',
  cinematic: 'Classic',
};

// ─── Output dimensions ──────────────────────────────────────────────────────

/**
 * Convert quality + aspect_ratio to pixel dimensions.
 *
 * Convention: "p" value anchors the portrait axis.
 *   9:16 720p → 720 × 1280  (portrait: width is the "p" axis)
 *   16:9 720p → 1280 × 720  (landscape: height is the "p" axis)
 *   1:1  720p → 720 × 720
 */
function getDimensions(quality, aspectRatio) {
  const base = { '480p': 480, '720p': 720, '1080p': 1080 };
  const b = base[quality] ?? 720;
  if (aspectRatio === '9:16') return { width: b, height: Math.round((b * 16) / 9 / 2) * 2 };
  if (aspectRatio === '16:9') return { width: Math.round((b * 16) / 9 / 2) * 2, height: b };
  if (aspectRatio === '1:1') return { width: b, height: b };
  return { width: 720, height: 1280 }; // safe fallback
}

// ─── Express setup ─────────────────────────────────────────────────────────

const app = express();
app.use(express.json({ limit: '512kb' }));

// ─── In-memory render state ─────────────────────────────────────────────────

const renders = new Map(); // renderId → state
const cancelFns = new Map(); // renderId → cancel()

fs.mkdirSync(OUTPUT_DIR, { recursive: true });

// ─── Remotion bundle (initialised once at startup) ──────────────────────────

let bundleLocation = null;
let bundleCompositions = null;
let bundleReady = false;
let bundleErr = null;

async function initBundle() {
  try {
    const entryPoint = path.join(__dirname, 'remotion', 'index.jsx');
    bundleLocation = await bundle({
      entryPoint,
      webpackOverride: (config) => config,
    });
    bundleCompositions = await getCompositions(bundleLocation, {
      inputProps: {},
      ...(CHROME_EXECUTABLE ? { overrideBrowserExecutable: CHROME_EXECUTABLE } : {}),
      chromiumOptions: { gl: 'swangle' },
    });
    bundleReady = true;
    console.log(
      `[renderer] bundle ready — ${bundleCompositions.length} composition(s): ${bundleCompositions.map((c) => c.id).join(', ')}`,
    );
  } catch (err) {
    bundleErr = err;
    console.error('[renderer] bundle initialisation failed:', err);
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

function badRequest(res, detail) {
  return res.status(422).json({ error: 'validation_error', detail });
}

function ensureVersion(req, res, next) {
  if (req.header('x-renderer-version') !== RENDERER_VERSION) {
    return res.status(400).json({ error: 'version_mismatch', expected: RENDERER_VERSION });
  }
  return next();
}

function isObject(v) {
  return v !== null && typeof v === 'object' && !Array.isArray(v);
}

function hasBinaryPayload(snapshot) {
  const queue = [snapshot];
  while (queue.length) {
    const cur = queue.shift();
    if (typeof cur === 'string') {
      if (cur.startsWith('data:') || cur.startsWith('base64,')) return true;
      if (cur.length > 32_768 && /^[A-Za-z0-9+/=\r\n]+$/.test(cur)) return true;
    } else if (Array.isArray(cur)) {
      queue.push(...cur);
    } else if (isObject(cur)) {
      queue.push(...Object.values(cur));
    }
  }
  return false;
}

function validateManifest(body) {
  if (!isObject(body)) return 'request body must be a JSON object';
  const { job_id, template, aspect_ratio, quality, duration_sec, fps, snapshot } = body;
  if (!job_id || typeof job_id !== 'string') return 'job_id must be a non-empty string';
  if (!ALLOWED_TEMPLATES.has(template)) return 'template must be one of: classic, cinematic';
  if (!ALLOWED_ASPECT_RATIOS.has(aspect_ratio))
    return 'aspect_ratio must be one of: 9:16, 1:1, 16:9';
  if (!ALLOWED_QUALITIES.has(quality)) return 'quality must be one of: 480p, 720p, 1080p';
  if (!Number.isInteger(duration_sec) || duration_sec <= 0)
    return 'duration_sec must be a positive integer';
  if (!Number.isInteger(fps) || fps <= 0) return 'fps must be a positive integer';
  if (!isObject(snapshot)) return 'snapshot must be a JSON object';
  if (hasBinaryPayload(snapshot)) return 'snapshot must not contain binary/base64 payloads';
  return null;
}

function getOutputPath(renderId) {
  const resolved = path.resolve(path.join(OUTPUT_DIR, `${renderId}.mp4`));
  const root = path.resolve(OUTPUT_DIR);
  if (!resolved.startsWith(`${root}${path.sep}`) && resolved !== root) {
    throw new Error('invalid_output_path');
  }
  return resolved;
}

// ─── Async render runner ────────────────────────────────────────────────────

async function runRender(renderId, manifest) {
  const state = renders.get(renderId);
  if (!state) return;

  try {
    state.status = 'rendering';
    state.progress = 0.05;
    state.updatedAt = Date.now();

    const compositionId = COMPOSITION_BY_TEMPLATE[manifest.template];
    const baseComp = bundleCompositions.find((c) => c.id === compositionId);
    if (!baseComp) throw new Error(`composition_not_found:${compositionId}`);

    const dims = getDimensions(manifest.quality, manifest.aspect_ratio);
    const composition = {
      ...baseComp,
      width: dims.width,
      height: dims.height,
      fps: manifest.fps,
      durationInFrames: manifest.duration_sec * manifest.fps,
    };

    const outputPath = getOutputPath(renderId);
    const { signal, cancel } = makeCancelSignal();
    cancelFns.set(renderId, cancel);

    await renderMedia({
      composition,
      serveUrl: bundleLocation,
      codec: 'h264',
      outputLocation: outputPath,
      inputProps: { snapshot: manifest.snapshot },
      cancelSignal: signal,
      ...(CHROME_EXECUTABLE ? { overrideBrowserExecutable: CHROME_EXECUTABLE } : {}),
      chromiumOptions: { gl: 'swangle' },
      onProgress: ({ progress }) => {
        const s = renders.get(renderId);
        if (s && !s.canceled) {
          s.progress = Math.max(0.05, Math.min(0.97, progress));
          s.updatedAt = Date.now();
        }
      },
    });

    cancelFns.delete(renderId);

    if (state.canceled) {
      state.status = 'failed';
      state.progress = 1;
      state.outputPath = null;
      state.error = 'canceled_by_user';
    } else {
      state.status = 'completed';
      state.progress = 1;
      state.outputPath = outputPath;
      state.error = null;
    }
    state.updatedAt = Date.now();
  } catch (err) {
    cancelFns.delete(renderId);
    const wasCanceled =
      state.canceled ||
      (typeof err.message === 'string' &&
        (err.message.includes('cancel') || err.message.includes('abort')));
    state.status = 'failed';
    state.progress = 1;
    state.outputPath = null;
    state.error = wasCanceled ? 'canceled_by_user' : (err.message || 'render_failed');
    state.updatedAt = Date.now();
  }
}

// ─── Routes ─────────────────────────────────────────────────────────────────

app.use('/api/v1/render', ensureVersion);

app.post('/api/v1/render', (req, res) => {
  if (!bundleReady) {
    const detail = bundleErr ? `bundle_error:${bundleErr.message}` : 'bundle_initialising';
    return res.status(503).json({ error: 'renderer_not_ready', detail });
  }

  const validationErr = validateManifest(req.body);
  if (validationErr) return badRequest(res, validationErr);

  const renderId = crypto.randomUUID();
  renders.set(renderId, {
    renderId,
    status: 'queued',
    progress: 0,
    outputPath: null,
    error: null,
    canceled: false,
    createdAt: Date.now(),
    updatedAt: Date.now(),
  });

  // Fire and forget — caller polls GET /api/v1/render/:id
  runRender(renderId, req.body).catch((err) =>
    console.error(`[renderer] unhandled error for ${renderId}:`, err),
  );

  return res.status(202).json({ render_id: renderId, status: 'queued' });
});

app.get('/api/v1/render/:renderId', (req, res) => {
  const state = renders.get(req.params.renderId);
  if (!state) return res.status(404).json({ error: 'not_found' });

  return res.status(200).json({
    render_id: state.renderId,
    status: state.status,
    progress: Math.max(0, Math.min(1, state.progress)),
    output_path: state.status === 'completed' ? state.outputPath : null,
    error: state.error,
  });
});

app.delete('/api/v1/render/:renderId', (req, res) => {
  const state = renders.get(req.params.renderId);
  if (!state) return res.status(404).json({ error: 'not_found' });

  state.canceled = true;

  // Signal Remotion to stop the render cooperatively
  const cancelFn = cancelFns.get(req.params.renderId);
  if (cancelFn) cancelFn();

  // Mark terminal state immediately so polling sees the cancellation
  if (state.status !== 'completed') {
    state.status = 'failed';
    state.progress = 1;
    state.outputPath = null;
    state.error = 'canceled_by_user';
    state.updatedAt = Date.now();
  }

  return res.status(200).json({ canceled: true });
});

// ─── Start ──────────────────────────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`[renderer] listening on :${PORT} (output_dir=${OUTPUT_DIR})`);
});

// Kick off bundle build in the background; server accepts connections immediately.
initBundle();
