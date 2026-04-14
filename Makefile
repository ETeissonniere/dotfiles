SHELL := /bin/bash
DOTFILES_ROOT := $(shell pwd)

.PHONY: default bootstrap apply configure verify

default: bootstrap

# First-time setup: install chezmoi, init from this repo, apply.
bootstrap:
	"$(DOTFILES_ROOT)/scripts/bootstrap.sh"

# Re-apply templates and rerun any changed run_onchange_ scripts.
apply:
	chezmoi apply

# Re-run chezmoi's interactive prompts (enable/disable modules), then apply.
configure:
	"$(DOTFILES_ROOT)/scripts/configure.sh"

verify:
	"$(DOTFILES_ROOT)/scripts/verify.sh"
