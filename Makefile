.PHONY: dry-run check apply deps hooks lint test triage profile secrets secrets-check secrets-vault-okta secrets-notion secrets-linear secrets-atlassian-env secrets-help repos-export repos-sync-notion

WORKSTATION_PROFILE := $(shell test -f "$(HOME)/.workstation_profile" && tr -d '[:space:]' < "$(HOME)/.workstation_profile")
ANSIBLE_PROFILE_ARGS := $(if $(WORKSTATION_PROFILE),-e workstation_profile=$(WORKSTATION_PROFILE),)
# Pass extra Ansible vars: make apply EXTRA_VARS='-e homebrew_upgrade=true'
# Limit to tags: make apply TAGS=dotfiles   or   make apply SKIP_TAGS=work
EXTRA_VARS ?=
ANSIBLE_EXTRA_ARGS ?=
TAGS ?=
SKIP_TAGS ?=
ANSIBLE_EXTRA_VAR_ARGS := $(EXTRA_VARS) $(ANSIBLE_EXTRA_ARGS)
ANSIBLE_TAG_ARGS := $(if $(TAGS),--tags $(TAGS),) $(if $(SKIP_TAGS),--skip-tags $(SKIP_TAGS),)
ANSIBLE_PLAYBOOK := ansible-playbook site.yml $(ANSIBLE_PROFILE_ARGS) $(ANSIBLE_EXTRA_VAR_ARGS) $(ANSIBLE_TAG_ARGS)

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
	@set -o pipefail; ANSIBLE_FORCE_COLOR=1 $(ANSIBLE_PLAYBOOK) 2>&1 | tee "$(APPLY_LOG)"; \
	 ec=$$?; echo "Log: $(APPLY_LOG) (make triage)"; exit $$ec

triage:
	@./scripts/log-triage.sh $(if $(LOG),$(LOG),)

secrets-check:
	@./scripts/secrets/keychain-check.sh

secrets: secrets-check

secrets-vault-okta:
	@./scripts/secrets/keychain-vault-okta.sh

secrets-notion:
	@./scripts/secrets/keychain-notion.sh

secrets-linear:
	@./scripts/secrets/keychain-linear.sh

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
