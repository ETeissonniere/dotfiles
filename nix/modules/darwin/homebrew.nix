{ config, pkgs, lib, ... }:
let
  cfg = config.dotfiles;
  isPersonal = cfg.profile == "personal";
  isWork = cfg.profile == "work";
  isVM = cfg.profile == "vm";
  hasDocker = isPersonal || isWork;
  hasSocials = isPersonal;
  hasPersonalApps = isPersonal;
  hasUTM = isPersonal;
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
    ] ++ lib.optionals hasDocker [
      "container"
    ];

    casks = [
      "appcleaner"
      "claude"
      "claude-code"
      "ghostty"
      "logseq"
    ] ++ lib.optionals (!isVM) [
      "logi-options+"
      "zed"
    ] ++ lib.optionals hasDocker [
      "docker-desktop"
    ] ++ lib.optionals hasUTM [
      "utm"
    ] ++ lib.optionals (isWork || isPersonal) [
      "google-chrome"
    ] ++ lib.optionals hasPersonalApps [
      "bambu-studio"
      "kicad"
    ];

    masApps = lib.mkMerge [
      (lib.mkIf (!isVM) {
        "Flighty – Live Flight Tracker" = 1358823008;
        "Numbers" = 409203825;
        "Pages" = 409201541;
        "uBlock Origin Lite" = 6745342698;
      })
      (lib.mkIf (isWork || isPersonal) {
        "Tailscale" = 1475387142;
      })
      (lib.mkIf hasSocials {
        "Telegram" = 747648890;
        "WhatsApp Messenger" = 310633997;
      })
      (lib.mkIf (isWork || isPersonal) {
        "Slack for Desktop" = 803453959;
      })
    ];
  };
}
