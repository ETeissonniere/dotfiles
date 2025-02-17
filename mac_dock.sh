#! /bin/sh

dockutil --no-restart --remove all

dockutil --no-restart --add "/Applications/Arc.app"
dockutil --no-restart --add "/Applications/Google Chrome.app"
dockutil --no-restart --add "~/Applications/Chrome Apps.localized/YouTube Music.app"
dockutil --no-restart --add "/Applications/Superhuman.app"
dockutil --no-restart --add "/System/Applications/Mail.app"
dockutil --no-restart --add "/System/Applications/Messages.app"
dockutil --no-restart --add "/Applications/Slack.app"
dockutil --no-restart --add "/Applications/Telegram.app"
dockutil --no-restart --add "/Applications/WhatsApp.app"
dockutil --no-restart --add "/Applications/Discord.app"
dockutil --no-restart --add "/Applications/Notion Calendar.app"
dockutil --no-restart --add "/Applications/Notion.app"
dockutil --no-restart --add "/Applications/GhostTy.app"
dockutil --no-restart --add "/Applications/Cursor.app"
dockutil --no-restart --add "/Applications/BambuStudio.app"

dockutil --no-restart --add "~/Downloads"

killall Dock
