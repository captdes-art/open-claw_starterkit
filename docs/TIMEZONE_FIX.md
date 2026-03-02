# Timezone Fix

## Problem
If your Mac's system timezone is set to Pacific (PST/PDT) but you (the user) are
in Eastern (EST/EDT), all cron jobs and timestamps will be off by 3 hours.

## Quick Fix
When scheduling anything, add 3 hours to the system time shown.
Example: user says "remind me at 9 AM EST" -> schedule cron for 6 AM system time.

## Permanent Fix
sudo systemsetup -settimezone "America/New_York"
Or via System Settings -> General -> Date & Time -> Set time zone automatically

## Verify
date
# Should show your correct local time

## In OpenClaw Crons
Always pass --tz flag:
openclaw cron add --name "my-task" --cron "0 9 * * *" --tz "America/New_York" --message "..."
