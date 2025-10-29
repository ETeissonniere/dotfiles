#! /bin/sh

dockutil --no-restart --remove all

dockutil --no-restart --add "/Applications/Safari.app"
dockutil --no-restart --add "$HOME/Applications/Youtube Music.app"
dockutil --no-restart --add "/System/Applications/Mail.app"
dockutil --no-restart --add "/System/Applications/Messages.app"
dockutil --no-restart --add "/System/Applications/Notes.app"
dockutil --no-restart --add "/System/Applications/Calendar.app"
dockutil --no-restart --add "/System/Applications/Reminders.app"
dockutil --no-restart --add "/System/Applications/Utilities/Terminal.app"
dockutil --no-restart --add "/Applications/Visual Studio Code.app"

dockutil --no-restart --add "$HOME/Downloads"

killall Dock
