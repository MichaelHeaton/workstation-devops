# Personal AWS — platform-bootstrap

SpecterRealm homelab AWS uses the **`platform-bootstrap`** CLI profile (IAM user from
[platform-bootstrap runbook 01](https://github.com/MichaelHeaton/platform-bootstrap/blob/main/docs/runbooks/01-aws-account-setup.md)).

Workstation-devops applies this on **personal** profile machines (`home` tag):

| Setting | Default |
| -------- | -------- |
| `AWS_PROFILE` | `platform-bootstrap` (when unset at shell start) |
| `AWS_REGION` | `us-west-2` |
| `TF_STATE_BUCKET_NAME` | `mccleaton-tfstate` |

Override in `group_vars/personal.local.yml` if your bucket or region differ.

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

## platform-bootstrap repo

```bash
cd ~/Projects/personal/platform-bootstrap
make plan          # needs TF_STATE_BUCKET_NAME + AWS creds (set by shell)
make configure-service-cicd-dry
make configure-service-cicd
```

Runbook: [04 — Add a Service](https://github.com/MichaelHeaton/platform-bootstrap/blob/main/docs/runbooks/04-add-service.md).

## Work laptop

Adobe CES profiles (`ces_dev`, `ces_prd`, …) come from the **`work`** tag (KLAM). Do not
add `home` on a work-only machine unless you also need personal AWS on that host.
