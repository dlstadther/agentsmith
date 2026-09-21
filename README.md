# agentsmith

A Claude Code marketplace of skills that put the human in command of their agents. Each plugin below installs independently.

## Prerequisites

- **[Claude Code](https://claude.ai/code)** — required to use plugins and run commands
- **[Beads](https://github.com/gastownhall/beads)** (`bd`) — required for `agentsmith-refinement`'s `to-beads` skill. Beads is a local-first issue tracker operated entirely from the CLI. Install and initialize it before using that skill.

## Contents

### Plugins

| Plugin | Description |
|---|---|
| `agentsmith-refinement` | Harden a plan or spec with a cynical gap review, then convert it into Beads issues. |
| `agentsmith-pr-comments` | Address open PR review comments — fix what's actionable, verify, push, resync, reply. |
| `agentsmith-code-reviewer` | Review a diff or PR using a selectable reviewer persona/style. |
| `agentsmith-project-eval` | Evaluate whether a project is safe to install or use. |

Skills are activated automatically by Claude based on context — no explicit invocation needed. See
each plugin's `skills/` directory for the skills it provides and what triggers them.

## Installation

### From GitHub

```
/plugin marketplace add dlstadther/agentsmith
/plugin install <plugin-name>@dlstadther-agentsmith
```

Replace `<plugin-name>` with any plugin from the [Contents](#contents) list above. Install
only the plugin(s) you need — they don't depend on each other.

### From a local clone

```
/plugin marketplace add /path/to/agentsmith
/plugin install <plugin-name>@dlstadther-agentsmith
```

### Updating

```
/plugin update <plugin-name>
```

## Usage

Just describe what you want in natural language:

> "Review this plan for gaps before we build it: path/to/plan.md"
> "Convert this plan into Beads issues: path/to/plan.md"
> "Translate this design doc into tasks: path/to/spec.md"
> "Create Beads issues from path/to/plan.md, using EPIC-ID as the existing epic"

Claude will activate `agentsmith-refinement:critique-plan` or `agentsmith-refinement:to-beads` automatically, based on what you ask for.

## Development

### Setup

Install tool dependencies via [mise](https://mise.jdx.dev/):

```bash
mise install
make install
```

### Running tests

```bash
make test
```

### Releases

Releases are fully automated. Every push to `main` runs `semantic-release`, which analyzes commits since the last tag and cuts a new release if qualifying commits exist.

**Semver mapping:**

| Commit type | Version bump |
|---|---|
| `feat:` | minor |
| `fix:` | patch |
| `feat!:` / `BREAKING CHANGE` footer | major |
| `chore:`, `docs:`, `refactor:`, `ci:`, etc. | no release |

The release process:
1. Bumps `version` in every `plugins/*/.claude-plugin/plugin.json` (one repo-wide version across all plugins)
2. Updates `CHANGELOG.md`
3. Creates a git tag (`vX.Y.Z`)
4. Publishes a GitHub Release with changelog notes

> **Note:** The `version` field in `plugins/*/.claude-plugin/plugin.json` is managed by CI. Do not edit it manually.

## License

MIT
