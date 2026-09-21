---
name: adding-a-plugin
description: Use when adding a new plugin to this marketplace, or a new skill to an existing plugin.
---

# Adding a Plugin or Skill

## Naming: two separate names, don't confuse them

- **Manifest name** (`plugin.json`'s `"name"` field, and the matching entry's `"name"` in
  `marketplace.json`): always `agentsmith-<dir-name>`. This is what users type — `/plugin install
  agentsmith-refinement@dlstadther-agentsmith`, skill invocation `agentsmith-refinement:critique-plan`.
- **Source path** (`plugins/<dir-name>/`, and `marketplace.json`'s `"source"` field): never carries
  the `agentsmith-` prefix. `plugins/refinement`, not `plugins/agentsmith-refinement`.

These are intentionally decoupled: changing the repo-wide prefix later means editing `name` fields,
not renaming directories (see CLAUDE.md's "Plugin Structure" section for why).

## Adding a new plugin — checklist

1. `plugins/<dir-name>/.claude-plugin/plugin.json` — create with `"name": "agentsmith-<dir-name>"`,
   an initial `version` (match the newest version already in `plugins/*/plugin.json`), `description`,
   `author`.
2. `plugins/<dir-name>/skills/<skill-name>/SKILL.md` — the skill content.
3. `.claude-plugin/marketplace.json` — add an entry: `"name": "agentsmith-<dir-name>"`,
   `"source": "./plugins/<dir-name>"`, `"description"`.
4. `.releaserc.json` — add the plugin to **both**:
   - the `prepareCmd` string (another `&& NEXT_RELEASE_VERSION=... ./scripts/bump-version.sh
     plugins/<dir-name>/.claude-plugin/plugin.json`)
   - the `assets` array (`"plugins/<dir-name>/.claude-plugin/plugin.json"`)

   Missing either one means CI silently stops bumping and committing that plugin's version.
5. `README.md` — add a row to the Plugins table.
6. `CLAUDE.md` — add a bullet under "What This Repo Is" describing the plugin and its skill(s).
7. Never hand-edit the `version` field — CI (`.releaserc.json` + `scripts/bump-version.sh`) owns it.

## Adding a new skill to an existing plugin

1. `plugins/<dir-name>/skills/<new-skill-name>/SKILL.md` — the skill content.
2. `CLAUDE.md` — update that plugin's bullet in "What This Repo Is" to mention the new skill.
3. If the new skill changes what the plugin as a whole does, update its `description` in both
   `plugin.json` and `marketplace.json`, and the README table row.
4. No `.releaserc.json` or `marketplace.json` structural change needed — the plugin already has an
   entry there.

## Verify before committing

- Both config files must parse:
  ```bash
  python3 -c "import json; json.load(open('.claude-plugin/marketplace.json')); json.load(open('.releaserc.json'))"
  ```
- Every directory under `plugins/` should appear in `.releaserc.json`'s `prepareCmd` and `assets`.
  Cross-check when in doubt:
  ```bash
  ls plugins
  grep -o 'plugins/[a-z-]*' .releaserc.json | sort -u
  ```
