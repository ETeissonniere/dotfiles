{ config, pkgs, lib, ... }:

let
  claudeDir = ../../../config/claude;
in
{
  home.file = {
    ".claude/CLAUDE.md".source = "${claudeDir}/CLAUDE.md";
    ".claude/settings.json".source = "${claudeDir}/settings.json";
    ".claude/statusline-command.sh" = {
      source = "${claudeDir}/statusline-command.sh";
      executable = true;
    };
    ".claude/agents".source = "${claudeDir}/agents";
    ".claude/commands".source = "${claudeDir}/commands";
    ".claude/skills".source = "${claudeDir}/skills";
  };
}
