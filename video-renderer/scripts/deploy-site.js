import path from 'path';

import { deploySite } from '@remotion/lambda';

async function main() {
  const region = process.env.AWS_REGION || 'us-east-1';
  const siteName = process.env.LAMBDA_SITE_NAME || 'dora-classic';
  const entryPoint = path.resolve('src/remotion/index.jsx');

  const result = await deploySite({
    entryPoint,
    region,
    siteName,
  });

  console.log(`serveUrl=${result.serveUrl}`);
}

main().catch((err) => {
  console.error('[deploy-site] failed:', err);
  process.exit(1);
});
