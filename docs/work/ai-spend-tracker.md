# AI Spend Tracker (work profile)

Menu-bar app for tracking AI API spend. **Source** may be private (employer GitHub SSO). **Binaries and Sparkle updates** are public so installs and auto-update work without SSO.

| What | URL | SSO? |
| ------ | ----- | ------ |
| Source / PRs | Private employer repo | Yes |
| DMG downloads | [roymerrill/ai-spend-tracker-releases](https://github.com/roymerrill/ai-spend-tracker-releases/releases) | No |
| Sparkle appcast | Public gist (see app `SUFeedURL`) | No |

## Playbook

Configured in `group_vars/all.yml` (`mac_dmg_apps_catalog`) and enabled for **work** and **personal** in each profile’s `mac_dmg_apps_profile`. With `mac_dmg_apps_install: true`, `make apply` downloads the latest `AISpendTracker.dmg` when `/Applications/AISpendTracker.app` is missing.

- **Detect:** `make check` passes if the app bundle is present.
- **Install:** `make apply` (or `make dry-run` to preview).
- **Override:** `-e mac_dmg_apps_install=false` for detect-only on locked-down Macs.

Installed app on this machine: `AISpendTracker.app`, bundle id `com.aispendtracker.app`.

## Manual install

Download [latest AISpendTracker.dmg](https://github.com/roymerrill/ai-spend-tracker-releases/releases/latest) and drag the app to `/Applications`.
