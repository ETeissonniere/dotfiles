{ config, pkgs, lib, ... }:
{
  imports = [
    ../options.nix
    ../modules/shared/git.nix
    ../modules/shared/ssh.nix
    ../modules/shared/zsh.nix
    ../modules/shared/shell-tools.nix
    ../modules/shared/claude.nix
    ../modules/linux/tmux.nix
    ../modules/linux/packages.nix
  ];

  home.username = config.dotfiles.username;
  home.homeDirectory = config.dotfiles.homeDirectory;
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
