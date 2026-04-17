# CLAUDE.md

## What This Repo Is

A Claude Code plugin with one SDLC command:

- **`/agentsmith:from-spec`** — Converts a markdown spec into Beads issues (epic + tasks + deps + gap review). Requires `bd` (Beads CLI), installed and initialized.

Skills mirror the commands and are auto-activated by Claude based on context.

## Plugin Structure

Skills live at `skills/<name>/SKILL.md` (not `skills/<name>.md`).

## Installing Locally

```bash
/plugin install /path/to/agentsmith@local
/plugin update agentsmith
```

No build step. Changes take effect on re-install or update.

## Releases & Versioning

Releases are automated via `semantic-release` on every push to `main`. Commit type determines the version bump:

- `feat:` → minor, `fix:` → patch, `feat!:` / `BREAKING CHANGE` → major
- `chore:`, `docs:`, `refactor:`, `ci:`, etc. → no release

**Do not edit `version` in `.claude-plugin/plugin.json` manually** — CI owns that field.

## Key Design Decisions

**`from-spec` always runs a gap review** (Step 5 of the skill) before pushing. The skill comment "The gap review always finds something" is a load-bearing instruction — do not optimize it away.

**`bd edit` is explicitly forbidden** in `from-spec` because it opens `$EDITOR` and blocks agents. Use `bd update --description` instead.

**Dependency direction in Beads:** `bd dep add <waiter> <provider>` — the thing that waits comes first.
