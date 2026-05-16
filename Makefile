.PHONY: dry-run apply

dry-run:
	ansible-playbook playbook.yml -e dry_run=true

apply:
	ansible-playbook playbook.yml
