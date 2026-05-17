.PHONY: dry-run check apply deps hooks lint

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

check:
	@tmpfile=$$(mktemp); \
	  ansible-playbook playbook.yml -e dry_run=true >$$tmpfile 2>&1 & \
	  pid=$$!; i=0; printf "Checking "; \
	  while kill -0 $$pid 2>/dev/null; do \
	    case $$((i % 6)) in \
	      0) printf "\033[91m*\033[0m" ;; \
	      1) printf "\033[93m*\033[0m" ;; \
	      2) printf "\033[92m*\033[0m" ;; \
	      3) printf "\033[96m*\033[0m" ;; \
	      4) printf "\033[94m*\033[0m" ;; \
	      5) printf "\033[95m*\033[0m" ;; \
	    esac; i=$$((i+1)); sleep 1; \
	  done; \
	  wait $$pid; rc=$$?; printf "\n"; \
	  awk 'BEGIN { green="\033[32m"; yel="\033[33m"; red="\033[31m"; dim="\033[2m"; gray="\033[90m"; rst="\033[0m" } \
	    /^PLAY RECAP/ { recap=1; print; next } \
	    recap { \
	      l=$$0; \
	      gsub(/ok=[0-9]+/, green "✓ &" rst, l); \
	      if (match(l,/changed=[0-9]+/))     { v=substr(l,RSTART+8,RLENGTH-8)+0;   if(v>0) gsub(/changed=[0-9]+/,     yel "~ &" rst,l); else gsub(/changed=[0-9]+/,     dim "&" rst,l) }; \
	      if (match(l,/unreachable=[0-9]+/)) { v=substr(l,RSTART+12,RLENGTH-12)+0; if(v>0) gsub(/unreachable=[0-9]+/, red "✗ &" rst,l); else gsub(/unreachable=[0-9]+/, dim "&" rst,l) }; \
	      if (match(l,/failed=[0-9]+/))      { v=substr(l,RSTART+7,RLENGTH-7)+0;   if(v>0) gsub(/failed=[0-9]+/,      red "✗ &" rst,l); else gsub(/failed=[0-9]+/,      dim "&" rst,l) }; \
	      gsub(/skipped=[0-9]+/, "\033[94m" "&" rst, l); \
	      gsub(/rescued=[0-9]+/, dim "&" rst, l); \
	      gsub(/ignored=[0-9]+/, dim "&" rst, l); \
	      print l; next \
	    } \
	    /"Would (install|create|clone|go install)/ { print green $$0 rst; next } \
	    /"Would (set|clear) Finder/               { print yel   $$0 rst; next } \
	    /FAILED|fatal:/                            { print red   $$0 rst; next }' $$tmpfile; \
	  rm -f $$tmpfile; exit $$rc

apply:
	ansible-playbook playbook.yml
