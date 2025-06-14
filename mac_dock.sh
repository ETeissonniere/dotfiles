#! /bin/sh

dockutil --no-restart --remove all

dockutil --no-restart --add "/Applications/Safari.app"
dockutil --no-restart --add "/Applications/Google Chrome.app"
dockutil --no-restart --add "~/Applications/Youtube Music.app"
dockutil --no-restart --add "/System/Applications/Mail.app"
dockutil --no-restart --add "/System/Applications/Messages.app"
dockutil --no-restart --add "/System/Applications/Notes.app"
dockutil --no-restart --add "/System/Applications/Journal.app"
dockutil --no-restart --add "/System/Applications/Calendar.app"
dockutil --no-restart --add "/System/Applications/Reminders.app"
dockutil --no-restart --add "/Applications/GhostTy.app"
dockutil --no-restart --add "/System/Applications/Utilities/Terminal.app"
dockutil --no-restart --add "/Applications/Cursor.app"

dockutil --no-restart --add "~/Downloads"

killall Dock
