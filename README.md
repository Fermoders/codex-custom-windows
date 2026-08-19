# Codex Custom for Windows

One-command installer for the custom Codex Desktop runtime and CLIProxyAPI usage sidebar.

## Requirements

- Windows 10/11 x64
- App Installer (`winget`) when OpenAI Codex is not installed yet
- Node.js 22.12+ x64 (`node` and `npx` must be available)

## Install with one command

Open **PowerShell** and run:

``````powershell
irm https://raw.githubusercontent.com/Fermoders/codex-custom-windows/main/install.ps1 | iex
``````

The installer downloads the latest immutable release. It asks for the CLIProxyAPI key **after the script starts**; hidden input keeps it out of PowerShell history. No API key is stored in this repository or release.

After installation, launch **Codex Usage** from the Start menu.

## Update

Run the same command again. A different Store version, UI patch, or custom runtime creates a new immutable release under:

``````text
%LOCALAPPDATA%\Programs\Codex-Usage\releases
``````

Existing releases are retained for rollback. The Microsoft Store installation is not modified.

## Current release

- Tested Store package: `26.814.5167.0` x64
- Release asset: `codex-custom-win-x64.zip`
- SHA-256: `4b4bfc746ba526841ddc54b179be8762ae602278795be9096d5e7cf92fc4d84b`

## Security

Review [`install.ps1`](./install.ps1) before running the one-liner. The bootstrap downloads the latest GitHub Release asset over HTTPS, verifies its published SHA-256 checksum, and executes the bundled installer locally. The API key is requested as a `SecureString`, then saved as the current user's `CLIPROXY_API_KEY` environment variable for the launcher.

This is an unofficial custom distribution and is not affiliated with OpenAI.