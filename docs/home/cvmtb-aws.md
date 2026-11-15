# Cedar Valley MTB AWS (`cvmtb` profile) — RETIRED

> **Retired (LAB-1227, Nov 2026).** The laptop `cvmtb` profile and its static keys were only for
> running the Website repo's Terraform from this machine. The Website repo now runs from its own
> pipeline, so the profile was removed from `~/.aws/config` and the `cvmtb` shell helper is gone.
> A Cedar Valley MTB SSO session may be added later on the same pattern as
> [aws-break-glass.md](aws-break-glass.md); not now.

| Item | Value |
| ---- | ----- |
| AWS account | `616714047495` (Cedar Valley MTB) |
| Repo | [Cedar-Valley-MTB/Website](https://github.com/Cedar-Valley-MTB/Website) |

## Manual cleanup (once)

Ansible never touches `~/.aws/credentials`, so these steps are yours.

1. Note the key ID: in `~/.aws/credentials`, copy the `aws_access_key_id` value under `[cvmtb]`.
2. In AWS account **`616714047495`**, IAM console → **Users** → the user that owns that key ID →
   **Security credentials** → **Access keys**: **Deactivate** it. Leave it inactive for a few
   days to confirm the Website pipeline is unaffected, then **Delete** it.
3. Delete the whole `[cvmtb]` section from `~/.aws/credentials`.
4. In the Website repo, `.envrc` may still set `AWS_PROFILE=cvmtb`; that profile no longer
   exists on this laptop (tracked in that repo, not here).
