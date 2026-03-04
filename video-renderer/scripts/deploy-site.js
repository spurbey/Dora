import path from 'path';

import { deploySite } from '@remotion/lambda';

async function main() {
  const region = process.env.AWS_REGION || 'us-east-1';
  const siteName = process.env.LAMBDA_SITE_NAME || 'dora-classic';
  const bucketName = process.env.LAMBDA_SITE_BUCKET || process.env.LAMBDA_OUTPUT_BUCKET;
  const entryPoint = path.resolve('src/remotion/index.jsx');

  if (!bucketName) {
    throw new Error('missing_env:LAMBDA_SITE_BUCKET_or_LAMBDA_OUTPUT_BUCKET');
  }

  const result = await deploySite({
    entryPoint,
    bucketName,
    region,
    siteName,
  });

  console.log(`serveUrl=${result.serveUrl}`);
}

main().catch((err) => {
  console.error('[deploy-site] failed:', err);
  process.exit(1);
});
