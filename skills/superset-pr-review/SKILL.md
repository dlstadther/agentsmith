---
name: superset-pr-review
description: Use when the user wants to open a dedicated Superset workspace for a GitHub pull request or GitLab merge request and run a code review inside it.
---

# superset-pr-review

Creates a Superset workspace scoped to a PR/MR branch and launches a code review agent inside it. Does not open the workspace — outputs the open command for the user to run.

## Usage

```
/superset-pr-review <pr-or-mr-url> [review instructions]
```

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

| User input after URL | Prompt to pass to agent |
|---|---|
| None or unclear | `/code-review` |
| Contains "roborev" | `/roborev-review` |
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
Creates workspace `review-pr-142`, agent prompt: `/code-review`

**RoboRev review:**
```
/superset-pr-review https://github.com/acme/api/pull/142 use roborev
```
Creates workspace `review-pr-142`, agent prompt: `/roborev-review`

**Custom prompt:**
```
/superset-pr-review https://github.com/acme/api/pull/142 focus on auth and SQL injection risks
```
Creates workspace `review-pr-142`, agent prompt: `focus on auth and SQL injection risks`
