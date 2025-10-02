SHELL := /bin/bash
DOTFILES_ROOT := $(shell pwd)

.PHONY: bootstrap packages link

bootstrap:
	"$(DOTFILES_ROOT)/scripts/bootstrap/main.sh"

packages:
	"$(DOTFILES_ROOT)/scripts/packages/install.sh"

link:
	"$(DOTFILES_ROOT)/scripts/config/deploy.sh"
