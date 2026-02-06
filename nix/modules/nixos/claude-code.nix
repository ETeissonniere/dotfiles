{ config, pkgs, lib, ... }:
let
  cfg = config.dotfiles;
in
{
  # Claude Code uses a native installer that manages its own updates.
  # This activation script ensures it's installed on first boot.
  system.activationScripts.claude-code.text = ''
    if ! /run/wrappers/bin/sudo -u ${cfg.username} bash -c 'command -v claude' &>/dev/null; then
      echo "Installing Claude Code..."
      /run/wrappers/bin/sudo -u ${cfg.username} bash -c '${pkgs.curl}/bin/curl -fsSL https://claude.ai/install.sh | bash' || echo "Claude Code installation failed (non-fatal)"
    fi
  '';
}
