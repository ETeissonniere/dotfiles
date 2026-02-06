{ config, pkgs, lib, ... }:
{
  programs.ssh = {
    enable = true;

    forwardAgent = true;
    addKeysToAgent = "yes";

    matchBlocks = {
      "*" = {
        identityFile = "~/.ssh/id_rsa";
      } // lib.optionalAttrs pkgs.stdenv.isDarwin {
        extraOptions = {
          UseKeychain = "yes";
        };
      };
    };
  };
}
