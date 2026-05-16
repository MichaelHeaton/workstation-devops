.PHONY: dry-run apply deps

deps:
	@./scripts/bootstrap-deps.sh

dry-run:
	ansible-playbook playbook.yml -e dry_run=true

apply:
	ansible-playbook playbook.yml
