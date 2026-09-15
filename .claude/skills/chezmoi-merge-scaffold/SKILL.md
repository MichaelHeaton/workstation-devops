---
name: chezmoi-merge-scaffold
description: Scaffold a new run_onchange_merge-claude-*.sh.tmpl chezmoi script in this repo's dotfiles/ directory, from a short description of what needs merging into ~/.claude/settings.json (permission entries, hooks, plugin/marketplace registration, or any other additive JSON key). Produces a real, correctly-structured .tmpl file matching this repo's existing merge scripts — not a generic guess. Use when asked to "add a new Claude permission via chezmoi", "scaffold a merge script", "add a run_onchange_merge script", "register a new hook/plugin through chezmoi", or "this needs its own merge-claude script".
compatibility: Local machine only — targets this repo's chezmoi dotfiles/ layout and ~/.claude/settings.json. Requires jq to test the generated script.
version: 1.0.0
last_updated: 2026-09-14
---

# chezmoi-merge-scaffold

Every Claude Code policy change in this repo (permissions, hooks, plugin
registration) ships as its own `run_onchange_merge-claude-*.sh.tmpl` under
`dotfiles/`, applied by `make apply`. These scripts share one non-negotiable
contract: **additive-only, idempotent, jq-based**. This skill scaffolds a new
one from a plain description of what needs merging, so every new script
matches the existing four (`run_onchange_merge-claude-hooks.sh.tmpl`,
`-security.sh.tmpl`, `-allow.sh.tmpl`, `-plugins.sh.tmpl`) instead of drifting
into a one-off shape.

## Before you start

Read the two closest existing examples in full, not just the one that seems
most similar:

- `dotfiles/run_onchange_merge-claude-allow.sh.tmpl` — flat array merge
  (`permissions.allow`), the simplest shape
- `dotfiles/run_onchange_merge-claude-hooks.sh.tmpl` — per-event hook-block
  merge with presence checks
- `dotfiles/run_onchange_merge-claude-plugins.sh.tmpl` — keyed-object merge,
  wrapped in `{{ if .feature_work -}}` gating

The starter template is `.claude/skills/chezmoi-merge-scaffold/assets/run_onchange_merge-claude-TOPIC.sh.tmpl.template`
— copy it, don't retype the boilerplate.

## 1. Nail down the shape of the merge

Ask (or infer from the description) which JSON shape is being merged into
`~/.claude/settings.json`:

| What's being added | Target path | Merge pattern |
| --- | --- | --- |
| Permission strings (allow/deny) | `.permissions.allow` / `.permissions.deny` | A — flat array, dedupe with `unique` |
| A hook (PreToolUse/PostToolUse/etc.) | `.hooks.<Event>` | B — presence-check by `matcher`, append one block |
| Plugin/marketplace registration | `.extraKnownMarketplaces` / `.enabledPlugins` | C — keyed object, `has("key")` check |
| Something else (new top-level key) | `.<newKey>` | Closest of A/B/C by shape — ask before inventing a fourth pattern |

If the description mixes shapes (e.g. "add a permission and a hook for the
same feature"), that's still **one script** — real examples merge multiple
sections in one file (see `-hooks.sh.tmpl` merging four separate hook types).

## 2. Pick the topic name and file path

- Topic: short noun, e.g. `mcp-audit`, `subagent-policy` — becomes `__TOPIC__`
  everywhere (script name, version-bump comment, echo prefixes)
- File: `dotfiles/run_onchange_merge-claude-<topic>.sh.tmpl`
- Do not reuse an existing topic name (`hooks`, `security`, `allow`,
  `plugins`) — add a new section to that script instead if the new merge
  logically belongs there (e.g. one more hook goes in `-hooks.sh.tmpl`, not a
  new file)

## 3. Fill in the template

Copy the asset file to the new path, then replace every `__PLACEHOLDER__`:

- `__TOPIC__` / `__TOPIC_UPPER__` — the topic name, and its shell-safe
  uppercase variable form (e.g. `mcp-audit` → `MCP_AUDIT`)
- `__ONE_LINE_PURPOSE__` — one sentence, matches the header-comment style of
  the real examples
- `__ADDITIVE_GUARANTEE__` — spell out exactly what is never removed
  (existing entries of the same kind, plus everything else in the file —
  `mcpServers`, `model`, `theme`, `additionalDirectories`, etc.)
- `__JSON_PATH__`, `__EVENT__`, `__MATCHER__`, `__KEY__`, `__VALUE__` per the
  pattern chosen in step 1
- Delete the two unused merge-pattern blocks (A/B/C) — ship exactly one
  active pattern per section, uncommented

If the merge target is genuinely work-only (an internal marketplace, a
work-only hook), keep the `{{ if .feature_work -}}` / `{{ else -}}` /
`{{ end -}}` wrapper from the template. **Delete all three lines** if it
applies to every machine — `-hooks.sh.tmpl`, `-security.sh.tmpl`, and
`-allow.sh.tmpl` are all ungated; only `-plugins.sh.tmpl` is gated, because
its marketplace is Adobe-internal.

## 4. Version-bump comment

Every script ends its header with a version string chezmoi's `run_onchange_`
hashing keys off of:

```
__TOPIC__-policy-version: v1.0.0
```

Start new scripts at `v1.0.0`. Bump this string (not just the code) on any
future edit that must re-run on machines that already applied an earlier
version — chezmoi only re-runs `run_onchange_` scripts when their rendered
content changes, so a logic fix with no version bump silently never re-runs
on machines that already have the file.

## 5. Validate before opening a PR

```bash
bash -n dotfiles/run_onchange_merge-claude-<topic>.sh.tmpl   # syntax check
shellcheck dotfiles/run_onchange_merge-claude-<topic>.sh.tmpl
```

Then dry-run the merge logic against a throwaway settings file (strip the
`{{ }}` chezmoi tags first if the script is gated, or copy the rendered
`~/.claude/settings.json.tmpl` output):

```bash
cp ~/.claude/settings.json /tmp/settings-test.json
SETTINGS=/tmp/settings-test.json bash -c "$(sed 's|\$HOME/.claude/settings.json|/tmp/settings-test.json|' dotfiles/run_onchange_merge-claude-<topic>.sh.tmpl)"
# run it a second time — output should say "already present" / "up to date",
# never add duplicates
```

Confirm:

- First run reports what it added; second run reports everything already
  present (idempotency)
- `jq . /tmp/settings-test.json` still parses (no malformed merge)
- Nothing outside the intended key changed (`diff` against the pre-run copy
  minus the intended key)

## 6. Wire it up

Reference the new script from `CLAUDE.md`'s "To change Claude policy" line if
it introduces a new category worth naming, same as hooks/security/allow/
plugins are already listed there. Commit, branch, PR per this repo's
`CLAUDE.md` branch rules — never push straight to `main`.
