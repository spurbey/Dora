import crypto from 'crypto';

import {
  getRenderProgress,
  renderMediaOnLambda,
  renderStillOnLambda,
} from '@remotion/lambda/client';
import { selectThumbnailFrame } from './thumbnail-frame.js';

function parsePositiveInt(value, fallback) {
  const parsed = parseInt(value || '', 10);
  if (!Number.isInteger(parsed) || parsed <= 0) {
    return fallback;
  }
  return parsed;
}

function parseOptionalBoolean(value) {
  if (typeof value === 'boolean') return value;
  if (typeof value === 'number') {
    if (value === 1) return true;
    if (value === 0) return false;
    return null;
  }
  if (typeof value === 'string') {
    const normalized = value.trim().toLowerCase();
    if (normalized === '1' || normalized === 'true' || normalized === 'yes' || normalized === 'on') return true;
    if (normalized === '0' || normalized === 'false' || normalized === 'no' || normalized === 'off') return false;
  }
  return null;
}

function parseEnvBoolean(value, fallback) {
  const parsed = parseOptionalBoolean(value);
  return parsed == null ? fallback : parsed;
}

function clampProgress(value) {
  if (typeof value !== 'number' || Number.isNaN(value)) {
    return 0;
  }
  if (value < 0) {
    return 0;
  }
  if (value > 1) {
    return 1;
  }
  return value;
}

export class LambdaRenderBackend {
  constructor({ getDimensions, compositionByTemplate }) {
    this._getDimensions = getDimensions;
    this._compositionByTemplate = compositionByTemplate;
    this._region = process.env.AWS_REGION || 'us-east-1';
    this._functionName = process.env.LAMBDA_FUNCTION_NAME || '';
    this._serveUrl = process.env.LAMBDA_SERVE_URL || '';
    this._outputBucket = process.env.LAMBDA_OUTPUT_BUCKET || '';
    this._framesPerLambda = Math.max(
      1,
      parseInt(process.env.LAMBDA_FRAMES_PER_LAMBDA || '200', 10) || 200,
    );
    this._framesPerLambdaCinematic = parsePositiveInt(
      process.env.LAMBDA_FRAMES_PER_LAMBDA_CINEMATIC,
      40,
    );
    this._concurrencyPerLambdaCinematic = parsePositiveInt(
      process.env.LAMBDA_CONCURRENCY_PER_LAMBDA_CINEMATIC,
      1,
    );
    this._videoCrf = parsePositiveInt(process.env.LAMBDA_VIDEO_CRF, 16);
    this._x264Preset = (process.env.LAMBDA_X264_PRESET || 'slow').trim();
    this._videoBitrate = (process.env.LAMBDA_VIDEO_BITRATE || '').trim();
    this._renderRetentionMs = parsePositiveInt(
      process.env.LAMBDA_RENDER_RETENTION_MS,
      10 * 60 * 1000,
    );
    this._maxTrackedRenders = parsePositiveInt(
      process.env.LAMBDA_MAX_TRACKED_RENDERS,
      2000,
    );
    this._mapboxToken = (process.env.RENDERER_MAPBOX_TOKEN || process.env.MAPBOX_API_KEY || '').trim();
    this._mapStyle = (process.env.RENDERER_MAP_STYLE || 'mapbox/navigation-night-v1').trim();
    this._mapboxGlEnabled = parseEnvBoolean(process.env.CINEMATIC_GL_ENABLE_MAPBOX, true);
    this._mapboxGlStrict = parseEnvBoolean(process.env.CINEMATIC_GL_STRICT_NATIVE, false);
    this._allowDerivedStylePin = (process.env.CINEMATIC_GL_ALLOW_DERIVED_STYLE_PIN || '').trim() === '1';
    this._renders = new Map();
  }

  _pruneRenders(now = Date.now()) {
    for (const [renderId, entry] of this._renders.entries()) {
      const timestamp = entry.updatedAt || entry.createdAt || now;
      if (entry.done && now - timestamp > this._renderRetentionMs) {
        this._renders.delete(renderId);
      }
    }

    if (this._renders.size <= this._maxTrackedRenders) {
      return;
    }

    // Evict oldest terminal entries first.
    for (const [renderId, entry] of this._renders.entries()) {
      if (this._renders.size <= this._maxTrackedRenders) {
        break;
      }
      if (entry.done) {
        this._renders.delete(renderId);
      }
    }

    // Final hard cap as fallback.
    while (this._renders.size > this._maxTrackedRenders) {
      const oldestKey = this._renders.keys().next().value;
      if (!oldestKey) {
        break;
      }
      this._renders.delete(oldestKey);
    }
  }

