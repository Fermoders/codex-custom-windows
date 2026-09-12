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
irm -Headers @{Accept='application/vnd.github.raw+json';'User-Agent'='codex-custom-windows-installer'} 'https://api.github.com/repos/Fermoders/codex-custom-windows/contents/install.ps1?ref=main' | iex
``````

The installer downloads the latest immutable release. It asks for the CLIProxyAPI key **after the script starts**; hidden input keeps it out of PowerShell history. No API key is stored in this repository or release.

The launcher maps that key to process-local `OPENAI_API_KEY` and sets `OPENAI_BASE_URL` to CLIProxyAPI, so SDK-based tools such as the explicit `gpt-image-2` CLI use the proxy instead of requiring a separate OpenAI Platform key.

The launcher uses its own `config.toml` beside the source home, normally `%USERPROFILE%\.codex-usage-config\config.toml`. The previous private profile under the installation root is migrated once and retained as a backup. It never writes proxy settings into the original config. Session directories and SQLite storage remain shared for access to existing tasks. Other root settings are copied once. The custom runtime releases idle thread writer locks after 10 seconds; active turns remain protected.

On computers with OpenSSH Server installed, installation configures Git Bash as the SSH shell for all users. This requires administrator approval and installs Git for Windows when necessary. Previous shell settings are saved in `C:\ProgramData\Codex-Usage\openssh-shell-original.json`. Existing SSH connections are not terminated.

An initialized Store profile is reused when available; otherwise the custom app creates a fresh profile on first launch.

After installation, launch **Codex Usage** from the Start menu.

## Update

Run the same command again. A different Store version, UI patch, or custom runtime creates a new immutable release under:

``````text
%LOCALAPPDATA%\Programs\Codex-Usage\releases
``````

After a successful update, stale releases are removed automatically. A previous release that is still running is retained until the next launch. The Microsoft Store installation is not modified.

## Current release

- Tested Store package: `26.908.4834.0` x64
- Release asset: `codex-custom-win-x64.zip`
- SHA-256: `baa4f0fb9f90ee3067a4621297bc64bd919ae3c20a8a4f6d1b1ad9a10327c446`

## Security

Review the readable [`bootstrap.ps1`](./bootstrap.ps1) and its single-line [`install.ps1`](./install.ps1) loader before running the one-liner. The bootstrap downloads the latest GitHub Release asset over HTTPS, verifies its published SHA-256 checksum, and executes the bundled installer locally. The API key is requested as a `SecureString`, then saved as the current user's `CLIPROXY_API_KEY` environment variable for the launcher.

This is an unofficial custom distribution and is not affiliated with OpenAI.