#!/bin/bash
# OpenClaw Gateway Watchdog v2
# Runs every 5 minutes via LaunchAgent (ai.openclaw.watchdog)
# Uses REAL RPC probe (not just HTTP ping) to catch frozen gateways
# Two consecutive failures required before restart (avoids false positives)

OPENCLAW_BIN="/opt/homebrew/bin/openclaw"
CHAT_ID="YOUR_TELEGRAM_CHAT_ID"
LOG="YOUR_HOME/.openclaw/logs/watchdog.log"
STATE_FILE="YOUR_HOME/.openclaw/logs/watchdog-state.json"
CONFIG="YOUR_HOME/.openclaw/openclaw.json"

TELEGRAM_TOKEN=$(python3 -c "import json,sys; cfg=json.load(open('$CONFIG')); print(cfg['channels']['telegram']['botToken'])" 2>/dev/null)

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG"; }

notify() {
  [ -n "$TELEGRAM_TOKEN" ] && curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
    -d "chat_id=${CHAT_ID}" -d "text=$1" > /dev/null 2>&1
}

get_failures() {
  python3 -c "
import json
try:
    d=json.load(open('$STATE_FILE'))
    print(d.get('consecutive_failures',0))
except:
    print(0)
" 2>/dev/null || echo "0"
}

set_failures() {
  local n=$1
  python3 -c "
import json, datetime
f='$STATE_FILE'
d={}
try: d=json.load(open(f))
except: pass
d['consecutive_failures']=$n
d['last_check']=datetime.datetime.utcnow().isoformat()+'Z'
json.dump(d, open(f,'w'))
" 2>/dev/null
}

reset_failures() { set_failures 0; }

rpc_ok() {
  "$OPENCLAW_BIN" gateway status 2>&1 | grep -q "RPC probe: ok"
}

if rpc_ok; then
  log "OK: gateway healthy (RPC probe passed)"
  reset_failures
  exit 0
fi

FAILURES=$(get_failures)
FAILURES=$((FAILURES + 1))
set_failures $FAILURES

log "WARNING: gateway RPC probe failed (consecutive failures: $FAILURES)"

if [ "$FAILURES" -lt 2 ]; then
  log "Waiting for next check to confirm before acting..."
  exit 0
fi

log "ACTION: 2 consecutive failures - beginning recovery"

PIDS=$(pgrep -f "node.*openclaw.*gateway" 2>/dev/null)
if [ -n "$PIDS" ]; then
  log "Killing orphans: $PIDS"
  for pid in $PIDS; do kill -TERM "$pid" 2>/dev/null; done
  sleep 3
  for pid in $PIDS; do kill -9 "$pid" 2>/dev/null; done
  sleep 2
fi

log "Restarting gateway..."
"$OPENCLAW_BIN" gateway stop 2>/dev/null
sleep 2
"$OPENCLAW_BIN" gateway start 2>/dev/null
sleep 10

if rpc_ok; then
  reset_failures
  log "RECOVERED: gateway back up (RPC probe passed)"
  notify "Skipper Watchdog: Gateway was stuck - auto-restarted and confirmed healthy. All good Cap!"
else
  log "FAILED: gateway still not responding after restart"
  notify "ALERT: Skipper gateway DOWN and could not auto-recover. Run on Mac: openclaw gateway restart"
fi
