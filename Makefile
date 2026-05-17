.PHONY: dry-run apply deps hooks lint

deps:
	@./scripts/bootstrap-deps.sh

hooks:
	pre-commit install

lint:
	yamllint .
	ansible-playbook playbook.yml --syntax-check
	ansible-lint

dry-run:
	ansible-playbook playbook.yml -e dry_run=true

apply:
	ansible-playbook playbook.yml
