# Runbook: Rotate corp password in Keychain Access (Vault `vl` / Okta)

Employers often require periodic **corp LDAP / VPN password** changes (typically **every 90 days**). The copy stored for **`vl` / `vault_mgmt`** lives in **Keychain Access**, not in the Passwords app — update it whenever you rotate, or `security` will keep feeding Vault the old password.

**Ansible reference:** `vault_okta_keychain_service` and `work_username` in `group_vars/work.local.yml` (default service: `work-vault-okta`; account matches LDAP short name).

---

## When to use this

- After a corporate **password reset** or expiry rotation.
- After changing your corp password anywhere else (Okta, laptop login policy, etc.) if Vault CLI login suddenly fails with bad password while MFA still works conceptually.
- You use **`vl`** with Keychain-backed `VAULT_OKTA_*` exports from `make apply` (see [vault-tools.md](../vault-tools.md)).

---

## Before you start

- Have the **new** corp password available (post-rotation).
- **No `make apply` is required** for this runbook — only the secret field in Keychain changes.

---

## Steps: update the Keychain item

1. Quit or finish any in-flight **`vl`** / **`vault_mgmt`** sessions (optional but avoids confusion).
2. Open **Keychain Access** (`/Applications/Utilities/Keychain Access.app`).
3. Select the **login** keychain (left sidebar, “login” under **Default Keychains**).
4. Use the search field: type your **`vault_okta_keychain_service`** (default `work-vault-okta`).
5. Double-click the **application password** item whose **Kind** is **application password** and name matches the service.
6. Click **Show password** (you may need Touch ID or your macOS password).
7. Replace the value with the **new** corp password.
8. Click **Save Changes**.

If you cannot find the item, it was never created in Keychain Access (Passwords app alone does not count). Create it per [vault-tools.md](../vault-tools.md) → *Keychain Access (not Apple Passwords)*.

---

## Optional: keep other stores in sync

| Store | Action |
|-------|--------|
| **Apple Passwords** (separate from Keychain CLI) | If you keep a browser/autofill copy, update that entry to the same new password so you are not juggling two different secrets. |
| **1Password** | If you use `vault_okta_op_ref` instead of Keychain, update the item field referenced by `op://…` — no Keychain step. |

---

## Verify (no secret in terminal output)

Check that `security` can read the item (you may get a **Touch ID / permission** prompt once per Terminal/iTerm):

```bash
security find-generic-password -s work-vault-okta -a YOUR_LDAP -w >/dev/null && echo "Keychain read OK"
```

Replace `work-vault-okta` and `YOUR_LDAP` with your `vault_okta_keychain_service` and `work_username` if different.

**Do not** paste `-w` output into tickets, chat, or screen recordings.

---

## Smoke test

```bash
source ~/.zshrc
vl
```

Pick a cluster, complete **Okta MFA** (Watch/app). Login should succeed without typing the password if Keychain integration is enabled.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|----------------|-----|
| `security: … could not be found` | Wrong service/account or item only in Passwords app | Recreate item in Keychain Access; match `group_vars/work.local.yml`. |
| Vault: invalid credentials | Keychain still has **old** password | Repeat update steps; confirm with verify command. |
| Touch ID never appears for Terminal **`security`** | First-time access | System Settings → **Privacy & Security** → allow the Terminal/iTerm app to use the Keychain item when macOS prompts. |
| `Note: password store lookup failed` | Exports on but item missing / name mismatch | Fix Keychain item or run `make apply` after fixing config. |

---

## Related

- [Vault CLI helpers (`vl`)](../vault-tools.md)
- Employer onboarding wiki: Vault Engineer Onboarding (internal)
