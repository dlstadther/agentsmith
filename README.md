# agentsmith

Skills that put the human in command of their agents.

## Prerequisites

- **[Claude Code](https://claude.ai/code)** — required to use plugins and run commands
- **[Beads](https://github.com/gastownhall/beads)** (`bd`) — required for `from-spec`. Beads is a local-first issue tracker operated entirely from the CLI. Install and initialize it before using any `from-spec` commands.

## Contents

### Commands

| Command | Description |
|---|---|
| `/agentsmith:from-spec` | Convert a markdown spec or design doc into Beads issues (epic + tasks + dependencies + gap review) |

### Skills

Skills are not invoked directly — Claude activates them automatically based on context. Phrases like "convert this spec to Beads issues" or "translate this design doc into tasks" will trigger `agentsmith:from-spec`. Use the commands above for explicit invocation.

| Skill | Triggered by |
|---|---|
| `agentsmith:from-spec` | "convert spec to Beads", "translate design doc into tasks", "create Beads issues from this plan" |

## Installation

### From GitHub

```
/plugin marketplace add dlstadther/agentsmith
/plugin install agentsmith@dlstadther-agentsmith
```

### From a local clone

```
/plugin install /path/to/agentsmith@local
```

### Updating

```
/plugin update agentsmith
```

## Usage

```
/agentsmith:from-spec path/to/spec.md
/agentsmith:from-spec path/to/spec.md EXISTING-EPIC-ID
```

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
1. Bumps `version` in `.claude-plugin/plugin.json`
2. Updates `CHANGELOG.md`
3. Creates a git tag (`vX.Y.Z`)
4. Publishes a GitHub Release with changelog notes

> **Note:** The `version` field in `.claude-plugin/plugin.json` is managed by CI. Do not edit it manually.

## License

MIT
