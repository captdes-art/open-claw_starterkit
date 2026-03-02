# Pending Handoffs — Never Drop the Baton

Sessions end. Context resets. Your human doesn't.

## The Rule

Any time you are mid-task and waiting on your human for a next step — create a repo,
approve something, send a file, anything — write it to the daily note IMMEDIATELY:

```markdown
## Pending: Waiting on [Human Name]
- [What they need to do]
- [What you will do once they confirm]
- Context: [1 sentence — what task this is part of]
```

## Why This Matters

If the session resets before they respond, the next session will find this note
during startup and surface it. Without it, the handoff is silently lost — and
the next session will have no idea what's waiting.

This is exactly what happened during the OpenClaw Starter Kit build:
- Skipper built all the files and asked Des to create the GitHub repo
- The session reset 40 minutes later
- New session had no memory of the pending push
- Des had to re-explain what was happening

A one-line note in the daily file would have prevented the entire confusion.

## How to Write a Pending Handoff

In memory/YYYY-MM-DD.md, add:

```markdown
## Pending: Waiting on Des
- Create GitHub repo at github.com/new (name: my-repo-name, public, no README)
- Once confirmed: push /tmp/my-project to that repo
- Context: Part of [project name] build — all files ready at /tmp/my-project
```

## Heartbeat Integration

Every heartbeat should check today's daily note for open Pending entries:
- If found: surface immediately — "Cap, still waiting on: [item]"
- Do not let open handoffs go stale
- When human confirms, strike the item and proceed

## Closing the Loop

When your human confirms they've done their part:
1. Strike the item from the daily note (or delete the section)
2. Proceed with your next step
3. Log completion in the daily note
