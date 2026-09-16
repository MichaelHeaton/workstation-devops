# Cedar Valley MTB AWS (cvmtb profile)

Volunteer team website infrastructure — **separate** from McCleaton `platform-bootstrap`.

| Item | Value |
| ---- | ----- |
| AWS account | `616714047495` |
| Profile | `cvmtb` |
| Region | `us-west-2` |
| Terraform state bucket | `rcv-website-terraform-state-616714047495` |
| Repo | [Cedar-Valley-MTB/Website](https://github.com/Cedar-Valley-MTB/Website) |

## One-time credentials

Ansible (`roles/personal`, `home` tag) owns **`~/.aws/config`** (region/output only).
Keys stay in `~/.aws/credentials` — set them without rewriting config:

```bash
aws configure set aws_access_key_id AKIA... --profile cvmtb
aws configure set aws_secret_access_key ... --profile cvmtb
# Do not use `aws configure --profile …` — it rewrites ~/.aws/config and fights Ansible.
aws sts get-caller-identity --profile cvmtb   # Account must be 616714047495
```

## Daily use

**In the Website repo**, direnv sets `AWS_PROFILE=cvmtb` via `.envrc`:

```bash
cd ~/Projects/Ceder-Valley-MTB/Website
direnv allow
aws sts get-caller-identity
```

**Anywhere else**, switch explicitly (do not use default `platform-bootstrap`):

```bash
cvmtb
aws sts get-caller-identity
```

## Infra commands

From the Website repo root:

```bash
make infra-bootstrap
make infra-preview-apply
make infra-preview-output
```

See Website `docs/aws-setup.md` and `infra/README.md`.
