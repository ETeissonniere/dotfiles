{ config, pkgs, lib, ... }:
let
  cfg = config.dotfiles;
in
{
  # Manual System Settings (defaults commands no longer work reliably for these):
  #   - First day of week: System Settings > General > Language & Region > Monday
  #   - Lock screen password: System Settings > Lock Screen > Require password

  # Locale & measurement
  system.defaults.NSGlobalDomain = {
    AppleMeasurementUnits = "Centimeters";
    AppleMetricUnits = true;
    AppleTemperatureUnit = "Celsius";
    # Keyboard
    KeyRepeat = 2;
    InitialKeyRepeat = 30;
    # Pointing devices
    "com.apple.trackpad.scaling" = 3.0;
    "com.apple.mouse.scaling" = 3.0;
    # Scrollbars
    AppleShowScrollBars = "WhenScrolling";
  };

  # Dock
  system.defaults.dock = {
    autohide = !cfg.isVM;
    tilesize = 64;
    # Disable hot corners
    wvous-tl-corner = 1;
    wvous-tr-corner = 1;
    wvous-bl-corner = 1;
    wvous-br-corner = 1;
  };

  # Finder
  system.defaults.finder = {
    FXPreferredViewStyle = "clmv";
    ShowExternalHardDrivesOnDesktop = false;
    ShowHardDrivesOnDesktop = false;
    ShowMountedServersOnDesktop = false;
    ShowRemovableMediaOnDesktop = false;
    ShowSidebar = true;
    ShowRecentTags = false;
    NewWindowTarget = "PfHm";
  };

  # Settings without native nix-darwin options
  system.defaults.CustomUserPreferences = {
    NSGlobalDomain = {
      AppleLocale = "en_US@currency=USD";
    };
    "com.apple.HIToolbox" = {
      AppleFnUsageType = 3;
    };
    "com.apple.finder" = {
      FXICloudDriveDesktop = true;
      FXICloudDriveDocuments = true;
      NewWindowTargetPath = "file:///Users/${cfg.username}/";
    };
    "com.apple.Safari.SandboxBroker" = {
      ShowDevelopMenu = true;
    };
  };

  # Imperative settings that need activation scripts
  system.activationScripts.postUserActivation.text = ''
    # Dark mode
    osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true' || true

    # TimeMachine exclusions
    tmutil addexclusion ~/Developer 2>/dev/null || true
    tmutil addexclusion ~/Downloads 2>/dev/null || true

    # Create Developer directory
    mkdir -p ~/Developer

    # Screenshot hotkey: Cmd+Shift+S copies screenshot selection to clipboard
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 31 '<dict><key>enabled</key><true/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>115</integer><integer>1</integer><integer>1179648</integer></array></dict></dict>'

    # Apply settings without logout
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
