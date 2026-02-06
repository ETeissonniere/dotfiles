{ config, pkgs, lib, ... }:
{
  programs.tmux = {
    enable = true;
    mouse = true;
  };
}
