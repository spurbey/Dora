# Dora Infrastructure

This folder contains infrastructure assets used by Dora's export platform, focused on Remotion Lambda scale-out.

## Scope

`infra/` currently tracks infrastructure templates for:

- renderer runtime IAM permissions
- Lambda trust/policy artifacts
- S3 lifecycle retention policy for export outputs

Primary subtree:

```text
infra/
  remotion/
    README.md
    iam.json
    iam.dev.json
    remotion-lambda-role-policy.json
    remotion-lambda-trust.json
    s3_lifecycle.json
```

## How This Infra Fits the System

Runtime services:

- `video-renderer` (Node) handles Remotion local/lambda render execution.
- `backend` worker calls `video-renderer` via HTTP.
- `backend` API generates presigned download URLs for completed cloud artifacts.

Permission split:

- Renderer runtime principal:
  - invokes Remotion render Lambda functions
  - writes/reads export artifacts in private S3 paths
  - accesses Remotion-managed S3 resources
  - writes CloudWatch logs
- Backend runtime principal:
  - reads S3 objects to issue presigned download URLs
  - does not require direct Lambda invocation for normal render path

## File Guide

- `remotion/iam.json`
  - parameterized template policy (`${AWS_REGION}`, `${AWS_ACCOUNT_ID}`, `${ENV}`)
  - suitable baseline for environment-specific derivation
- `remotion/iam.dev.json`
  - concrete development variant with fixed account/region/bucket values
- `remotion/remotion-lambda-role-policy.json`
  - role policy artifact for lambda renderer permissions
- `remotion/remotion-lambda-trust.json`
  - trust relationship allowing Lambda service assume-role
- `remotion/s3_lifecycle.json`
  - lifecycle policy expiring `private/` exports after 30 days

## Provisioning Checklist (Environment Bring-Up)

1. Create bucket: `dora-exports-<env>`.
2. Block all public access on that bucket.
3. Apply lifecycle config from `remotion/s3_lifecycle.json`.
4. Create renderer execution role and attach relevant policies.
5. Configure `video-renderer` lambda env:
   - `RENDER_BACKEND=lambda`
   - `AWS_REGION`
   - `LAMBDA_FUNCTION_NAME`
   - `LAMBDA_SERVE_URL`
   - `LAMBDA_OUTPUT_BUCKET`
6. Configure backend env:
   - `RENDER_BACKEND=lambda`
   - `RENDERER_URL` (points to renderer service)
   - `AWS_REGION`
   - backend AWS credentials for presigned URL generation
7. Deploy renderer Lambda function:
   - `cd video-renderer && npm run deploy:function`
8. Deploy renderer Remotion site:
   - `cd video-renderer && npm run deploy:site`

## Validation Commands

Use AWS CLI to verify infra state:

```bash
aws sts get-caller-identity
aws s3api get-public-access-block --bucket dora-exports-<env>
aws s3api get-bucket-lifecycle-configuration --bucket dora-exports-<env>
```

## Security and Operational Notes

- Keep export bucket private; distribution should happen via short-lived presigned URLs or backend tokenized share paths.
- Avoid exposing renderer service publicly without additional auth/network controls.
- Remotion package versions in `video-renderer/package.json` are intentionally pinned to exact patch versions for lambda compatibility.
- Current lifecycle policy is unconditional 30-day expiry under `private/`.
- `pinned_at` retention wiring and share-token hardening are tracked as later hardening scope (post-6C docs).

## Related Docs

- `infra/remotion/README.md`
- `video-renderer/README.md`
- `flutter/docs/handoffs/phase6c-cloud-scale-report.md`
- `flutter/docs/phases/Phase-6-PRD.md`
