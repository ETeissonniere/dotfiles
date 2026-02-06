{ lib, ... }:
{
  options.dotfiles = {
    isVM = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Running in a virtual machine -- skip desktop apps and dock autohide";
    };

    isLaptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Laptop-specific tools (Tailscale)";
    };

    workApps = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Include work apps (Chrome, Slack)";
    };

    personalApps = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Include personal apps (Bambu Studio, KiCad)";
    };

    noSocials = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Skip social messaging apps (Telegram, WhatsApp)";
    };

    noVirt = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Skip virtualization tools (UTM)";
    };

    username = lib.mkOption {
      type = lib.types.str;
      default = "eliottteissonniere";
      description = "Primary username";
    };

    homeDirectory = lib.mkOption {
      type = lib.types.str;
      description = "Home directory path";
    };

    hostName = lib.mkOption {
      type = lib.types.str;
      default = "macbook";
      description = "Machine hostname";
    };
  };
}
