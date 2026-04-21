# CLAUDE.md

## What This Repo Is

A Claude Code plugin with SDLC skills and commands:

- **`agentsmith:to-beads`** (skill) — Converts a markdown plan, spec, or design doc into Beads issues (epic + tasks + deps + gap review). Auto-activated by context; requires `bd` (Beads CLI), installed and initialized.
- **`/agentsmith:setup-devcontainer`** (command) — Scaffolds an agent-ready devcontainer for a repo: firewall-protected container, `~/.claude` mount, toolchain detection, and a `make claude` target for CLI-first `--dangerously-skip-permissions` usage.

Skills are auto-activated by Claude based on context.

## Plugin Structure

Skills live at `skills/<name>/SKILL.md` (not `skills/<name>.md`).

## Installing Locally

First, register the local path as a marketplace source (one-time):

```
/plugin marketplace add /path/to/agentsmith
```

Then install/update and reload:

```
/plugin update agentsmith
/reload-plugins
```

No build step. Changes take effect after update + reload.

## Releases & Versioning

Releases are automated via `semantic-release` on every push to `main`. Commit type determines the version bump:

- `feat:` → minor, `fix:` → patch, `feat!:` / `BREAKING CHANGE` → major
- `chore:`, `docs:`, `refactor:`, `ci:`, etc. → no release

**Do not edit `version` in `.claude-plugin/plugin.json` manually** — CI owns that field.

## Key Design Decisions

**`agentsmith:to-beads` always runs a gap review** (Step 5 of the skill) before pushing. The skill comment "The gap review always finds something" is a load-bearing instruction — do not optimize it away.

**`bd edit` is explicitly forbidden** in `agentsmith:to-beads` because it opens `$EDITOR` and blocks agents. Use `bd update --description` instead.

**Dependency direction in Beads:** `bd dep add <waiter> <provider>` — the thing that waits comes first.


<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:ca08a54f -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

## Session Completion

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd dolt push
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
<!-- END BEADS INTEGRATION -->
