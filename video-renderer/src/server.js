const express = require('express');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const RENDERER_VERSION = '1';
const PORT = parseInt(process.env.PORT || '3100', 10);
const OUTPUT_DIR = process.env.RENDER_OUTPUT_DIR || path.resolve(process.cwd(), 'render_artifacts');

const ALLOWED_TEMPLATE = new Set(['classic', 'cinematic']);
const ALLOWED_ASPECT_RATIO = new Set(['9:16', '1:1', '16:9']);
const ALLOWED_QUALITY = new Set(['480p', '720p', '1080p']);

const app = express();
app.use(express.json({ limit: '1mb' }));

const renders = new Map();

fs.mkdirSync(OUTPUT_DIR, { recursive: true });

function badRequest(res, detail) {
  return res.status(422).json({
    error: 'validation_error',
    detail,
  });
}

function ensureRendererVersion(req, res, next) {
  const version = req.header('x-renderer-version');
  if (version !== RENDERER_VERSION) {
    return res.status(400).json({
      error: 'version_mismatch',
      expected: RENDERER_VERSION,
    });
  }
  return next();
}

function isObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function containsLikelyBinaryPayload(snapshot) {
  const queue = [snapshot];
  while (queue.length > 0) {
    const current = queue.shift();

    if (typeof current === 'string') {
      if (current.startsWith('data:') || current.startsWith('base64,')) {
        return true;
      }
      if (current.length > 32768 && /^[A-Za-z0-9+/=\r\n]+$/.test(current)) {
        return true;
      }
      continue;
    }

    if (Array.isArray(current)) {
      for (const item of current) queue.push(item);
      continue;
    }

    if (isObject(current)) {
      for (const value of Object.values(current)) queue.push(value);
    }
  }

  return false;
}

function validateManifest(manifest) {
  if (!isObject(manifest)) return 'request body must be a JSON object';

  const { job_id, template, aspect_ratio, quality, duration_sec, fps, snapshot } = manifest;

  if (!job_id || typeof job_id !== 'string') return 'job_id must be a non-empty string';
  if (!ALLOWED_TEMPLATE.has(template)) return 'template must be one of: classic, cinematic';
  if (!ALLOWED_ASPECT_RATIO.has(aspect_ratio)) return 'aspect_ratio must be one of: 9:16, 1:1, 16:9';
  if (!ALLOWED_QUALITY.has(quality)) return 'quality must be one of: 480p, 720p, 1080p';
  if (!Number.isInteger(duration_sec) || duration_sec <= 0) return 'duration_sec must be a positive integer';
  if (!Number.isInteger(fps) || fps <= 0) return 'fps must be a positive integer';
  if (!isObject(snapshot)) return 'snapshot must be a JSON object';
  if (containsLikelyBinaryPayload(snapshot)) return 'snapshot must not contain binary/base64 payloads';

  return null;
}

function getOutputPath(renderId) {
  const resolved = path.resolve(path.join(OUTPUT_DIR, `${renderId}.mp4`));
  const normalizedRoot = path.resolve(OUTPUT_DIR);
  if (!resolved.startsWith(`${normalizedRoot}${path.sep}`) && resolved !== normalizedRoot) {
    throw new Error('invalid_output_path');
  }
  return resolved;
}

function clearTimers(state) {
  if (state.startTimer) {
    clearTimeout(state.startTimer);
    state.startTimer = null;
  }
  if (state.progressTimer) {
    clearInterval(state.progressTimer);
    state.progressTimer = null;
  }
}

function completeRender(state) {
  state.status = 'completed';
  state.progress = 1;
  state.error = null;
  state.updatedAt = Date.now();

  try {
    state.outputPath = getOutputPath(state.renderId);
    fs.writeFileSync(
      state.outputPath,
      Buffer.from(`DORA_RENDER_STUB:${state.renderId}:${Date.now()}`),
    );
  } catch (error) {
    state.status = 'failed';
    state.progress = 1;
    state.outputPath = null;
    state.error = `artifact_write_failed:${error.message}`;
  }
}

function startRenderLifecycle(state) {
  state.startTimer = setTimeout(() => {
    if (state.canceled) return;

    state.status = 'rendering';
    state.progress = 0.05;
    state.updatedAt = Date.now();

    state.progressTimer = setInterval(() => {
      if (state.canceled) {
        clearTimers(state);
        return;
      }

      if (state.status !== 'rendering') {
        clearTimers(state);
        return;
      }

      state.progress = Math.min(0.97, state.progress + 0.12);
      state.updatedAt = Date.now();

      if (state.progress >= 0.97) {
        clearTimers(state);
        completeRender(state);
      }
    }, 300);
  }, 200);
}

app.use('/api/v1/render', ensureRendererVersion);

app.post('/api/v1/render', (req, res) => {
  const validationError = validateManifest(req.body);
  if (validationError) {
    return badRequest(res, validationError);
  }

  const renderId = crypto.randomUUID();
  const state = {
    renderId,
    status: 'queued',
    progress: 0,
    outputPath: null,
    error: null,
    canceled: false,
    createdAt: Date.now(),
    updatedAt: Date.now(),
    startTimer: null,
    progressTimer: null,
  };

  renders.set(renderId, state);
  startRenderLifecycle(state);

  return res.status(202).json({
    render_id: renderId,
    status: 'queued',
  });
});

app.get('/api/v1/render/:renderId', (req, res) => {
  const state = renders.get(req.params.renderId);
  if (!state) {
    return res.status(404).json({ error: 'not_found' });
  }

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
  if (!state) {
    return res.status(404).json({ error: 'not_found' });
  }

  state.canceled = true;
  clearTimers(state);
  state.status = 'failed';
  state.progress = 1;
  state.outputPath = null;
  state.error = 'canceled_by_user';
  state.updatedAt = Date.now();

  return res.status(200).json({ canceled: true });
});

app.listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`video-renderer listening on :${PORT} (output=${OUTPUT_DIR})`);
});
