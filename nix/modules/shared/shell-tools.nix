{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    eza
    fd
    fzf
    ripgrep
    zoxide
    httpie
    btop
    gh
    glab
    gitea-tea
    uv
  ];
}
