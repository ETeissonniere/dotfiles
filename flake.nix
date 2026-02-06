{
  description = "Eliott's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nix-homebrew, disko }:
  let
    username = "eliottteissonniere";

    # Helper: create a macOS (nix-darwin) configuration
    mkDarwin = { hostname, hostPlatform ? "aarch64-darwin", dotfilesFlags ? {} }:
      nix-darwin.lib.darwinSystem {
        modules = [
          ./nix/hosts/darwin.nix
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = username;
            };
          }
          {
            dotfiles = {
              inherit username;
              homeDirectory = "/Users/${username}";
              hostName = hostname;
            } // dotfilesFlags;

            nixpkgs.hostPlatform = hostPlatform;
          }
        ];
        specialArgs = { inherit self; };
      };

    # Helper: create a NixOS server configuration
    mkNixOS = { hostname, system ? "x86_64-linux", dotfilesFlags ? {} }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          disko.nixosModules.disko
          ./nix/hosts/nixos.nix
          home-manager.nixosModules.home-manager
          {
            dotfiles = {
              inherit username;
              homeDirectory = "/home/${username}";
              hostName = hostname;
            } // dotfilesFlags;
          }
        ];
        specialArgs = { inherit self; };
      };

    # Helper: create a Linux (Home Manager standalone) configuration
    mkLinux = { system ? "x86_64-linux", dotfilesFlags ? {} }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./nix/hosts/linux.nix
          {
            dotfiles = {
              inherit username;
              homeDirectory = "/home/${username}";
            } // dotfilesFlags;
          }
        ];
      };
  in
  {
    # --- macOS configurations ---

    darwinConfigurations."personal" = mkDarwin {
      hostname = "macbook";
      dotfilesFlags = { profile = "personal"; };
    };

    darwinConfigurations."work" = mkDarwin {
      hostname = "work";
      dotfilesFlags = { profile = "work"; };
    };

    darwinConfigurations."vm" = mkDarwin {
      hostname = "vm";
      dotfilesFlags = { profile = "vm"; };
    };

    # --- NixOS configurations ---

    nixosConfigurations."server" = mkNixOS {
      hostname = "server";
      dotfilesFlags = { profile = "server"; };
    };

    # --- Linux configurations ---

    homeConfigurations."linux" = mkLinux {
      dotfilesFlags = { profile = "linux"; };
    };
  };
}
