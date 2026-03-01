# Remotion Lambda Infra (Phase 6C)

This folder documents the minimum infrastructure required for the 6C Lambda renderer path.

## Runtime Principal Split

- Renderer runtime principal (Node `video-renderer`) needs:
  - Lambda invoke permissions for Remotion render functions
  - S3 object access for export outputs
  - S3 access used by Remotion Lambda internals
  - CloudWatch logs permissions
- Backend runtime principal (Python API/worker) needs:
  - S3 read access for generating presigned download URLs
  - no direct Lambda invoke for the normal render path

`iam.json` is a template for the renderer runtime principal policy.

## Provisioning Sequence

1. Create private S3 bucket `dora-exports-{env}`.
2. Block all public access on the bucket.
3. Apply lifecycle policy from `s3_lifecycle.json`.
4. Create renderer runtime role and attach policy from `iam.json`.
5. Configure renderer environment:
   - `RENDER_BACKEND=lambda`
   - `AWS_REGION`
   - `LAMBDA_FUNCTION_NAME`
   - `LAMBDA_SERVE_URL`
   - `LAMBDA_OUTPUT_BUCKET`
6. Configure backend environment:
   - `RENDER_BACKEND=lambda`
   - `RENDERER_URL` pointing to `video-renderer`
   - `AWS_REGION`
   - `EXPORT_WORKER_STALE_SECONDS` greater than max render runtime
7. Deploy Remotion Lambda function:
   - `cd video-renderer && npm run deploy:function`
8. Deploy Remotion site bundle:
   - `cd video-renderer && npm run deploy:site`

## Notes

- Keep all Remotion packages at the exact same patch version.
- Lifecycle in 6C is unconditional 30-day cleanup under `private/`.
- `pinned_at` retention logic and share-token hardening are 6D scope.
