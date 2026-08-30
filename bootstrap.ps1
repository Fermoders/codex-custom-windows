$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$owner = 'Fermoders'
$repository = 'codex-custom-windows'
$assetName = 'codex-custom-win-x64.zip'

function Remove-DirectoryBestEffort {
    param(
        [Parameter(Mandatory = $true)][string]$Path
    )

    $lastError = $null
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        if (-not (Test-Path -LiteralPath $Path)) {
            return
        }
        try {
            Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop
            return
        }
        catch [System.IO.DirectoryNotFoundException] {
            if (-not (Test-Path -LiteralPath $Path)) {
                return
            }
            $lastError = $_.Exception
        }
        catch {
            $lastError = $_.Exception
        }
        Start-Sleep -Milliseconds (100 * $attempt)
    }

    if (Test-Path -LiteralPath $Path) {
        Write-Warning "Could not completely remove temporary directory '$Path': $($lastError.Message)"
    }
}

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

    if ($null -ne $asset.size -and [int64]$asset.size -gt 0) {
        $bootstrapRequiredBytes = ([int64]$asset.size * 3) + 256MB
        $tempVolumeRoot = [IO.Path]::GetPathRoot([IO.Path]::GetFullPath($workRoot))
        try {
            $tempDrive = [IO.DriveInfo]::new($tempVolumeRoot)
            if ($tempDrive.IsReady -and $tempDrive.AvailableFreeSpace -lt $bootstrapRequiredBytes) {
                throw "Not enough free space on $tempVolumeRoot to download and extract the installer. Required at least $('{0:N2} GB' -f ($bootstrapRequiredBytes / 1GB)), available $('{0:N2} GB' -f ($tempDrive.AvailableFreeSpace / 1GB))."
            }
        }
        catch [ArgumentException] {
            Write-Warning "Could not determine free space for $tempVolumeRoot. The download will perform the final check."
        }
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

    $bundleArguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $bundleInstaller)
    $existingKey = [Environment]::GetEnvironmentVariable('CLIPROXY_API_KEY', 'User')
    if (-not [string]::IsNullOrWhiteSpace($existingKey)) {
        $bundleArguments += '-ReuseExistingKey'
    }
    & powershell.exe @bundleArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Codex custom installer failed with exit code $LASTEXITCODE."
    }
}
finally {
    Remove-DirectoryBestEffort -Path $workRoot
}