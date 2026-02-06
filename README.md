# Eliott's dotfiles

Declarative system configuration for macOS workstations, NixOS servers, and non-NixOS Linux machines. Everything is managed through [Nix Flakes](https://nixos.wiki/wiki/Flakes) with [nix-darwin](https://github.com/LnL7/nix-darwin), [NixOS](https://nixos.org/), and [Home Manager](https://github.com/nix-community/home-manager).

## Quick start

### macOS (personal laptop)

```sh
git clone https://github.com/ETeissonniere/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/bootstrap.sh switch personal
```

### NixOS server (fresh install via nixos-anywhere)

```sh
./scripts/bootstrap.sh install server root@192.168.1.100
```

### Non-NixOS Linux (Home Manager standalone)

```sh
git clone https://github.com/ETeissonniere/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/bootstrap.sh switch linux
```

## Architecture

```
flake.nix                      # Entry point — defines all configurations
nix/
  options.nix                  # Shared option declarations (dotfiles.*)
  hosts/
    darwin.nix                 # macOS host (nix-darwin + Home Manager)
    nixos.nix                  # NixOS host (full system + Home Manager)
    linux.nix                  # Standalone Home Manager for non-NixOS Linux
  modules/
    shared/                    # Cross-platform Home Manager modules
      git.nix                  #   Git with SSH signing
      ssh.nix                  #   SSH client config
      zsh.nix                  #   Zsh (sources runtime modules from modules/zsh/)
      shell-tools.nix          #   CLI tools (eza, fd, fzf, ripgrep, etc.)
      ghostty.nix              #   Ghostty terminal config
      claude.nix               #   Claude Code config files
    darwin/                    # macOS-specific system modules
      homebrew.nix             #   Homebrew casks, brews, Mac App Store
      defaults.nix             #   System preferences (dock, finder, keyboard)
      dock.nix                 #   Dock app layout via dockutil
    nixos/                     # NixOS-specific system modules
      base.nix                 #   Core settings (locale, firewall, nix gc)
      docker.nix               #   Docker with auto-prune
      sudo.nix                 #   Passwordless sudo for wheel group
      ssh-server.nix           #   OpenSSH server (key-only auth)
      claude-code.nix          #   Claude Code native installer
      disko.nix                #   Disk partitioning (GPT + EFI + ext4)
    linux/                     # Non-NixOS Linux modules
      tmux.nix                 #   Tmux with mouse support
      packages.nix             #   Basic build tools
modules/zsh/                   # Runtime zsh fragments (sourced, not Nix-managed)
config/                        # Config files symlinked by Nix
  ghostty/config               #   Ghostty settings
  git/allowed_signers          #   SSH signing allowed keys
  claude/                      #   Claude Code settings, agents, commands, skills
scripts/
  bootstrap.sh                 #   Unified CLI for all operations
  ssh/import_key.sh            #   SSH key import helper
```

## Available flavors

| Flavor | Platform | Description |
|--------|----------|-------------|
| `personal` | macOS | All apps, socials, Docker, UTM, Tailscale |
| `work` | macOS | Work apps, Docker, Tailscale — no socials/personal apps/UTM |
| `vm` | macOS | Minimal VM — no Docker, UTM, or socials |
| `server` | NixOS | Linux server — Docker, SSH, passwordless sudo |
| `linux` | Linux | Non-NixOS fallback — Home Manager standalone |

## Commands

```sh
# Apply configuration locally
./scripts/bootstrap.sh switch <flavor>

# Deploy NixOS config to a remote host
./scripts/bootstrap.sh deploy <flavor> <user@host>

# Provision NixOS on a new machine (wipes disk!)
./scripts/bootstrap.sh install <flavor> <user@host>

# Update all flake dependencies
./scripts/bootstrap.sh update

# Validate flake configuration
./scripts/bootstrap.sh check
```

## Day-to-day usage

### Adding a package

Edit the relevant Nix module and rebuild:

- **CLI tool (all platforms):** Add to `nix/modules/shared/shell-tools.nix`, run `switch`
- **Homebrew cask (macOS):** Add to `nix/modules/darwin/homebrew.nix`, run `switch`
- **NixOS system package:** Add to `nix/modules/nixos/base.nix`, run `switch` or `deploy`

### Updating dependencies

```sh
./scripts/bootstrap.sh update
./scripts/bootstrap.sh switch <flavor>
```

### Remote server management

After initial install, push config changes from your laptop:

```sh
./scripts/bootstrap.sh deploy server user@server-ip
```

## Profiles

The `dotfiles.profile` option in `nix/options.nix` controls what gets installed:

| Profile | Docker | UTM | Socials | Personal apps | Work apps | Tailscale |
|---------|:---:|:---:|:---:|:---:|:---:|:---:|
| `personal` | yes | yes | yes | yes | yes | yes |
| `work` | yes | - | - | - | yes | yes |
| `vm` | - | - | - | - | yes | - |

## Post-install reminders

- Import SSH keys: `./scripts/ssh/import_key.sh --from /path/to/key`
- Authenticate GitHub: `gh auth login -p ssh`
- Set wallpaper manually
- For NixOS servers: override `disko.devices.disk.main.device` if disk isn't `/dev/sda`
