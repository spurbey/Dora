<#
.SYNOPSIS
  Deploy a Flutter web production build to the private S3 bucket behind
  CloudFront (see infra/web/README.md).

.EXAMPLE
  .\infra\web\deploy-web.ps1 -BucketName dora-web-prod -DistributionId E1234567890ABC
#>
param(
  [Parameter(Mandatory = $true)][string]$BucketName,
  [Parameter(Mandatory = $false)][string]$DistributionId = "",
  [Parameter(Mandatory = $false)][string]$BuildDir = "flutter/build/web",
  [Parameter(Mandatory = $false)][string]$Profile = ""
)

$ErrorActionPreference = "Stop"

$profileArgs = @()
if ($Profile -ne "") { $profileArgs = @("--profile", $Profile) }

if (-not (Test-Path -LiteralPath $BuildDir)) {
  throw "Build dir not found: $BuildDir. Run 'flutter build web' first."
}
foreach ($f in @("index.html", "flutter_bootstrap.js", "main.dart.js")) {
  if (-not (Test-Path -LiteralPath (Join-Path $BuildDir $f))) {
    throw "Missing $f in $BuildDir — not a Flutter web build."
  }
}

Write-Host "Syncing versioned assets (long cache)..."
& aws s3 sync $BuildDir "s3://$BucketName" @profileArgs `
  --delete `
  --exclude "index.html" `
  --exclude "flutter_bootstrap.js" `
  --exclude "flutter_service_worker.js" `
  --exclude "version.json" `
  --exclude "manifest.json" `
  --cache-control "public,max-age=31536000,immutable"

Write-Host "Syncing entry points (no cache)..."
& aws s3 sync $BuildDir "s3://$BucketName" @profileArgs `
  --delete `
  --exclude "*" `
  --include "index.html" `
  --include "flutter_bootstrap.js" `
  --include "flutter_service_worker.js" `
  --include "version.json" `
  --include "manifest.json" `
  --cache-control "no-cache"

if ($DistributionId -ne "") {
  Write-Host "Invalidating CloudFront $DistributionId ..."
  & aws cloudfront create-invalidation @profileArgs `
    --distribution-id $DistributionId --paths "/*" | Out-Null
  Write-Host "Invalidation requested."
} else {
  Write-Host "No DistributionId given — skipping invalidation."
}

Write-Host "Done."
