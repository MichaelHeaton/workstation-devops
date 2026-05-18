.PHONY: dry-run check apply deps hooks lint profile

WORKSTATION_PROFILE := $(shell test -f "$(HOME)/.workstation_profile" && tr -d '[:space:]' < "$(HOME)/.workstation_profile")
ANSIBLE_PROFILE_ARGS := $(if $(WORKSTATION_PROFILE),-e workstation_profile=$(WORKSTATION_PROFILE),)
# Pass extra Ansible vars: make apply EXTRA_VARS='-e homebrew_upgrade=true'
ANSIBLE_EXTRA_ARGS ?=
ANSIBLE_PLAYBOOK := ansible-playbook site.yml $(ANSIBLE_PROFILE_ARGS) $(ANSIBLE_EXTRA_ARGS)

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
