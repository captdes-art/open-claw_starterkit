# HEARTBEAT.md - Proactive Checks

Run these checks on rotation (2-4 per heartbeat).
Quiet hours: 11 PM - 7 AM local time. Only break silence for urgent items.

## Checks (cycle through)

- [ ] Urgent emails — any high-priority unread?
- [ ] Calendar — upcoming events in next 24h?
- [ ] System health — disk space, gateway status
- [ ] Weather — relevant conditions for the day?

## State Tracking

Read/write memory/heartbeat-state.json to track last check times.

## Rules

- Don't repeat a check within 30 minutes
- Batch 2-4 checks per heartbeat to save tokens
- If nothing to report: HEARTBEAT_OK
- If something needs attention: report it, skip HEARTBEAT_OK

## MANDATORY — Every Heartbeat

- [ ] **Pending handoffs** — Check today's daily note for any `## Pending: Waiting on` section.
  If found, surface it: "Cap, still waiting on: [item]." Do not let open handoffs go stale.