  ensureConfigured() {
    if (!this._functionName) {
      throw new Error('lambda_config_missing:LAMBDA_FUNCTION_NAME');
    }
    if (!this._serveUrl) {
      throw new Error('lambda_config_missing:LAMBDA_SERVE_URL');
    }
    if (!this._outputBucket) {
      throw new Error('lambda_config_missing:LAMBDA_OUTPUT_BUCKET');
    }
  }

  _buildInputProps(snapshot) {
    const sourceSnapshot =
      snapshot && typeof snapshot === 'object' && !Array.isArray(snapshot) ? snapshot : {};
    const existingRendererConfig =
      sourceSnapshot.renderer_config &&
      typeof sourceSnapshot.renderer_config === 'object' &&
      !Array.isArray(sourceSnapshot.renderer_config)
        ? sourceSnapshot.renderer_config
        : {};
    const rendererConfig = {
      ...existingRendererConfig,
      map_style: existingRendererConfig.map_style || this._mapStyle,
    };
    const requestedNativeGl = parseOptionalBoolean(existingRendererConfig.mapbox_gl_enabled);
    const requestedStrictNative = parseOptionalBoolean(existingRendererConfig.mapbox_gl_strict);
    rendererConfig.mapbox_gl_enabled = requestedNativeGl ?? this._mapboxGlEnabled;
    rendererConfig.mapbox_gl_strict = requestedStrictNative ?? this._mapboxGlStrict;
    rendererConfig.allow_derived_style_pin = this._allowDerivedStylePin;
    if (this._mapboxToken) {
      rendererConfig.mapbox_token = this._mapboxToken;
    }
    return {
      snapshot: {
        ...sourceSnapshot,
        renderer_config: rendererConfig,
      },
    };
  }

  async submit(manifest) {
    this.ensureConfigured();
    this._pruneRenders();

    const composition = this._compositionByTemplate[manifest.template];
    if (!composition) {
      throw new Error(`template_not_supported:${manifest.template}`);
    }

    const dims = this._getDimensions(manifest.quality, manifest.aspect_ratio);
    const userId = manifest?.snapshot?.trip?.user_id || 'unknown';
    const renderId = crypto.randomUUID();
    const outputKey = `private/${userId}/${manifest.job_id}/output.mp4`;
    const thumbnailKey = `private/${userId}/${manifest.job_id}/thumbnail.jpg`;
    const inputProps = this._buildInputProps(manifest.snapshot);
    const durationInFrames = manifest.duration_sec * manifest.fps;
    const isCinematic = manifest.template === 'cinematic';
    const framesPerLambda = isCinematic ? this._framesPerLambdaCinematic : this._framesPerLambda;

    const response = await renderMediaOnLambda({
      region: this._region,
      functionName: this._functionName,
      serveUrl: this._serveUrl,
      composition,
      inputProps,
      codec: 'h264',
      imageFormat: isCinematic ? 'png' : 'jpeg',
      framesPerLambda,
      privacy: 'no-acl',
      forceWidth: dims.width,
      forceHeight: dims.height,
      forceFps: manifest.fps,
      forceDurationInFrames: durationInFrames,
      outName: {
        bucketName: this._outputBucket,
        key: outputKey,
      },
      timeoutInMilliseconds: 240000,
      maxRetries: 1,
      crf: this._videoCrf,
      x264Preset: this._x264Preset,
      ...(this._videoBitrate ? { videoBitrate: this._videoBitrate } : {}),
      ...(isCinematic ? { concurrencyPerLambda: this._concurrencyPerLambdaCinematic } : {}),
      chromiumOptions: { gl: 'swangle' },
    });

    const stillResponse = await renderStillOnLambda({
      region: this._region,
      functionName: this._functionName,
      serveUrl: this._serveUrl,
      composition,
      inputProps,
      imageFormat: 'jpeg',
      privacy: 'no-acl',
      frame: selectThumbnailFrame({
        template: manifest.template,
        snapshot: manifest.snapshot,
        durationInFrames,
        durationSec: manifest.duration_sec,
        fps: manifest.fps,
      }),
      forceWidth: dims.width,
      forceHeight: dims.height,
      forceFps: manifest.fps,
      forceDurationInFrames: durationInFrames,
      outName: {
        bucketName: this._outputBucket,
        key: thumbnailKey,
      },
      timeoutInMilliseconds: 240000,
      maxRetries: 1,
    });

    this._renders.set(renderId, {
      lambdaRenderId: response.renderId,
      progressBucketName: response.bucketName || this._outputBucket,
      outputBucketName: this._outputBucket,
      outputKey,
      thumbnailBucketName: stillResponse.bucketName || this._outputBucket,
      thumbnailKey: stillResponse.outKey || thumbnailKey,
      done: false,
      terminalStatus: null,
      error: null,
      createdAt: Date.now(),
      updatedAt: Date.now(),
    });
    console.log(
      `[EXPORT_RENDER] lambda_submit job_id=${manifest.job_id} render_id=${renderId} lambda_render_id=${response.renderId}`,
    );

    return renderId;
  }

