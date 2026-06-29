---
name: superset-pr-review
description: Use when the user wants to open a dedicated Superset workspace for a GitHub pull request or GitLab merge request and run a code review inside it.
version: "1.1.0"
---

# superset-pr-review

Creates a Superset workspace scoped to a PR/MR branch and launches a code review agent inside it. Does not open the workspace — outputs the open command for the user to run.

## Usage

```
/superset-pr-review <pr-or-mr-url> [review instructions]
```

## Superset CLI Reference

The Superset CLI is currently in beta. If a command fails or behaves unexpectedly, consult the reference docs or use the built-in help before concluding there is an environment issue:

- Full CLI reference: https://docs.superset.sh/cli/cli-reference
- Top-level help: `superset --help`
- Per-command help: `superset <command> --help` (e.g., `superset workspaces --help`, `superset projects --help`)

Run `superset --help` first if you are unsure whether a flag or subcommand exists — the beta CLI surface changes frequently.

## Steps

### 1. Parse the URL

Extract owner, repo, and PR/MR number from the URL:

| Platform | URL pattern | Number field |
|---|---|---|
| GitHub | `https://github.com/<owner>/<repo>/pull/<number>` | PR number |
| GitLab | `https://gitlab.com/<owner>/<repo>/-/merge_requests/<number>` | MR number |

If the URL doesn't match either pattern, abort and tell the user the expected format.

### 2. Validate repo match

Get the current workspace's remote URL:
```bash
git remote get-url origin
```

Normalize both URLs before comparing:
- Strip trailing `.git`
- Convert SSH format (`git@github.com:owner/repo`) → `github.com/owner/repo`
- Lowercase

Extract owner/repo from each. If they don't match, **abort** with:
```
Error: PR repo (<owner>/<repo>) does not match current workspace repo (<local-owner>/<local-repo>).
Invoke this skill from a workspace for the correct repo.
```

### 3. Find the Superset project ID

```bash
superset projects list --json
```

Find the entry whose `repo` field matches the current repo (normalize as above). Extract its `id` (`prj_…`).

If no match: abort and ask the user to verify with `superset projects list`.

### 4. Determine the review agent prompt

The `--prompt` value is passed as a literal string to the workspace agent — slash-commands are not interpreted there. Use the expanded text below, not a slash-command shorthand.

| User input after URL | Prompt to pass to agent |
|---|---|
| None or unclear | `Review this pull request for correctness bugs, simplification opportunities, and efficiency improvements. Read all changed files in full before forming findings. For each finding include the file path, line number, severity (critical/high/medium/low), a one-sentence description of the problem, and a suggested fix. Group findings by severity, highest first. If no issues are found, say so explicitly.` |
| Contains "roborev" | `Run roborev review --branch --wait to review the pull request branch, then present the results: show the verdict prominently, list findings grouped by severity with file paths and line numbers, and offer to fix them if the verdict is Fail.` |
| Other explicit instructions | Use those instructions verbatim |

### 5. Create the workspace

```bash
superset workspaces create \
  --project <project-id> \
  --name "review-pr-<number>" \
  --pr <number> \
  --local \
  --agent claude \
  --prompt "<review-prompt>"
```

Capture the workspace ID from the output.

### 6. Output the open command — do not execute it

Present this to the user:

```
Workspace created: <workspace-id>

To open it:
  superset workspaces open <workspace-id>
```

## Examples

**Default review:**
```
/superset-pr-review https://github.com/acme/api/pull/142
```
Creates workspace `review-pr-142`. Agent receives the expanded correctness-and-simplification prompt from Step 4.

**RoboRev review:**
```
/superset-pr-review https://github.com/acme/api/pull/142 use roborev
```
Creates workspace `review-pr-142`. Agent receives the expanded `roborev review --branch --wait` prompt from Step 4.

**Custom prompt:**
```
/superset-pr-review https://github.com/acme/api/pull/142 focus on auth and SQL injection risks
```
Creates workspace `review-pr-142`, agent prompt: `focus on auth and SQL injection risks`
