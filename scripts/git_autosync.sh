#!/bin/bash
# Git autosync — hourly push of workspace to skipper-workspace on GitHub
# Runs as cron job. Logs to memory/git-autosync.log

WORKSPACE="$HOME/.openclaw/workspace"
LOG="$WORKSPACE/memory/git-autosync.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

cd "$WORKSPACE" || exit 1

# Load credentials
source "$HOME/.openclaw/credentials/env.sh"

# Set authenticated remote
git remote set-url origin "https://captdes-art:${GITHUB_TOKEN}@github.com/YOUR_GITHUB_USERNAME/YOUR_REPO.git"

# Stage all changes
git add -A

# Only commit if there are changes
if git diff --cached --quiet; then
  echo "[$TIMESTAMP] No changes to sync." >> "$LOG"
  exit 0
fi

# Commit with timestamp
git commit -m "Auto-sync: $TIMESTAMP" >> "$LOG" 2>&1

# Push
if git push origin main >> "$LOG" 2>&1; then
  echo "[$TIMESTAMP] ✅ Pushed successfully." >> "$LOG"
else
  echo "[$TIMESTAMP] ❌ Push failed — check credentials or network." >> "$LOG"
  # Alert via OpenClaw
  openclaw system event --text "⚠️ Git autosync failed at $TIMESTAMP" --mode now 2>/dev/null
fi
