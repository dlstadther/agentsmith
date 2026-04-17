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

## License

MIT
