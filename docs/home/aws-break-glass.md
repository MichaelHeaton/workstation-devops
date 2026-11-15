# Personal AWS — break-glass SSO profile (`specterrealm-management`)

The laptop has exactly one AWS profile: **`specterrealm-management`**, the break-glass
operator profile for the SpecterRealm AWS Organization management account. It is
**SSO only**: no static access keys anywhere.

| Item | Value |
| ---- | ----- |
| Profile | `specterrealm-management` |
| SSO session | `specterrealm` (`https://d-926631fcf2.awsapps.com/start`, `us-west-2`, scope `sso:account:access`) |
| Account | `893407364620` |
| Role | `AdministratorAccess` |
| Region / output | `us-west-2` / `json` |
| Used by | `make op-*` in platform-bootstrap (ADR-011) |

The old `platform-bootstrap` and `cvmtb` key profiles are retired: see
[platform-aws.md](platform-aws.md) and [cvmtb-aws.md](cvmtb-aws.md).

## Rules

- **Break-glass only.** Use it for `make op-*` in platform-bootstrap and nothing else. Never
  for day-to-day work, never from AI tools (Claude Code, Cursor, agents), never in scripts or CI.
  Normal changes go through each repo's pipeline.
- **Chosen on purpose, every time.** Nothing exports `AWS_PROFILE` for it. Pass it explicitly
  (`--profile specterrealm-management`, or the platform-bootstrap Makefile default) and
  `unset AWS_PROFILE` when done if you set it.
- **Do not run `aws configure` or `aws configure sso`.** Ansible owns `~/.aws/config`; those
  commands rewrite it (that is how SSO settings ended up inside the old `platform-bootstrap`
  profile). Change `personal_aws_profiles` / `personal_aws_sso_sessions` in
  `group_vars/personal.yml` instead. A later Cedar Valley MTB SSO session is one more entry in
  each list.
- `~/.aws/credentials` is not managed and should hold no keys.

## First login

```bash
aws sso login --profile specterrealm-management
aws sts get-caller-identity --profile specterrealm-management   # Account 893407364620
```

The SSO token is cached under `~/.aws/sso/cache/` and expires; repeat `aws sso login` when
commands report an expired token.

## Apply just this change (no full playbook run)

From `~/Projects/personal/workstation-devops`, on a personal Mac. The `aws` tag runs only the
three AWS tasks in `roles/personal` and the `shell-personal` marked block in `~/.zshrc`
(see [tags.md](../tags.md)):

```bash
ansible-playbook site.yml -i inventory/localhost.yml -e workstation_profile=personal --tags aws --check --diff
ansible-playbook site.yml -i inventory/localhost.yml -e workstation_profile=personal --tags aws --diff
```

The check run should show changes only to:

- `~/.aws/config`: the `[profile platform-bootstrap]` and `[profile cvmtb]` sections (and any SSO
  lines `aws configure sso` added) removed; `[profile specterrealm-management]` and
  `[sso-session specterrealm]` added, as in the file below.
- `~/.zshrc`, inside `# BEGIN/END ANSIBLE MANAGED - workstation-devops shell-personal` only: the
  `export AWS_PROFILE=...` line and the `platform_bootstrap()` / `cvmtb()` functions removed.
- Possibly `~/.aws` itself: mode set to `0700` if it was looser.

Nothing else (no other files, no lines outside that marked block) should appear.

If the `~/.zshrc` diff shows anything else you want to keep, skip the shell part: run the real
run with `--skip-tags shell` added, then delete these lines by hand from the `shell-personal`
block in `~/.zshrc`:

```zsh
export AWS_PROFILE="${AWS_PROFILE:-platform-bootstrap}"
```

and the `platform_bootstrap() { … }` and `cvmtb() { … }` functions below it. Then open a new
terminal (or `unset AWS_PROFILE`).

## Manual fallback: `~/.aws/config`

If Ansible can't run, replace `~/.aws/config` with exactly this (`chmod 600 ~/.aws/config`):

```ini
# Managed by workstation-devops (roles/personal, `aws` tag) from group_vars/personal.yml.
# SSO only, no static keys. Break-glass use only: see docs/home/aws-break-glass.md.
# Do not run `aws configure` or `aws configure sso`; they rewrite this file. Edit the vars instead.

[default]

[profile specterrealm-management]
region = us-west-2
output = json
sso_session = specterrealm
sso_account_id = 893407364620
sso_role_name = AdministratorAccess

[sso-session specterrealm]
sso_start_url = https://d-926631fcf2.awsapps.com/start
sso_region = us-west-2
sso_registration_scopes = sso:account:access
```

`tests/fixtures/aws_config.expected` holds the same content and `make test` checks the template
renders it byte for byte.
