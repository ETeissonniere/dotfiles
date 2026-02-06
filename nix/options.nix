{ lib, ... }:
{
  options.dotfiles = {
    profile = lib.mkOption {
      type = lib.types.enum [ "personal" "work" "vm" "server" "linux" ];
      default = "personal";
      description = ''
        Machine profile:
        - personal: All apps, socials, Docker, UTM, Tailscale
        - work: Work apps, Docker, no socials/personal apps/UTM
        - vm: Minimal macOS VM, no Docker/UTM/socials
        - server: NixOS server
        - linux: Non-NixOS Linux (Home Manager standalone)
      '';
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
      default = "nixos";
      description = "Machine hostname";
    };
  };
}
