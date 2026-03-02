# Setup Guide

## 1. Install OpenClaw
npm install -g openclaw
openclaw setup

## 2. Configure Telegram Bot
- Create a bot via @BotFather on Telegram
- Get your bot token
- Get your chat ID (message @userinfobot)
- Add to openclaw config: openclaw config set channels.telegram.botToken YOUR_TOKEN

## 3. Install the Watchdog
Edit scripts/watchdog.sh — replace YOUR_TELEGRAM_CHAT_ID and YOUR_HOME with your values.
Copy launchagents/ai.openclaw.watchdog.plist to ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/ai.openclaw.watchdog.plist

## 4. Install the Rescue Poller
Edit scripts/telegram-rescue.py — replace YOUR_TELEGRAM_CHAT_ID with your value.
Copy launchagents/ai.openclaw.rescue.plist to ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/ai.openclaw.rescue.plist

## 5. Set Up Workspace Backup (Optional)
Create a private GitHub repo for your workspace.
Edit scripts/git_autosync.sh with your repo URL.
openclaw cron add --name workspace-autosync --cron "0 * * * *" --message "bash ~/workspace/scripts/git_autosync.sh"

## 6. Copy Templates
Copy templates/ into your OpenClaw workspace folder (~/.openclaw/workspace/).
Customize SOUL.md with your assistant's identity and persona.
Customize AGENTS.md with your workspace rules.
