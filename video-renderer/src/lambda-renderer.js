import crypto from 'crypto';

import {
  getRenderProgress,
  renderMediaOnLambda,
  renderStillOnLambda,
} from '@remotion/lambda/client';

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
    this._mapboxToken = (process.env.RENDERER_MAPBOX_TOKEN || process.env.MAPBOX_API_KEY || '').trim();
    this._mapStyle = (process.env.RENDERER_MAP_STYLE || 'mapbox/navigation-night-v1').trim();
    this._renders = new Map();
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

    const response = await renderMediaOnLambda({
      region: this._region,
      functionName: this._functionName,
      serveUrl: this._serveUrl,
      composition,
      inputProps,
      codec: 'h264',
      imageFormat: 'jpeg',
      framesPerLambda: this._framesPerLambda,
      privacy: 'no-acl',
      forceWidth: dims.width,
      forceHeight: dims.height,
      forceFps: manifest.fps,
      forceDurationInFrames: manifest.duration_sec * manifest.fps,
      outName: {
        bucketName: this._outputBucket,
        key: outputKey,
      },
      timeoutInMilliseconds: 240000,
      maxRetries: 1,
    });

    const stillResponse = await renderStillOnLambda({
      region: this._region,
      functionName: this._functionName,
      serveUrl: this._serveUrl,
      composition,
      inputProps,
      imageFormat: 'jpeg',
      privacy: 'no-acl',
      frame: Math.max(0, Math.floor(manifest.duration_sec * manifest.fps * 0.45)),
      forceWidth: dims.width,
      forceHeight: dims.height,
      forceFps: manifest.fps,
      forceDurationInFrames: manifest.duration_sec * manifest.fps,
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
    });
    console.log(
      `[EXPORT_RENDER] lambda_submit job_id=${manifest.job_id} render_id=${renderId} lambda_render_id=${response.renderId}`,
    );

    return renderId;
  }

  async getStatus(renderId) {
    const entry = this._renders.get(renderId);
    if (!entry) {
      return null;
    }

    if (entry.done) {
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

  /** Cancel is intentionally a no-op for Lambda renders.
   *  Once renderMediaOnLambda() is invoked, no Remotion API exists to abort it.
   *  Lambda runs to completion and bills regardless. The worker marks the job
   *  canceled in DB so the artifact is never surfaced to users. */
  async cancel(renderId) {
    const entry = this._renders.get(renderId);
    if (!entry) {
      return false;
    }
    console.warn(
      `[lambda-renderer] cancel requested for ${renderId} — no-op: Lambda continues billing`,
    );
    return true;
  }
}
