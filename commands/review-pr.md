---
description: >
  Review a pull request with parallel multi-agent analysis. Presents the draft
  review for approval before posting to GitHub. Accepts a PR URL or owner/repo#number.
allowed-tools: Bash, Agent
---

# Review Pull Request

Conduct a comprehensive PR review with parallel multi-agent analysis. This command analyzes code changes across five dimensions, scores findings for confidence, and presents a draft review for your approval before posting.

---

## Arguments

| Argument | Description | Format |
|----------|-------------|--------|
| PR reference | The PR to review | Full GitHub URL, `owner/repo#123`, or just `123` if in the repo |

Examples:
- `https://github.com/owner/repo/pull/123`
- `owner/repo#123`
- `123` (when current directory is the repo)

---

## Steps

### 1. Parse PR reference and fetch metadata

Parse `$ARGUMENTS` to extract owner, repo, and PR number using the following rules:

1. If `$ARGUMENTS` starts with `https://github.com/`, extract from URL: `https://github.com/{owner}/{repo}/pull/{number}`
2. If `$ARGUMENTS` contains `#`, parse as `owner/repo#number`
3. If `$ARGUMENTS` is a number, detect the repo from `git remote get-url origin` in the current working directory, normalize SSH and HTTPS URLs to `owner/repo` format
4. If `$ARGUMENTS` is empty or parsing fails, print the following message and stop:
   > Please provide a PR reference: full GitHub URL, owner/repo#123, or just a number if run from inside the repo.

Fetch PR metadata using `gh pr view {owner}/{repo}/{number} --json state,isDraft,author,headRefName,baseRefName,baseRefOid,headRefOid,files --repo {owner}/{repo}`. Stop if the PR does not exist.

### 2. Check PR eligibility

Verify all of the following conditions:

- **Not closed:** If the PR state is "CLOSED", print "PR is already closed. Skipping review." and stop.
- **Not draft:** If `isDraft` is true, print "PR is a draft. Skipping review." and stop.
- **Not already reviewed by authenticated user:** Run the following to check if the authenticated user has already reviewed:
  ```bash
  gh api repos/{owner}/{repo}/pulls/{number}/reviews --jq '[.[] | select(.user.login == "'"$(gh api user --jq .login)"'")] | length > 0'
  ```
  If this returns `true`, print "You have already reviewed this PR." and stop.

### 3. Detect codebase access tier

Determine whether the current working directory is the target repository:

**Tier A (CWD is target repo):**
1. Run `git remote get-url origin` in the current directory
2. Normalize both the remote URL and the PR repo reference to `owner/repo` format:
   - SSH: `git@github.com:{owner}/{repo}.git` → `{owner}/{repo}`
   - HTTPS: `https://github.com/{owner}/{repo}.git` or `https://github.com/{owner}/{repo}` → `{owner}/{repo}`
3. If they match, declare Tier A access. All PR files are locally available.
4. **Caveat:** If the user's local HEAD diverges significantly from the PR's base branch, file contents may be stale. In that case, prefer fetching files at `baseRefOid` via `gh api repos/{owner}/{repo}/contents/{path}?ref={baseRefOid}` (same as Tier B) rather than reading from the local working tree.

**Tier B (CWD is not target repo):**
If Tier A does not match, declare Tier B access. Use `gh api repos/{owner}/{repo}/contents/{path}?ref={sha}` for selective file fetching (see Step 5).

### 4. Gather PR diff and file list

Run `gh pr diff {owner}/{repo}/{number} --repo {owner}/{repo}` to fetch the full unified diff.

Extract the file list and changed line ranges. For each file touched by the PR, record:
- `filename`
- `status` (added, modified, deleted)
- `patch` (the diff hunks from the unified diff output)

### 5. Collect CLAUDE.md files

Build a list of CLAUDE.md files to reference during review. Collect from:

1. **Root CLAUDE.md:** `{owner}/{repo}/CLAUDE.md` (if it exists)
2. **Directory-level CLAUDE.md files:** For each unique directory touched by the PR (e.g., if PR modifies `src/auth/login.js`, check for `src/CLAUDE.md` and `src/auth/CLAUDE.md`), fetch `CLAUDE.md` at each directory level if it exists.

**Access method depends on tier:**

- **Tier A:** Read directly from filesystem using relative paths from CWD.
- **Tier B:** Use `gh api repos/{owner}/{repo}/contents/{path}?ref={baseRefOid} --jq '.content | @base64d' 2>/dev/null || true` to fetch file contents. Missing files (404) should be silently skipped using error suppression.

If a CLAUDE.md cannot be fetched or does not exist, skip it (no error).

Concatenate all collected CLAUDE.md files into a single context block.

### 6. Dispatch five parallel review agents

Dispatch all five review agents in parallel using the Agent tool in a single message. All five agents receive identical shared context:

- Full PR metadata as JSON: owner, repo, number, author, head branch name, base branch name
- Full unified diff from Step 4
- File list from Step 4
- Concatenated CLAUDE.md file contents from Step 5

Each agent applies its own specific focus to this identical shared input.

**Agent 1: CLAUDE.md Compliance**

