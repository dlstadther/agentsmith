# agentsmith

A Claude Code marketplace of skills that put the human in command of their agents. Each plugin below installs independently.

## Prerequisites

- **[Claude Code](https://claude.ai/code)** — required to use plugins and run commands
- **[Beads](https://github.com/gastownhall/beads)** (`bd`) — required for `agentsmith-to-beads`. Beads is a local-first issue tracker operated entirely from the CLI. Install and initialize it before using this plugin.

## Contents

### Plugins

| Plugin | Skill | Triggered by |
|---|---|---|
| `agentsmith-to-beads` | `agentsmith-to-beads:to-beads` | "convert plan to Beads", "translate design doc into tasks", "create Beads issues from this spec" |
| `agentsmith-superset-pr-review` | `agentsmith-superset-pr-review:superset-pr-review` | "open a Superset workspace for this PR", "review this PR/MR in Superset" |

Skills are activated automatically by Claude based on context — no explicit invocation needed.

## Installation

### From GitHub

```
/plugin marketplace add dlstadther/agentsmith
/plugin install agentsmith-to-beads@dlstadther-agentsmith
/plugin install agentsmith-superset-pr-review@dlstadther-agentsmith
```

Install only the plugin(s) you need — they don't depend on each other.

### From a local clone

```
/plugin marketplace add /path/to/agentsmith
/plugin install agentsmith-to-beads@dlstadther-agentsmith
```

### Updating

```
/plugin update agentsmith-to-beads
/plugin update agentsmith-superset-pr-review
```

## Usage

Just describe what you want in natural language:

> "Convert this plan into Beads issues: path/to/plan.md"
> "Translate this design doc into tasks: path/to/spec.md"
> "Create Beads issues from path/to/plan.md, using EPIC-ID as the existing epic"

Claude will activate `agentsmith-to-beads:to-beads` automatically.

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
