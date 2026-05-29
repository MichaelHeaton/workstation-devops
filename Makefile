.PHONY: dry-run check apply deps hooks lint profile secrets secrets-check secrets-vault-okta secrets-atlassian-env secrets-help

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

profile:
	ansible-playbook profile_detect.yml $(ANSIBLE_PROFILE_ARGS)

dry-run:
	$(ANSIBLE_PLAYBOOK) -e dry_run=true

check:
	@./scripts/preflight.sh

apply:
	$(ANSIBLE_PLAYBOOK)

secrets-check:
	@./scripts/secrets/keychain-check.sh

secrets: secrets-check

secrets-vault-okta:
	@./scripts/secrets/keychain-vault-okta.sh

secrets-atlassian-env:
	@./scripts/secrets/keychain-atlassian-env.sh

secrets-help:
	@./scripts/secrets/help.sh
