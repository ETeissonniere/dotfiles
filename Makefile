SHELL := /bin/bash
DOTFILES_ROOT := $(shell pwd)

.PHONY: default bootstrap apply configure verify

default: bootstrap

bootstrap:
	"$(DOTFILES_ROOT)/scripts/bootstrap.sh"

apply:
	chezmoi apply

configure:
	@command -v chezmoi >/dev/null || { echo "Run 'make bootstrap' first"; exit 1; }
	chezmoi init --prompt
	chezmoi apply

verify:
	"$(DOTFILES_ROOT)/scripts/verify.sh"
