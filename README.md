# agentsmith

Skills that put the human in command of their agents.

## Prerequisites

- **[Claude Code](https://claude.ai/code)** — required to use plugins and run commands
- **[Beads](https://github.com/gastownhall/beads)** (`bd`) — required for `from-spec`. Beads is a local-first issue tracker operated entirely from the CLI. Install and initialize it before using any `from-spec` commands.
- **[GitHub CLI](https://cli.github.com/)** (`gh`) — required for `review-pr`. Must be authenticated (`gh auth login`) against the GitHub account you want to post reviews from.

## Contents

### Commands

| Command | Description |
|---|---|
| `/agentsmith:from-spec` | Convert a markdown spec or design doc into Beads issues (epic + tasks + dependencies + gap review) |
| `/agentsmith:review-pr` | Review a PR with parallel multi-agent analysis. Presents draft for approval before posting. Accepts a PR URL or `owner/repo#number`. |

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

/agentsmith:review-pr https://github.com/owner/repo/pull/123
/agentsmith:review-pr owner/repo#123
/agentsmith:review-pr 123
```

## Future Improvements

- **`review-pr` skill-to-skill delegation** — Once Claude Code supports a skill invoking another skill or command, `review-pr` should delegate its core review logic to a dedicated marketplace code review plugin (e.g., `superpowers:code-reviewer`) and focus solely on repo context, multi-agent orchestration, and the user-approval-before-posting workflow. Tracked upstream: [anthropics/claude-code#38719](https://github.com/anthropics/claude-code/issues/38719).

## License

MIT