  async getStatus(renderId) {
    this._pruneRenders();
    const entry = this._renders.get(renderId);
    if (!entry) {
      return null;
    }
    entry.updatedAt = Date.now();

    if (entry.done) {
      if (entry.terminalStatus === 'failed') {
        return {
          render_id: renderId,
          status: 'failed',
          progress: 1,
          output_path: null,
          thumbnail_path: null,
          error: entry.error || 'lambda_render_failed',
        };
      }
      return {
        render_id: renderId,
        status: 'completed',
        progress: 1,
        output_path: `s3://${entry.outputBucketName}/${entry.outputKey}`,
        thumbnail_path: `s3://${entry.thumbnailBucketName}/${entry.thumbnailKey}`,
        error: null,
      };
    }

    const progress = await getRenderProgress({
      region: this._region,
      functionName: this._functionName,
      renderId: entry.lambdaRenderId,
      bucketName: entry.progressBucketName,
    });

    if (progress.fatalErrorEncountered) {
      const firstError = Array.isArray(progress.errors) && progress.errors.length > 0
        ? progress.errors[0]
        : null;
      const message = firstError?.message || 'lambda_render_failed';
      entry.done = true;
      entry.terminalStatus = 'failed';
      entry.error = message;
      entry.updatedAt = Date.now();
      console.error(
        `[EXPORT_FAIL] lambda_render render_id=${renderId} lambda_render_id=${entry.lambdaRenderId} error=${message}`,
      );
      return {
        render_id: renderId,
        status: 'failed',
        progress: 1,
        output_path: null,
        error: message,
      };
    }

    if (progress.done) {
      entry.done = true;
      entry.terminalStatus = 'completed';
      entry.updatedAt = Date.now();
      console.log(
        `[EXPORT_RENDER] lambda_complete render_id=${renderId} output_path=s3://${entry.outputBucketName}/${entry.outputKey}`,
      );
      return {
        render_id: renderId,
        status: 'completed',
        progress: 1,
        output_path: `s3://${entry.outputBucketName}/${entry.outputKey}`,
        thumbnail_path: `s3://${entry.thumbnailBucketName}/${entry.thumbnailKey}`,
        error: null,
      };
    }

    const normalizedProgress = clampProgress(progress.overallProgress);
    const status = normalizedProgress > 0 ? 'rendering' : 'queued';
    return {
      render_id: renderId,
      status,
      progress: normalizedProgress,
      output_path: null,
      thumbnail_path: null,
      error: null,
    };
  }

  getActiveCount() {
    this._pruneRenders();
    let active = 0;
    for (const entry of this._renders.values()) {
      if (!entry.done) {
        active += 1;
      }
    }
    return active;
  }

  /** Cancel is intentionally a no-op for Lambda renders.
   *  Once renderMediaOnLambda() is invoked, no Remotion API exists to abort it.
   *  Lambda runs to completion and bills regardless. The worker marks the job
   *  canceled in DB so the artifact is never surfaced to users. */
  async cancel(renderId) {
    this._pruneRenders();
    const entry = this._renders.get(renderId);
    if (!entry) {
      return false;
    }
    entry.updatedAt = Date.now();
    console.warn(
      `[lambda-renderer] cancel requested for ${renderId} — no-op: Lambda continues billing`,
    );
    return true;
  }
}
