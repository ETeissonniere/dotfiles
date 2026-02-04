#! /bin/sh

dockutil --no-restart --remove all

dockutil --no-restart --add "/Applications/Safari.app"

# Add Chrome next to Safari if installed
if [ -d "/Applications/Google Chrome.app" ]; then
    dockutil --no-restart --add "/Applications/Google Chrome.app"
fi

dockutil --no-restart --add "$HOME/Applications/Youtube Music.app"
dockutil --no-restart --add "/System/Applications/Mail.app"
dockutil --no-restart --add "/System/Applications/Messages.app"
dockutil --no-restart --add "/System/Applications/Notes.app"
dockutil --no-restart --add "/Applications/Logseq.app"
dockutil --no-restart --add "/System/Applications/Calendar.app"
dockutil --no-restart --add "/Applications/Ghostty.app"

# Only add VSCode if not in VM mode
if [ -d "/Applications/Zed.app" ]; then
    dockutil --no-restart --add "/Applications/Zed.app"
fi

# Only add slack if it is installed
if [ -d "/Applications/Slack.app" ]; then
    dockutil --no-restart --add "/Applications/Slack.app"
fi

dockutil --no-restart --add "/Applications/Claude.app"

# Only add Bambu Studio if PERSONAL_APPS is enabled and it is installed
if [ -d "/Applications/BambuStudio.app" ]; then
    dockutil --no-restart --add "/Applications/BambuStudio.app"
fi

# Only add UGREEN NAS if installed
if [ -d "/Applications/UGREEN NAS.app" ]; then
    dockutil --no-restart --add "/Applications/UGREEN NAS.app"
fi

dockutil --no-restart --add "$HOME/Downloads"

killall Dock