Review the diff for violations of rules that apply to written code (not meta-instructions like planning or git workflows). Check:
- Commit message style (if amended during PR)
- Code structure, naming, or patterns explicitly required
- Forbidden patterns or technologies explicitly prohibited
- Documentation or comment requirements
- Any rule that would be caught in automated code review (linting, formatting, etc.)

Flag violations with one-sentence explanation per rule broken. Ignore meta-instructions like issue workflows or planning guidelines—those are not reviewed in code.

Output format: List each violation as `{rule}: {explanation}`.

**Agent 2: Bug Scan**

Focus exclusively on the diff. Scan for logic errors, potential crashes, incorrect algorithms, or security issues. Do not nitpick style, naming, or performance micro-optimizations. Look for:
- Off-by-one errors, boundary conditions
- Null pointer dereferences or unchecked optional values
- Race conditions or concurrency issues
- Incorrect error handling
- Logic that contradicts its apparent intent

Output format: List each potential bug as `{location}: {one-sentence description}`.

**Agent 3: Git History Context**

Review recent commit history (last 50 commits) touching the same files as the PR. Look for:
- Recent commits that contradict or revert patterns being introduced
- Commits with messages indicating intent that may conflict with the PR changes
- Recent refactorings being undone or bypassed

Output format: List conflicts as `{file}: {description of conflicting recent change}`.

**Agent 4: Prior PR Comments**

Review merged PRs (last 20 merged PRs) that touched any of the same files as the current PR. Examine PR comments from reviewers for patterns or feedback that may still apply. Look for:
- Recurring feedback on the same files (e.g., "always add error handling here")
- Architectural decisions that were documented in PR discussions
- Patterns that were explicitly rejected in prior reviews

Output format: List recurring patterns as `{file}: {feedback that may apply}`.

**Agent 5: Code Comment Compliance**

Scan the existing code comments in files touched by the PR. Look for explicit intent statements (e.g., "this function must always validate input") or documented assumptions. Check whether the PR changes violate these documented intents.

Output format: List violations as `{location}: {one-sentence explanation of violated intent}`.

### 7. Confidence scoring (run in parallel)

For each issue found across all five agents, dispatch one Haiku scorer per issue (N scorers total, one per issue discovered across all 5 agents). Dispatch all scorers in parallel using the Agent tool in a single message.

Each scorer receives:
- The original issue text from the agent
- The relevant diff hunk (the specific changed lines involved)
- All CLAUDE.md files collected in Step 5 (full context—do not attempt to filter which ones are "relevant")

Score using the following rubric:

**Confidence Scoring Rubric**

- **0**: False positive that doesn't stand up to scrutiny, or a pre-existing issue
- **25**: Might be real, unverified, or stylistic and not explicitly in CLAUDE.md
- **50**: Verified real issue but a nitpick or rare in practice
- **75**: Verified, likely in practice, important — or directly required by CLAUDE.md
- **100**: Confirmed, will occur frequently, evidence is direct

For CLAUDE.md issues: scorer must verify the rule is actually stated, not just implied.

The scorer responds with a single integer: the confidence score (0–100).

**Filter findings:** Only include issues with confidence score ≥ 75.

### 8. Format draft review

Construct the draft review comment. If issues were found (after filtering by confidence ≥ 75):

```
### Code review

Found N issue(s):

1. <brief description>

   `file.py:L10-L20` — <one-sentence explanation with quoted evidence>

2. ...

🤖 Generated with [Claude Code](https://claude.ai/code)
```

If no issues were found:

```
### Code review

No issues found. Checked for CLAUDE.md compliance, bugs, git history, prior PR feedback, and code comment intent.

🤖 Generated with [Claude Code](https://claude.ai/code)
```

### 9. Present draft and wait for approval

Print the draft review and prompt the user with:

```
Review draft above. Reply with one of:
- post    — post this review to the PR
- cancel  — discard review
- [edited text] — paste edited version to post instead
```

Wait for the user's response. Do not proceed until the user provides explicit input.

If the user replies with edited text, use that as the review body instead.
If the user replies `cancel`, stop and exit.
If the user replies `post`, proceed to Step 10.

### 10. Re-run eligibility check and post review

Before posting, re-run the eligibility checks from Step 2:
- PR still exists and is not closed
- PR is not a draft
- Authenticated user has not already reviewed it

If any check fails, print the reason and stop without posting.

If all checks pass, post the review comment using the review body captured from Step 9. If the user replied `post`, use the original draft. If the user pasted an edited version, use that instead.

```bash
gh pr comment {owner}/{repo}/{number} --body "$(cat <<'EOF'
<review body>
EOF
)" --repo {owner}/{repo}
```

Print the result (success or error).

---

## Notes

- All agent dispatch and confidence scoring runs in parallel. Do not wait sequentially.
- PR metadata fetches use `--repo {owner}/{repo}` to avoid ambiguity if the user is in a different repository.
- CLAUDE.md files are context for reviewers, not rules to enforce. Only flag direct violations of stated rules.
- File paths in the review use `file:L{start}-L{end}` format when referencing ranges, or `file:L{line}` for single lines.
- The review is a single top-level comment. Do not use inline comments.
