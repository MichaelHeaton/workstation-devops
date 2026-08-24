# jira-cli / confluence-cli — work profile

Automated by `roles/atlassian_cli` on `make apply` when `workstation_profile=work`.

**Source:** [jira-cli & confluence-cli — Team Setup Guide](https://wiki.corp.adobe.com/spaces/~blake/pages/4015541841) (internal wiki, Blake Garner)

These replace the Atlassian MCP server's `jira_*`/`confluence_*` tools with local
Go binaries — no MCP tool schemas loaded into context every turn, help text
loaded on demand instead. Forked from `Adobe-AIFoundations/jira-cli` and
`Adobe-AIFoundations/confluence-cli`.

## CLI vs MCP — measured findings (2026-08-24)

The wiki's token-efficiency pitch was benchmarked against the CLI's own
unflagged output, never against the MCP tools' actual responses. Testing
both side by side on real data (50-issue and 43-issue Jira searches, one
Confluence page read) told a different story:

| Operation | CLI (best flags) | MCP | Winner |
| --------- | ----------------- | --- | ------ |
| Jira search, 50 issues, 4 fields | 29,588 bytes (`--minimize --query`) | ~15,900 bytes | **MCP, ~2x smaller** |
| Jira search, 43 issues (own open tickets) | 33,441 bytes (`--minimize`) | ~13,600 bytes | **MCP, ~2.4x smaller** |
| Confluence page read (same page) | 9,404 bytes (`--markdown --minimize`) | 9,079 bytes | Tie |

MCP's Jira tool flattens `status`/`priority` into `{name, category, color}`;
jira-cli's `--minimize`/`--query` still pass through Jira's raw REST shape
(`statusCategory`, nested `description`, IDs) even at its most aggressive
flags. MCP's Confluence tool already converts to Markdown and trims metadata
by default, so `--markdown --minimize` doesn't buy anything extra there.
Correctness was solid both times — CLI and MCP returned identical keys,
order, and timestamps for the same query.

**When the CLI is actually the better choice:**

- **Bulk operations** — `jira bulk update/transition/comment/mixed` (up to
  100 issues, one stdin-JSON call). No MCP equivalent for bulk update/
  transition/comment (MCP only has batch create + batch changelogs).
- **Attachments** — `attachment download <id> --dest /path` writes straight
  to disk. The MCP equivalent returns a base64 blob into the agent's context
  first — fine for a few KB, real cost for anything larger.
- **Fixed schema footprint** — ~90 `mcp__atlassian__*` tool *names* sit in
  context every turn even lazy-loaded; the CLI costs nothing until `--help`
  is actually invoked.
- **Uses your own PAT**, not whatever identity backs the MCP server —
  matters if that server's access differs from yours on restricted content.
- **Works with no agent in the loop** — shell scripts, cron, `mytools`-style
  aliases; MCP tools only exist inside an MCP client.

**Where MCP is still the better default:** everyday search/read/single-issue
work (smaller payloads, confirmed above) and broader coverage — jira-cli's
own admitted gaps (delete issue, watchers, worklog reads, SLA, ProForma,
epic-link) are all things the MCP tool list already covers.

**Net:** this isn't a wholesale MCP replacement. Reach for the CLI for bulk
changes or attachment-heavy work; keep MCP as the default for search/read.
Nothing here has been wired into `ai-skills` as a default yet — see
"Claude skill files" below.

## What Ansible does

| Step | Automated |
| ------ | ----------- |
| Clone `blake_adobe/jira-cli` → `~/Projects/adobe/jira-cli` | Yes |
| Clone `blake_adobe/confluence-cli` → `~/Projects/adobe/confluence-cli` | Yes |
| `git pull --ff-only` on subsequent applies (clean tree only) | Yes |
| `go build` → `~/.local/bin/jira`, `~/.local/bin/confluence` | Yes |
| Jira PAT (macOS Keychain) | **No** — one-time, see below |
| Confluence PAT (credential helper) | **No** — one-time, see below |
| Claude skill files (`jira-skill.md`, `confluence-skill.md`) | **No** — not yet wired into `ai-skills`; install manually if wanted (see below) |

## Credentials (one-time, manual)

```bash
jira config set email you@adobe.com
pbpaste | jira config set-keychain   # paste a Jira PAT from clipboard first
```

Confluence has no Keychain support — use a credential helper instead of a
plaintext PAT (matches this repo's policy of never storing secrets in
config files):

```bash
echo "CONFLUENCE_EMAIL=you@adobe.com" > ~/.confluence-cli
chmod 600 ~/.confluence-cli
echo 'CONFLUENCE_CREDENTIAL_HELPER=<your command here>' >> ~/.confluence-cli
```

Verify:

```bash
jira auth
confluence search --cql 'type=page' --max 1   # NOT `confluence auth` — 401s on this Data Center instance even when working
```

Both require corp VPN at runtime (`jira.corp.adobe.com` / `wiki.corp.adobe.com`),
same as any other internal Atlassian access.

## Team default

```bash
jira config set default.project CESSS
```

CESSS uses `Closed`, not `Done`, as its resolved status in JQL.

## Claude skill files

The wiki page has two attachments (`jira-skill.md`, `confluence-skill.md`) meant
for `~/.claude/skills/jira/SKILL.md` and `~/.claude/skills/wiki/SKILL.md`. Not
installed by this role or checked into `ai-skills` yet — that's a separate,
deliberately unmade decision (see the tool-adoption evaluation this role came
out of). Install manually to try them:

```bash
cp jira-skill.md ~/.claude/skills/jira/SKILL.md
cp confluence-skill.md ~/.claude/skills/wiki/SKILL.md
```
