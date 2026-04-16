# CLAUDE.md

## What This Repo Is

A Claude Code plugin with two SDLC commands:

- **`/agentsmith:from-spec`** — Converts a markdown spec into Beads issues (epic + tasks + deps + gap review). Requires `bd` (Beads CLI), installed and initialized.
- **`/agentsmith:review-pr`** — Parallel multi-agent PR review with confidence scoring; presents a draft before posting. Requires `gh`, authenticated.

Skills mirror the commands and are auto-activated by Claude based on context.

## Plugin Structure

Skills live at `skills/<name>/SKILL.md` (not `skills/<name>.md`).

## Installing Locally

```bash
/plugin install /path/to/agentsmith@local
/plugin update agentsmith
```

No build step. Changes take effect on re-install or update.

## Key Design Decisions

**`review-pr` uses five parallel agents** (CLAUDE.md compliance, bug scan, git history, prior PR comments, code comment intent), then dispatches one Haiku confidence scorer per finding. Only findings scored ≥ 75 appear in the draft. The draft is always shown to the user for approval before posting — never auto-posted.

**`from-spec` always runs a gap review** (Step 5 of the skill) before pushing. The skill comment "The gap review always finds something" is a load-bearing instruction — do not optimize it away.

**`bd edit` is explicitly forbidden** in `from-spec` because it opens `$EDITOR` and blocks agents. Use `bd update --description` instead.

**Dependency direction in Beads:** `bd dep add <waiter> <provider>` — the thing that waits comes first.
