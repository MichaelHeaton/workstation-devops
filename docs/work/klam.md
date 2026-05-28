# KLAM CLI — work profile

Automated by `roles/klam` on `make apply` when `workstation_profile=work`.

**Source:** KLAM Command Line Interface wiki (internal)

## What Ansible does

| Step | Automated |
|------|-----------|
| `pip3 install --user klam` from Artifactory | Yes, when `klam` missing and `klam_artifactory_api_key` is passed |
| `ces_sandbox` / `ces_dev` / `ces_prd` shell aliases | Yes → `~/.config/workstation-devops/klam_aliases.zsh` |
| Artifactory API key | **No** — you pass at apply time (not stored in git) |
| KLAM trust key (`klam.corp.adobe.com` → CLI keys) | **No** — one-time in browser |
| `klam login` / `klam configure-profile` | **No** — interactive; needs IAM groups |

> **Naming:** Use **`ces_*`** profiles (CES Vault). Older wiki/onboarding examples use `cstdev`/`cstprd` (legacy CST naming).

## Credentials (do not confuse)

| Secret | Used for | Where |
|--------|----------|--------|
| **Artifactory API key** | `pip install` index URL | [Artifactory profile](https://artifactory.corp.adobe.com/artifactory/webapp/#/profile) → API Key |
| **ADOBENET / Okta password** | `vault login -method=okta`, `klam login` prompts | Apple Passwords “Adobe: ADOBENET” — **never** put in Ansible/git |

## Install via playbook

The CLI is **not** installed until you pass an Artifactory API key. Aliases alone will fail with `command not found: klam` until pip install runs.

**Preferred** (keeps the key out of shell history):

```bash
# VPN on; API key from Artifactory profile page (not ADOBENET)
export KLAM_ARTIFACTORY_API_KEY='paste-key-here'
export ADOBE_USERNAME=YOUR_LDAP   # Artifactory LDAP — not your macOS login name
cd ~/Projects/personal/workstation-devops
make apply
source ~/.zshrc
klam --help
```

**Homebrew Python (PEP 668):** the role passes `--break-system-packages` on macOS so `pip install --user` is allowed.

Or via extra-var:

```bash
make apply EXTRA_VARS='-e klam_artifactory_api_key=YOUR_ARTIFACTORY_API_KEY adobe_username=YOUR_LDAP'
```

## Manual pip install (same as wiki)

```bash
pip3 install --user --break-system-packages klam \
  -i "https://YOUR_LDAP:YOUR_API_KEY@artifactory.corp.adobe.com/artifactory/api/pypi/pypi-klam-cli-release/simple"
```

## After install (manual, one-time)

1. **Trust key** — [klam.corp.adobe.com](https://klam.corp.adobe.com) → Profile → Command Line Interface → Generate key → run the command shown.

2. **Discover policies** (environment is **uppercase** `DEV` / `PRD` as shown in `klam projects`):

   ```bash
   klam project-policies -p AWS_CESSS-SecurityTooling -e DEV -C aws
   klam project-policies -p ATS_CES_Vault -e DEV -C aws
   klam project-policies -p ATS_CES_Vault -e PRD -C aws
   ```

3. **Configure profiles** — use `-d 8` (or 1/4/12) when `duration_override` is true; policy must match `project-policies` exactly:

   ```bash
   klam login

   klam configure-profile -n ces_sandbox \
     -p AWS_CESSS-SecurityTooling -e DEV -C aws \
     -P administrator_and_support -d 8

   klam configure-profile -n ces_dev \
     -p ATS_CES_Vault -e DEV -C aws \
     -P administrator_and_support -d 8

   klam configure-profile -n ces_prd \
     -p ATS_CES_Vault -e PRD -C aws \
     -P administrator_and_support -d 8
   ```

4. **Fetch creds** — shell aliases or explicit profile:

   ```bash
   ces_dev    # alias: klam login + credentials --profile ces_dev --configure
   aws sts get-caller-identity --profile ces_dev
   # or: export AWS_PROFILE=ces_dev
   ```

| Profile | Project | Env | AWS account | Team use |
|---------|---------|-----|-------------|----------|
| `ces_sandbox` | AWS_CESSS-SecurityTooling | DEV | 365215803550 | **CES Vault team dev** (sandbox/Terraform) |
| `ces_dev` | ATS_CES_Vault | DEV | 891377009010 | Shared Vault dev (other Adobe teams) |
| `ces_prd` | ATS_CES_Vault | PRD | 937224341222 | Vault prod |

IAM group membership is required before profiles work — see [setup-notes.md](setup-notes.md).

## Terminal background / tab color (optional)

The deployed `klam_aliases.zsh` can tint the **tab title**, **tab color**, and **background** when you run a `ces_*` function (works best in **iTerm2**; may be partial in Cursor/VS Code).

Enabled by default after `make apply`. Disable: `export CES_KLAM_TERM_BG=0`.

```bash
source ~/.zshrc
ces_sandbox   # green — CES team dev
ces_term_reset   # restore default colors and unset AWS_PROFILE
```

**Cursor / VS Code integrated terminal:** window title + OSC background may work; **iTerm2 tab color** escapes are skipped outside iTerm. For full tab+background tint, use **iTerm2** and ensure the profile allows terminal-initiated color changes.

**KLAM `osascript` / System Events error on login:** KLAM tries to close the OAuth browser tab via AppleScript. Login still succeeds. To silence it: **System Settings → Privacy & Security → Accessibility** → allow **iTerm** (optional).

| Function | Visual cue | Meaning |
|----------|------------|---------|
| `ces_sandbox` | Green | CES Vault **team** dev |
| `ces_dev` | Gold/yellow | Shared Vault dev (not CES team dev) |
| `ces_prd` | Red | Prod warning |

iTerm2: if background does not change, check **Preferences → Profiles → Terminal → Allow terminal to change opacity** / ANSI color reporting. Tab color uses iTerm2 proprietary escapes; background uses OSC 11.
