import crypto from 'crypto';

import { getRenderProgress, renderMediaOnLambda } from '@remotion/lambda/client';

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

    const response = await renderMediaOnLambda({
      region: this._region,
      functionName: this._functionName,
      serveUrl: this._serveUrl,
      composition,
      inputProps: { snapshot: manifest.snapshot },
      codec: 'h264',
      imageFormat: 'jpeg',
      framesPerLambda: 8,
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

    this._renders.set(renderId, {
      lambdaRenderId: response.renderId,
      progressBucketName: response.bucketName || this._outputBucket,
      outputBucketName: this._outputBucket,
      outputKey,
      canceled: false,
      done: false,
    });

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
      return {
        render_id: renderId,
        status: 'completed',
        progress: 1,
        output_path: `s3://${entry.outputBucketName}/${entry.outputKey}`,
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
      error: null,
    };
  }

  async cancel(renderId) {
    const entry = this._renders.get(renderId);
    if (!entry) {
      return false;
    }
    entry.canceled = true;
    console.log(
      `[lambda-renderer] cancel requested for ${renderId} (lambda_render_id=${entry.lambdaRenderId}) - no-op`,
    );
    return true;
  }
}
