# kubelogin (Ethos kubectl OIDC) — work profile

Automated by `roles/kubernetes` on `make apply` when the `work` tag is in the allowlist.

**Source:** Vault Engineer Onboarding wiki (internal) → Install Azure/kubelogin v0.1.9

Ethos requires **Azure/kubelogin v0.1.9 exactly**. Newer Homebrew builds can force re-auth on every `kubectl` command.

## What Ansible does

| Step | Automated |
|------|-----------|
| Download `kubelogin-darwin-{arm64,amd64}.zip` v0.1.9 from GitHub | Yes, when missing or wrong version |
| Install to `~/.local/bin/kubelogin` | Yes |
| Symlink `kubectl-oidc_login` plugin | Yes |
| `kubectl` itself | Detect-only (IT or `kubernetes-cli` formula) |

**Do not** `brew install kubelogin` or `brew upgrade kubelogin` on work machines. If Homebrew has a newer kubelogin, this role’s copy under `~/.local/bin` wins because shell-common prepends that path.

## Prerequisites

- `kubectl` on PATH
- Ethos kubeconfig setup per internal **k8s-kubeconfig** repo / employer wiki
- VPN as required for cluster access

## Test

```bash
source ~/.zshrc
kubelogin --version    # expect git hash: v0.1.9/...
kubectl oidc-login --version
kubectl get ns         # after kubeconfig + login
```

## Pin variable

Version is pinned in `roles/kubernetes/defaults/main.yml` (`kubelogin_version: "0.1.9"`). Bump only when Ethos docs change — never via Homebrew upgrade.
