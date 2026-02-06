{ config, pkgs, lib, ... }:

let
  dotfilesRoot = "$HOME/.dotfiles";
in
{
  programs.zsh = {
    enable = true;

    initExtra = ''
      # Source system zshrc if present
      if [[ -f /etc/zshrc ]]; then
        source /etc/zshrc
      fi

      export DOTFILES_ROOT="${dotfilesRoot}"

      # Platform-specific modules
      case "$OSTYPE" in
        darwin*)
          source "$DOTFILES_ROOT/modules/zsh/platform/macos.zsh"
          ;;
        linux*)
          source "$DOTFILES_ROOT/modules/zsh/platform/linux.zsh"
          ;;
      esac

      # Core configuration (PATH, history, colors, completions, prompt, tool integrations)
      source "$DOTFILES_ROOT/modules/zsh/core.zsh"

      # Aliases
      source "$DOTFILES_ROOT/modules/zsh/aliases.zsh"

      # Dotfiles auto-sync
      source "$DOTFILES_ROOT/modules/zsh/sync.zsh"
    '';
  };
}
