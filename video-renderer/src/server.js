/**
 * Dora video-renderer service.
 *
 * Exposes the frozen HTTP contract:
 * - POST /api/v1/render
 * - GET /api/v1/render/:renderId
 * - DELETE /api/v1/render/:renderId
 *
 * Runtime backend is selected by RENDER_BACKEND:
 * - local  -> in-process Remotion renderer
 * - lambda -> @remotion/lambda-backed renderer
 */

import crypto from 'crypto';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

import express from 'express';
import { bundle } from '@remotion/bundler';
import { getCompositions, makeCancelSignal, renderMedia } from '@remotion/renderer';

import { LambdaRenderBackend } from './lambda-renderer.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const RENDERER_VERSION = '1';
const PORT = parseInt(process.env.PORT || '3100', 10);
const OUTPUT_DIR = process.env.RENDER_OUTPUT_DIR || path.resolve(process.cwd(), 'render_artifacts');
const CHROME_EXECUTABLE = process.env.REMOTION_CHROME_EXECUTABLE || undefined;
const RENDER_BACKEND = (process.env.RENDER_BACKEND || 'local').trim().toLowerCase();

const ALLOWED_TEMPLATES = new Set(['classic', 'cinematic']);
const ALLOWED_ASPECT_RATIOS = new Set(['9:16', '1:1', '16:9']);
const ALLOWED_QUALITIES = new Set(['480p', '720p', '1080p']);

// Maps manifest template -> Remotion composition ID.
// 'cinematic' falls back to Classic until Phase 6D implements it.
const COMPOSITION_BY_TEMPLATE = {
  classic: 'Classic',
  cinematic: 'Classic',
};

function getDimensions(quality, aspectRatio) {
  const base = { '480p': 480, '720p': 720, '1080p': 1080 };
  const b = base[quality] ?? 720;
  if (aspectRatio === '9:16') return { width: b, height: Math.round((b * 16) / 9 / 2) * 2 };
  if (aspectRatio === '16:9') return { width: Math.round((b * 16) / 9 / 2) * 2, height: b };
  if (aspectRatio === '1:1') return { width: b, height: b };
  return { width: 720, height: 1280 };
}

const app = express();
app.use(express.json({ limit: '512kb' }));

// Local runtime in-memory state.
const renders = new Map(); // renderId -> state
const cancelFns = new Map(); // renderId -> cancel()

fs.mkdirSync(OUTPUT_DIR, { recursive: true });

let bundleLocation = null;
let bundleCompositions = null;
let bundleReady = false;
let bundleErr = null;
let lambdaBackend = null;

function isObject(v) {
  return v !== null && typeof v === 'object' && !Array.isArray(v);
}

function badRequest(res, detail) {
  return res.status(422).json({ error: 'validation_error', detail });
}

function ensureVersion(req, res, next) {
  if (req.header('x-renderer-version') !== RENDERER_VERSION) {
    return res.status(400).json({ error: 'version_mismatch', expected: RENDERER_VERSION });
  }
  return next();
}

