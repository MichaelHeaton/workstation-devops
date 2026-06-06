# Personal AWS — McCleaton platform

Personal platform infrastructure (GitHub org provisioning, OIDC, S3 state, domain spokes)
runs in the **McCleaton** AWS account. Workstation-devops applies shell defaults on **personal**
profile machines (`home` tag):

| Setting | Default |
| -------- | -------- |
| `AWS_PROFILE` | `platform-bootstrap` (when unset at shell start) |
| `AWS_REGION` | `us-west-2` |
| `TF_STATE_BUCKET_NAME` | `mccleaton-tfstate` |

Override in `group_vars/personal.local.yml` if your bucket or region differ.

## Terraform state model

| Repo | Backend | Plan / apply |
| ---- | ------- | ------------ |
| **platform-bootstrap** | HCP Terraform (`McCleaton-Bootstrap` / workspace `platform-bootstrap`) | VCS-driven in [HCP](https://app.terraform.io/app/McCleaton-Bootstrap/workspaces/platform-bootstrap) — not local `terraform apply` |
| **Domain spokes** (e.g. `McCleaton/cloudflare`) | S3 (`mccleaton-tfstate`, key per pipeline) | GitHub Actions OIDC on `main` |

Local `AWS_PROFILE=platform-bootstrap` is still used for Secrets Manager reads, debugging
spoke plans, and helper scripts — not for applying platform-bootstrap root module state.

## One-time credentials

Chezmoi manages **`~/.aws/config`** (profile metadata only). **Access keys** stay in
`~/.aws/credentials` — create manually:

```bash
aws configure --profile platform-bootstrap
aws sts get-caller-identity --profile platform-bootstrap
```

## Daily use

New shells on a personal Mac pick up the exports automatically. To re-apply after
`ces_term_reset` or `unset AWS_PROFILE` on a hybrid machine:

```bash
platform_bootstrap
```

## platform-bootstrap (HCP)

Hub repo: `MichaelHeaton/platform-bootstrap` — creates McCleaton org repos, OIDC roles, and
registers spokes in `terraform/managed.auto.tfvars`.

```bash
cd ~/Projects/personal/platform-bootstrap
# fmt/validate locally; plan+apply run in HCP after merge to main
make fmt validate
```

HCP workspace: [McCleaton-Bootstrap/platform-bootstrap](https://app.terraform.io/app/McCleaton-Bootstrap/workspaces/platform-bootstrap).

Runbooks: [04 — Add a Service](https://github.com/MichaelHeaton/platform-bootstrap/blob/main/docs/runbooks/04-add-service.md),
[09 — Cloudflare spoke](https://github.com/MichaelHeaton/platform-bootstrap/blob/main/docs/runbooks/09-cloudflare-terraform-repo.md).

## cloudflare spoke (S3 + GHA)

Repo: `McCleaton/cloudflare` → cloned to `~/Projects/personal/cloudflare`.

| Item | Value |
| ---- | ----- |
| State bucket | `mccleaton-tfstate` |
| State key | `shared-cloudflare-dns/terraform.tfstate` |
| SM secret (plan time) | `personal/cloudflare-api-token` |

Local plan (optional — needs AWS creds + token from SM):

```bash
cd ~/Projects/personal/cloudflare/terraform
export AWS_PROFILE=platform-bootstrap TF_STATE_BUCKET_NAME=mccleaton-tfstate
terraform init -backend-config="bucket=$TF_STATE_BUCKET_NAME" -backend-config="key=shared-cloudflare-dns/terraform.tfstate"
# CLOUDFLARE_API_TOKEN from SM for plan
terraform plan
```

Normal path: push to `main` and let GitHub Actions plan/apply via OIDC.

## Work laptop

Adobe CES profiles (`ces_dev`, `ces_prd`, …) come from the **`work`** tag (KLAM). Do not
add `home` on a work-only machine unless you also need personal AWS on that host.
