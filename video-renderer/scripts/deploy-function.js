import { deployFunction } from '@remotion/lambda';
import { speculateFunctionName } from '@remotion/lambda/client';

async function main() {
  const region = process.env.AWS_REGION || 'us-east-1';
  const memorySizeInMb = Number(process.env.LAMBDA_MEMORY_MB || '2048');
  const timeoutInSeconds = Number(process.env.LAMBDA_TIMEOUT_SECONDS || '900');
  const diskSizeInMb = Number(process.env.LAMBDA_DISK_MB || '2048');
  const architecture = process.env.LAMBDA_ARCHITECTURE || 'arm64';

  const result = await deployFunction({
    region,
    memorySizeInMb,
    timeoutInSeconds,
    diskSizeInMb,
    architecture,
  });

  console.log(`functionName=${result.functionName}`);
  try {
    const predicted = speculateFunctionName({
      memorySizeInMb,
      diskSizeInMb,
      timeoutInSeconds,
      version: result.version ?? result.versionName,
    });
    console.log(`speculatedFunctionName=${predicted}`);
  } catch (err) {
    console.log(`speculatedFunctionName=unavailable (${err?.message || 'unknown_error'})`);
  }
}

main().catch((err) => {
  console.error('[deploy-function] failed:', err);
  process.exit(1);
});
