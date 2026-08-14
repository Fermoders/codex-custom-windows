# Codex Custom for Windows

One-command installer for the custom Codex Desktop runtime and CLIProxyAPI usage sidebar.

## Requirements

- Windows 10/11 x64
- OpenAI Codex installed from Microsoft Store
- Launch the Store app once, sign in, then close it completely
- Node.js 22.12+ x64 (`node` and `npx` must be available)

## Install with one command

Open **PowerShell** and run:

```powershell
irm https://raw.githubusercontent.com/Fermoders/codex-custom-windows/main/install.ps1 | iex
```

The installer downloads the latest immutable release. It asks for the CLIProxyAPI key **after the script starts**; hidden input keeps it out of PowerShell history. No API key is stored in this repository or release.

After installation, launch **Codex Usage** from the Start menu.

## Update

Run the same command again. A different Store version, UI patch, or custom runtime creates a new immutable release under:

```text
%LOCALAPPDATA%\Programs\Codex-Usage\releases
```

Existing releases are retained for rollback. The Microsoft Store installation is not modified.

## Current release

- Tested Store package: 26.803.10989.0 x64
- Release asset: `codex-custom-win-x64.zip`
- SHA-256: `06fbc2d4801e6c1f7878ffd64496040ae5d6f1920b9786fc2323c49a4eb4a83f`

## Security

Review [`install.ps1`](./install.ps1) before running the one-liner. The bootstrap downloads the latest GitHub Release asset over HTTPS and executes the bundled installer locally. The API key is requested as a `SecureString`, then saved as the current user's `CLIPROXY_API_KEY` environment variable for the launcher.

This is an unofficial custom distribution and is not affiliated with OpenAI.
