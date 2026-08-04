.PHONY: help dry-run check apply deps hooks lint test triage profile secrets secrets-check secrets-notion secrets-linear secrets-atlassian secrets-atlassian-env secrets-help repos-export repos-sync-notion

help:
	@echo "workstation-devops — available targets"
	@echo ""
	@echo "  Setup"
	@echo "    make profile                        Detect or change machine profile (work/personal)"
	@echo "    make deps                           Install Ansible and toolchain dependencies"
	@echo "    make check                          Preflight: verify PATH, /Applications, Homebrew"
	@echo "    make hooks                          Install pre-commit hooks"
	@echo ""
	@echo "  Apply"
	@echo "    make apply                          Apply full configuration (logs to logs/apply-*.log)"
	@echo "    make apply ASK_BECOME=1             Also prompt for sudo (only needed for a new PKG cask install)"
	@echo "    make dry-run                        Preview changes without writing anything"
	@echo "    make apply TAGS=dotfiles            Run only the dotfiles (chezmoi) tag"
	@echo "    make apply SKIP_TAGS=work           Skip work-tagged tooling"
	@echo "    make apply EXTRA_VARS='-e homebrew_upgrade=true'"
	@echo ""
	@echo "  Debug"
	@echo "    make triage                         Summarize latest apply log"
	@echo "    make triage LOG=logs/apply-X.log    Summarize a specific apply log"
	@echo "    make lint                           yamllint + ansible syntax check + ansible-lint"
	@echo "    make test                           Regression tests + personal dry-run"
	@echo ""
	@echo "  Secrets"
	@echo "    make secrets-check                  Verify all Keychain items and local secret files"
	@echo "    make secrets-help                   List all secret setup commands"
	@echo "    make secrets-notion                 Notion MCP token → Keychain"
	@echo "    make secrets-linear                 Linear MCP API key → Keychain"
	@echo "    make secrets-atlassian              Atlassian Jira/Confluence tokens + config file"
	@echo "    make secrets-atlassian-env          Create ~/.mcp/env/atlassian-config.env"
	@echo ""
	@echo "  Repos"
	@echo "    make repos-export                   Export managed_repos to Notion Repositories DB"
	@echo "    make repos-sync-notion              Export + print Notion sync instructions"

WORKSTATION_PROFILE := $(shell test -f "$(HOME)/.workstation_profile" && tr -d '[:space:]' < "$(HOME)/.workstation_profile")
ANSIBLE_PROFILE_ARGS := $(if $(WORKSTATION_PROFILE),-e workstation_profile=$(WORKSTATION_PROFILE),)
# Pass extra Ansible vars: make apply EXTRA_VARS='-e homebrew_upgrade=true'
# Limit to tags: make apply TAGS=dotfiles   or   make apply SKIP_TAGS=work
EXTRA_VARS ?=
ANSIBLE_EXTRA_ARGS ?=
TAGS ?=
SKIP_TAGS ?=
# Sudo is only needed for the homebrew role's PKG-cask installer task (rare —
# new PKG cask, first install). Off by default so routine `make apply` runs
# don't prompt for a password you don't have memorized; opt in when you know
# a new PKG cask needs installing: make apply ASK_BECOME=1
ASK_BECOME ?=
ANSIBLE_EXTRA_VAR_ARGS := $(EXTRA_VARS) $(ANSIBLE_EXTRA_ARGS)
ANSIBLE_TAG_ARGS := $(if $(TAGS),--tags $(TAGS),) $(if $(SKIP_TAGS),--skip-tags $(SKIP_TAGS),)
ANSIBLE_PLAYBOOK := ansible-playbook site.yml $(ANSIBLE_PROFILE_ARGS) $(ANSIBLE_EXTRA_VAR_ARGS) $(ANSIBLE_TAG_ARGS)
ANSIBLE_APPLY := $(ANSIBLE_PLAYBOOK) $(if $(ASK_BECOME),--ask-become-pass,)

deps:
	@./scripts/bootstrap-deps.sh

hooks:
	pre-commit install

lint:
	yamllint .
	ansible-playbook site.yml --syntax-check -e workstation_profile=personal -e skip_profile_prompt=true
	ansible-lint

test:
	@./scripts/test-apply-safety.sh

profile:
	ansible-playbook profile_detect.yml $(ANSIBLE_PROFILE_ARGS)

dry-run:
	$(ANSIBLE_PLAYBOOK) -e dry_run=true

check:
	@./scripts/preflight.sh

# Tee full output so logs survive terminal resets / IDE restarts mid-apply
APPLY_LOG = logs/apply-$(shell date +%Y%m%d-%H%M%S).log

apply:
	@mkdir -p logs
	@echo "Logging to $(APPLY_LOG)"
	@set -o pipefail; ANSIBLE_FORCE_COLOR=1 $(ANSIBLE_APPLY) 2>&1 | tee "$(APPLY_LOG)"; \
	 ec=$$?; echo "Log: $(APPLY_LOG) (make triage)"; exit $$ec

triage:
	@./scripts/log-triage.sh $(if $(LOG),$(LOG),)

secrets-check:
	@./scripts/secrets/keychain-check.sh

secrets: secrets-check

secrets-notion:
	@./scripts/secrets/keychain-notion.sh

secrets-linear:
	@./scripts/secrets/keychain-linear.sh

secrets-atlassian:
	@./scripts/secrets/keychain-atlassian.sh

secrets-atlassian-env:
	@./scripts/secrets/keychain-atlassian-env.sh

secrets-help:
	@./scripts/secrets/help.sh

# Ansible managed_repos → Notion Repositories (Projects dest, Clone scope)
# Override profile: make repos-export REPOS_PROFILE=work
REPOS_PROFILE ?= $(if $(WORKSTATION_PROFILE),$(WORKSTATION_PROFILE),personal)

repos-export:
	@./scripts/export-managed-repos.py --profile $(REPOS_PROFILE)

repos-sync-notion: repos-export
	@echo ""
	@echo "Next: sync Projects dest + Clone scope to Notion (Repositories DB)."
	@echo "  Use Notion MCP — procedure: scripts/sync-notion-repo-layout.md"
	@echo "  Or ask your agent: sync repo dests to Notion"
