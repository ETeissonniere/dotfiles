{ config, pkgs, lib, ... }:
let
  cfg = config.dotfiles;
in
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    brews = [
      "dockutil"
      "container"
    ];

    casks = [
      "appcleaner"
      "claude"
      "claude-code"
      "ghostty"
      "logseq"
    ] ++ lib.optionals (!cfg.isVM) [
      "docker-desktop"
      "logi-options+"
      "zed"
    ] ++ lib.optionals (!cfg.isVM && !cfg.noVirt) [
      "utm"
    ] ++ lib.optionals cfg.workApps [
      "google-chrome"
    ] ++ lib.optionals cfg.personalApps [
      "bambu-studio"
      "kicad"
    ];

    masApps = lib.mkMerge [
      (lib.mkIf (!cfg.isVM) {
        "Flighty – Live Flight Tracker" = 1358823008;
        "Numbers" = 409203825;
        "Pages" = 409201541;
        "uBlock Origin Lite" = 6745342698;
      })
      (lib.mkIf (!cfg.isVM && !cfg.noSocials) {
        "Telegram" = 747648890;
        "WhatsApp Messenger" = 310633997;
      })
      (lib.mkIf cfg.isLaptop {
        "Tailscale" = 1475387142;
      })
      (lib.mkIf cfg.workApps {
        "Slack for Desktop" = 803453959;
      })
    ];
  };
}
