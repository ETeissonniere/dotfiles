{ config, pkgs, lib, self, ... }:

let
  cfg = config.dotfiles;
in
{
  imports = [
    ../options.nix
    ../modules/darwin/homebrew.nix
    ../modules/darwin/defaults.nix
    ../modules/darwin/dock.nix
  ];

  nix.settings.experimental-features = "nix-command flakes";

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 4;

  users.users.${cfg.username} = {
    name = cfg.username;
    home = cfg.homeDirectory;
  };

  programs.zsh.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  # Home Manager embedded in nix-darwin
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${cfg.username} = { ... }: {
    imports = [
      ../modules/shared/git.nix
      ../modules/shared/ssh.nix
      ../modules/shared/zsh.nix
      ../modules/shared/shell-tools.nix
      ../modules/shared/ghostty.nix
      ../modules/shared/claude.nix
    ];

    home.stateVersion = "24.11";
  };
}
