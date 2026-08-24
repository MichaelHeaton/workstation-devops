# jira-cli / confluence-cli — work profile

Automated by `roles/atlassian_cli` on `make apply` when `workstation_profile=work`.

**Source:** [jira-cli & confluence-cli — Team Setup Guide](https://wiki.corp.adobe.com/spaces/~blake/pages/4015541841) (internal wiki, Blake Garner)

These replace the Atlassian MCP server's `jira_*`/`confluence_*` tools with local
Go binaries — no MCP tool schemas loaded into context every turn, help text
loaded on demand instead. Forked from `Adobe-AIFoundations/jira-cli` and
`Adobe-AIFoundations/confluence-cli`.

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
