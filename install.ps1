[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$owner = 'Fermoders'
$repository = 'codex-custom-windows'
$assetName = 'codex-custom-win-x64.zip'

if (-not [Environment]::Is64BitOperatingSystem) {
    throw 'This installer requires 64-bit Windows.'
}

$workRoot = Join-Path $env:TEMP ("codex-custom-bootstrap-" + [guid]::NewGuid().ToString('N'))
$archivePath = Join-Path $workRoot $assetName
$extractRoot = Join-Path $workRoot 'bundle'

New-Item -ItemType Directory -Path $workRoot -Force | Out-Null
try {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repository/releases/latest" -Headers @{ 'User-Agent' = "$repository-installer" }
    $asset = $release.assets | Where-Object { $_.name -eq $assetName } | Select-Object -First 1
    if ($null -eq $asset) {
        throw "Release asset not found: $assetName"
    }

    Write-Host "Downloading $($release.tag_name)..."
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $archivePath -UseBasicParsing

    if ([string]::IsNullOrWhiteSpace($release.body)) {
        throw 'The latest release does not publish a SHA-256 checksum.'
    }
    $checksumMatch = [Regex]::Match($release.body, '(?im)^SHA-256:\s*([a-f0-9]{64})\s*$')
    if (-not $checksumMatch.Success) {
        throw 'Could not parse the release SHA-256 checksum.'
    }
    $expectedHash = $checksumMatch.Groups[1].Value.ToLowerInvariant()
    $actualHash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -ne $expectedHash) {
        throw "Release checksum mismatch. Expected $expectedHash, got $actualHash."
    }

    Expand-Archive -LiteralPath $archivePath -DestinationPath $extractRoot -Force

    $bundleInstaller = Join-Path $extractRoot 'Install-Codex-Custom.ps1'
    if (-not (Test-Path -LiteralPath $bundleInstaller -PathType Leaf)) {
        throw "Downloaded bundle is missing Install-Codex-Custom.ps1"
    }

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $bundleInstaller
    if ($LASTEXITCODE -ne 0) {
        throw "Codex custom installer failed with exit code $LASTEXITCODE."
    }
}
finally {
    if (Test-Path -LiteralPath $workRoot) {
        Remove-Item -LiteralPath $workRoot -Recurse -Force
    }
}