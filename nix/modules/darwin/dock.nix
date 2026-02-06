{ config, pkgs, lib, ... }:
let
  cfg = config.dotfiles;
  isVM = cfg.profile == "vm";
  isPersonal = cfg.profile == "personal";
  isWork = cfg.profile == "work";

  dockApps = [
    "/Applications/Safari.app"
  ]
  ++ lib.optionals (isWork || isPersonal) [
    "/Applications/Google Chrome.app"
  ]
  ++ [
    "$HOME/Applications/Youtube Music.app"
    "/System/Applications/Mail.app"
    "/System/Applications/Messages.app"
    "/System/Applications/Notes.app"
    "/Applications/Logseq.app"
    "/System/Applications/Calendar.app"
    "/Applications/Ghostty.app"
  ]
  ++ lib.optionals (!isVM) [
    "/Applications/Zed.app"
  ]
  ++ lib.optionals (isWork || isPersonal) [
    "/Applications/Slack.app"
  ]
  ++ [
    "/Applications/Claude.app"
  ]
  ++ lib.optionals isPersonal [
    "/Applications/BambuStudio.app"
  ]
  ++ [
    "/Applications/UGREEN NAS.app"
  ];

  dockutilCmds = lib.concatMapStringsSep "\n" (app: ''
    if [ -d "${app}" ]; then
      dockutil --no-restart --add "${app}" || true
    fi
  '') dockApps;
in
{
  system.activationScripts.postUserActivation.text = lib.mkAfter ''
    echo "Configuring Dock apps..."
    dockutil --no-restart --remove all || true
    ${dockutilCmds}
    dockutil --no-restart --add "$HOME/Downloads" --section others || true
    killall Dock 2>/dev/null || true
  '';
}
