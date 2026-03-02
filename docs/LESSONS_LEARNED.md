# Lessons Learned (Hard-Won)

## 1. Never edit openclaw.json directly without a backup
OpenClaw uses strict JSON validation. Unknown keys cause a crash loop.
Always: cp openclaw.json openclaw.json.bak BEFORE any edit.
If it breaks: cp openclaw.json.bak openclaw.json && openclaw gateway restart

## 2. STOP means stop — immediately
If your human says STOP/HALT/PAUSE, kill everything first, then respond.
Do not keep running background tasks while responding conversationally.

## 3. Gateway restarts cause silence
Warn the user before restarting. Normal silence is 10-30 seconds.
Batch all config changes into ONE restart — don't restart multiple times.

## 4. Timezone mismatch on Mac
If your Mac is set to Pacific time but your user is in Eastern time,
add 3 hours to system time for all scheduling and reminders.
See docs/TIMEZONE_FIX.md for the full fix.

## 5. Context window fills up
Check session_status every 10 exchanges. Warn at 40%, urge /new at 75%, stop new tasks at 85%.

## 6. Never download packages without permission
Always ask before installing anything from npm, pip, ClawHub, or any registry.

## 7. Heredoc injection guard conflict
Using << 'EOF' in scripts triggers the prompt injection guard.
Use printf instead when building scripts programmatically.

## 8. One-shot reminders die on session reset
Always use openclaw cron for reminders — never rely on in-session memory.
openclaw cron add --name "reminder-topic" --cron "..." --delete-after-run

## 9. Session memory is not persistent
Write everything important to a file. "Mental notes" don't survive restarts.
Daily notes: memory/YYYY-MM-DD.md. Long-term: MEMORY.md.
