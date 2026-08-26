# Codex Custom for Windows

One-command installer for the custom Codex Desktop runtime and CLIProxyAPI usage sidebar.

## Requirements

- Windows 10/11 x64
- App Installer (`winget`) for automatic installation of OpenAI Codex or Node.js when missing
- Node.js 22.12+ x64 is installed automatically through `winget` when missing
- Enough free space for a local Codex copy and temporary ASAR extraction; the installer checks this before copying

## Install with one command

Open **PowerShell** and run:

``````powershell
irm https://raw.githubusercontent.com/Fermoders/codex-custom-windows/main/install.ps1 | iex
``````

The installer downloads the latest immutable release. It asks for the CLIProxyAPI key **after the script starts**; hidden input keeps it out of PowerShell history. No API key is stored in this repository or release.

The launcher maps that key to process-local `OPENAI_API_KEY` and sets `OPENAI_BASE_URL` to CLIProxyAPI, so SDK-based tools such as the explicit `gpt-image-2` CLI use the proxy instead of requiring a separate OpenAI Platform key.

An existing `config.toml` or `auth.json` is not required. The launcher keeps the existing `CODEX_HOME`, so current and future tasks stay directly available in both the Store and patched applications. The custom runtime releases an idle thread writer lock 10 seconds after its last UI subscriber disconnects instead of retaining it for 30 minutes; active turns remain protected.

An initialized Store profile is reused when available; otherwise the custom app creates a fresh profile on first launch.

After installation, launch **Codex Usage** from the Start menu.

## Update

Run the same command again. A different Store version, UI patch, or custom runtime creates a new immutable release under:

``````text
%LOCALAPPDATA%\Programs\Codex-Usage\releases
``````

Existing releases are retained for rollback. The Microsoft Store installation is not modified.

## Current release

- Tested Store package: `26.820.7780.0` x64
- Release asset: `codex-custom-win-x64.zip`
- SHA-256: `f7dcab699a0c7590ca97ac61723906d69242d4192810ba18e00e6712c0bea64a`

## Security

Review [`install.ps1`](./install.ps1) before running the one-liner. The bootstrap downloads the latest GitHub Release asset over HTTPS, verifies its published SHA-256 checksum, and executes the bundled installer locally. The API key is requested as a `SecureString`, then saved as the current user's `CLIPROXY_API_KEY` environment variable for the launcher.

This is an unofficial custom distribution and is not affiliated with OpenAI.