function hasBinaryPayload(snapshot) {
  const queue = [snapshot];
  while (queue.length) {
    const cur = queue.shift();
    if (typeof cur === 'string') {
      if (cur.startsWith('data:') || cur.startsWith('base64,')) return true;
      if (cur.length > 32768 && /^[A-Za-z0-9+/=\r\n]+$/.test(cur)) return true;
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
  if (!ALLOWED_ASPECT_RATIOS.has(aspect_ratio)) {
    return 'aspect_ratio must be one of: 9:16, 1:1, 16:9';
  }
  if (!ALLOWED_QUALITIES.has(quality)) return 'quality must be one of: 480p, 720p, 1080p';
  if (!Number.isInteger(duration_sec) || duration_sec <= 0) {
    return 'duration_sec must be a positive integer';
  }
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

async function initLocalBundle() {
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
      `[renderer] local backend ready - ${bundleCompositions.length} composition(s): ${bundleCompositions.map((c) => c.id).join(', ')}`,
    );
  } catch (err) {
    bundleErr = err;
    console.error('[renderer] local bundle initialization failed:', err);
  }
}

function initLambdaBackend() {
  try {
    lambdaBackend = new LambdaRenderBackend({
      getDimensions,
      compositionByTemplate: COMPOSITION_BY_TEMPLATE,
    });
    lambdaBackend.ensureConfigured();
    bundleReady = true;
    console.log('[renderer] lambda backend ready');
  } catch (err) {
    bundleErr = err;
    console.error('[renderer] lambda backend initialization failed:', err);
  }
}

function initRuntime() {
  if (RENDER_BACKEND === 'lambda') {
    initLambdaBackend();
    return;
  }
  void initLocalBundle();
}

async function runLocalRender(renderId, manifest) {
  const state = renders.get(renderId);
  if (!state) return;

  try {
    state.status = 'rendering';
    state.progress = 0.05;
    state.updatedAt = Date.now();
    console.log(
      `[EXPORT_RENDER] local_start render_id=${renderId} job_id=${manifest.job_id} template=${manifest.template}`,
    );

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
    console.log(
      `[EXPORT_RENDER] local_terminal render_id=${renderId} status=${state.status} output_path=${state.outputPath ?? 'null'}`,
    );
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
    console.error(
      `[EXPORT_FAIL] local_render render_id=${renderId} error=${state.error}`,
    );
  }
}

async function submitRender(manifest) {
  if (RENDER_BACKEND === 'lambda') {
    const renderId = await lambdaBackend.submit(manifest);
    return { render_id: renderId, status: 'queued' };
  }

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

  void runLocalRender(renderId, manifest).catch((err) =>
    console.error(`[renderer] unhandled local render error for ${renderId}:`, err),
  );
  return { render_id: renderId, status: 'queued' };
}

async function getRenderStatus(renderId) {
  if (RENDER_BACKEND === 'lambda') {
    return lambdaBackend.getStatus(renderId);
  }

  const state = renders.get(renderId);
  if (!state) {
    return null;
  }
  return {
    render_id: state.renderId,
    status: state.status,
    progress: Math.max(0, Math.min(1, state.progress)),
    output_path: state.status === 'completed' ? state.outputPath : null,
    error: state.error,
  };
}

async function cancelRender(renderId) {
  if (RENDER_BACKEND === 'lambda') {
    const found = await lambdaBackend.cancel(renderId);
    return found;
  }

  const state = renders.get(renderId);
  if (!state) {
    return false;
  }

  state.canceled = true;
  const cancelFn = cancelFns.get(renderId);
  if (cancelFn) cancelFn();

  if (state.status !== 'completed') {
    state.status = 'failed';
    state.progress = 1;
    state.outputPath = null;
    state.error = 'canceled_by_user';
    state.updatedAt = Date.now();
  }
  return true;
}

app.use('/api/v1/render', ensureVersion);

app.post('/api/v1/render', async (req, res) => {
  if (!bundleReady) {
    const detail = bundleErr ? `backend_error:${bundleErr.message}` : 'backend_initializing';
    return res.status(503).json({ error: 'renderer_not_ready', detail });
  }

  const validationErr = validateManifest(req.body);
  if (validationErr) return badRequest(res, validationErr);

  try {
    console.log(
      `[EXPORT_RENDER] submit job_id=${req.body.job_id} template=${req.body.template} backend=${RENDER_BACKEND}`,
    );
    const payload = await submitRender(req.body);
    return res.status(202).json(payload);
  } catch (err) {
    console.error(`[EXPORT_FAIL] submit job_id=${req.body?.job_id ?? 'unknown'} error=${err?.message || 'submit_failed'}`);
    return res.status(500).json({
      error: 'submit_failed',
      detail: err?.message || 'submit_failed',
    });
  }
});

app.get('/api/v1/render/:renderId', async (req, res) => {
  try {
    const payload = await getRenderStatus(req.params.renderId);
    if (!payload) return res.status(404).json({ error: 'not_found' });
    return res.status(200).json(payload);
  } catch (err) {
    console.error(
      `[EXPORT_FAIL] status render_id=${req.params.renderId} error=${err?.message || 'status_failed'}`,
    );
    return res.status(500).json({
      error: 'status_failed',
      detail: err?.message || 'status_failed',
    });
  }
});

app.delete('/api/v1/render/:renderId', async (req, res) => {
  try {
    const found = await cancelRender(req.params.renderId);
    if (!found) return res.status(404).json({ error: 'not_found' });
    return res.status(200).json({ canceled: true });
  } catch (err) {
    console.error(
      `[EXPORT_FAIL] cancel render_id=${req.params.renderId} error=${err?.message || 'cancel_failed'}`,
    );
    return res.status(500).json({
      error: 'cancel_failed',
      detail: err?.message || 'cancel_failed',
    });
  }
});

app.listen(PORT, () => {
  console.log(`[renderer] listening on :${PORT} (backend=${RENDER_BACKEND}, output_dir=${OUTPUT_DIR})`);
});

initRuntime();
