# Personal AWS — McCleaton platform (`platform-bootstrap` profile) — RETIRED

> **Retired (LAB-1227, Nov 2026).** The laptop `platform-bootstrap` profile and its static keys
> were only for running Terraform and helper scripts from this machine. platform-bootstrap and
> the domain spokes now run from their own pipelines (HCP Terraform, VCS-driven on `main`), so the
> profile was removed from `~/.aws/config`, and the shell no longer exports
> `AWS_PROFILE=platform-bootstrap` or defines `platform_bootstrap`. The only laptop profile now is
> the break-glass SSO profile: [aws-break-glass.md](aws-break-glass.md).

## Manual cleanup (once)

Ansible never touches `~/.aws/credentials`, so these steps are yours.

1. Note the key ID: in `~/.aws/credentials`, copy the `aws_access_key_id` value under
   `[platform-bootstrap]`.
2. In the **McCleaton** AWS account (the platform account this profile pointed at), IAM console →
   **Users** → the user that owns that key ID → **Security credentials** → **Access keys**:
   **Deactivate** it. Leave it inactive for a few days to confirm nothing (pipelines, scripts)
   breaks, then **Delete** it. Pipelines use OIDC roles, not this key.
3. Delete the whole `[platform-bootstrap]` section from `~/.aws/credentials`.
4. Open a new terminal and confirm `echo $AWS_PROFILE` prints nothing.

## Still relevant

| Repo | Backend | Plan / apply |
| ---- | ------- | ------------ |
| **platform-bootstrap** | HCP Terraform (`McCleaton-Bootstrap` / workspace `platform-bootstrap`) | VCS-driven in [HCP](https://app.terraform.io/app/McCleaton-Bootstrap/workspaces/platform-bootstrap) |
| **Domain spokes** (e.g. `homelab-infra/terraform/<stack>`) | HCP Terraform (one workspace per stack) | VCS-driven in HCP on `main` |

Cloudflare DNS lives in `homelab-infra/terraform/cloudflare/` (HCP workspace `cloudflare`), not
a standalone repo. See `homelab-infra/docs/terraform-workspaces.md`.

Runbooks: [04 — Add a Service](https://github.com/MichaelHeaton/platform-bootstrap/blob/main/docs/runbooks/04-add-service.md),
[09 — Cloudflare spoke](https://github.com/MichaelHeaton/platform-bootstrap/blob/main/docs/runbooks/09-cloudflare-terraform-repo.md).
Some platform-bootstrap runbooks still mention the laptop profile; that is tracked outside this repo.

## Work laptop

Adobe CES profiles (`ces_dev`, `ces_prd`, …) come from the **`work`** tag (KLAM), unrelated to this.
