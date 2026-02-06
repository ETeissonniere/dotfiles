{ config, pkgs, lib, ... }:
{
  # Nix settings
  nix.settings.experimental-features = "nix-command flakes";
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "UTC";

  # Networking
  networking.firewall.enable = true;

  # Basic system packages
  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    git
    gcc
    gnumake
  ];

  # Enable zsh system-wide
  programs.zsh.enable = true;
}
