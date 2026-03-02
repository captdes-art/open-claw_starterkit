#!/usr/bin/env python3
"""
Skipper Telegram Rescue Poller
Runs every 2 minutes as a background LaunchAgent.
ONLY activates when the gateway is DOWN - otherwise exits quietly.
This avoids conflicting with the gateway's own Telegram polling.

When gateway is dead:
  /ping or /status -> confirms gateway is down, offers /restart
  /restart         -> restarts the gateway, confirms recovery
  /help            -> shows available commands
"""
import json, os, subprocess, urllib.request, urllib.parse, sys, datetime

OPENCLAW_BIN = "/opt/homebrew/bin/openclaw"
CONFIG_FILE  = os.path.expanduser("~/.openclaw/openclaw.json")
STATE_FILE   = os.path.expanduser("~/.openclaw/logs/rescue-state.json")
LOG_FILE     = os.path.expanduser("~/.openclaw/logs/rescue.log")
CHAT_ID      = "YOUR_TELEGRAM_CHAT_ID"

try:
    cfg = json.load(open(CONFIG_FILE))
    TOKEN = cfg["channels"]["telegram"]["botToken"]
except Exception as e:
    open(LOG_FILE, "a").write("Config error: " + str(e) + "\n")
    sys.exit(1)

BASE = "https://api.telegram.org/bot" + TOKEN

def log(msg):
    ts = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    open(LOG_FILE, "a").write(ts + " " + msg + "\n")

def send(text):
    data = urllib.parse.urlencode({"chat_id": CHAT_ID, "text": text}).encode()
    try:
        urllib.request.urlopen(BASE + "/sendMessage", data, timeout=10)
    except Exception as e:
        log("send error: " + str(e))

def get_updates(offset=0):
    url = BASE + "/getUpdates?offset=" + str(offset) + "&limit=10&timeout=1&allowed_updates=message"
    try:
        resp = urllib.request.urlopen(url, timeout=10)
        return json.loads(resp.read())
    except Exception as e:
        log("getUpdates error: " + str(e))
        return None

def load_state():
    try:
        return json.load(open(STATE_FILE))
    except:
        return {"offset": 0, "notified_down": False}

def save_state(state):
    json.dump(state, open(STATE_FILE, "w"))

def is_gateway_alive():
    try:
        r = subprocess.run([OPENCLAW_BIN, "gateway", "status"],
                           capture_output=True, text=True, timeout=15)
        return "RPC probe: ok" in r.stdout
    except:
        return False

def restart_gateway():
    log("Restart requested via Telegram rescue")
    send("Skipper Rescue: Restarting gateway now...")
    subprocess.run([OPENCLAW_BIN, "gateway", "restart"],
                   capture_output=True, timeout=30)
    import time; time.sleep(10)
    if is_gateway_alive():
        log("Restart successful")
        send("Back online! Gateway restarted. What do you need, Cap?")
        return True
    else:
        log("Restart FAILED")
        send("WARNING: restart attempted but gateway still not responding. Check the Mac.")
        return False

# --- MAIN LOGIC ---

state = load_state()

if is_gateway_alive():
    # Gateway is fine - reset notification state and exit quietly
    if state.get("notified_down"):
        log("Gateway healthy again - rescue standing down")
        state["notified_down"] = False
        state["offset"] = 0  # reset offset so we catch fresh commands next outage
        save_state(state)
    sys.exit(0)

# Gateway is DOWN - rescue mode active
log("Gateway DOWN - rescue poller activating")

# Notify Des once per outage (not every 2 min)
if not state.get("notified_down"):
    send("Skipper is not responding. Gateway appears to be DOWN.\nSend /restart to auto-recover or /ping to recheck.")
    state["notified_down"] = True
    save_state(state)

# Poll for commands from Des
result = get_updates(state.get("offset", 0))
if not result or not result.get("ok"):
    sys.exit(0)

for update in result.get("result", []):
    uid = update["update_id"]
    state["offset"] = max(state.get("offset", 0), uid + 1)

    msg = update.get("message", {})
    chat_id = str(msg.get("chat", {}).get("id", ""))
    text = (msg.get("text") or "").strip().lower()

    if chat_id != CHAT_ID:
        continue

    log("Rescue command received: " + text)

    if text in ("/restart", "/skipper restart", "restart skipper", "/skipper_restart"):
        if restart_gateway():
            state["notified_down"] = False
            state["offset"] = 0
    elif text in ("/ping", "/status", "/alive"):
        send("Gateway is still DOWN. Send /restart to auto-recover.")
    elif text == "/help":
        send("Skipper Rescue (gateway is currently DOWN):\n/restart - restart gateway\n/ping - recheck status\n/help - this message")

save_state(state)
