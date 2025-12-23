#! /bin/sh

dockutil --no-restart --remove all

dockutil --no-restart --add "/Applications/Safari.app"
dockutil --no-restart --add "$HOME/Applications/Youtube Music.app"
dockutil --no-restart --add "/System/Applications/Mail.app"
dockutil --no-restart --add "/System/Applications/Messages.app"
dockutil --no-restart --add "/System/Applications/Notes.app"
dockutil --no-restart --add "/System/Applications/Calendar.app"
dockutil --no-restart --add "/Applications/Ghostty.app"

# Only add VSCode if not in VM mode
if [ "${VM:-0}" != "1" ]; then
    dockutil --no-restart --add "/Applications/Zed.app"
fi

# Only add slack if it is installed
if [ -d "/Applications/Slack.app" ]; then
    dockutil --no-restart --add "/Applications/Slack.app"
fi

dockutil --no-restart --add "/Applications/Claude.app"

# Only add Bambu Studio if PERSONAL_APPS is enabled and it is installed
if [ "${PERSONAL_APPS:-0}" = "1" ] && [ -d "/Applications/BambuStudio.app" ]; then
    dockutil --no-restart --add "/Applications/BambuStudio.app"
fi

dockutil --no-restart --add "$HOME/Downloads"

killall Dock
