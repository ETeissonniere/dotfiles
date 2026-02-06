{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    gcc
    gnumake
    curl
    wget
    vim
  ];
}
