# OpenClaw Starter Kit 🧭

A hardened, battle-tested OpenClaw setup — watchdog, Telegram rescue poller, timezone fix, workspace templates, and lessons learned.

Built by Capt Des O'Sullivan. Shared with the OpenClaw community.

## What's Inside

| Path | What it does |
|---|---|
| `scripts/watchdog.sh` | Gateway watchdog — restarts a frozen/crashed gateway, notifies via Telegram |
| `scripts/telegram-rescue.py` | Rescue poller — lets you /restart the gateway from Telegram when completely dead |
| `scripts/git_autosync.sh` | Hourly workspace backup to GitHub |
| `launchagents/` | macOS LaunchAgent plists for watchdog + rescue poller |
| `templates/SOUL.md` | Starter persona template for your assistant |
| `templates/AGENTS.md` | Workspace rules and conventions template |
| `templates/HEARTBEAT.md` | Proactive check loop template |
| `docs/SETUP.md` | Step-by-step setup guide |
| `docs/LESSONS_LEARNED.md` | Hard-won lessons from production use |
| `docs/TIMEZONE_FIX.md` | Fix for Mac PST vs user EST timezone mismatch |

## Quick Start

1. Clone this repo
2. Follow docs/SETUP.md
3. Customize templates/ for your own identity and workspace
4. Install LaunchAgents from launchagents/
5. Add your Telegram chat ID and bot token where indicated

## Requirements

- macOS (Apple Silicon or Intel)
- OpenClaw installed via npm install -g openclaw
- Telegram bot configured in OpenClaw
- GitHub repo for workspace backup (optional but recommended)
