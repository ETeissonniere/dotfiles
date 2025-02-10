#!/bin/bash

if [ "$#" -eq 0 ]; then
    echo -e " Shutdown\n Reboot\n Logout\n Suspend\n Hibernate"
else
    case $1 in
        \ Shutdown) systemctl poweroff ;;
        \ Reboot) systemctl reboot ;;
        \ Logout) hyprlock ;;
        \ Suspend) systemctl suspend ;;
        \ Hibernate) systemctl hibernate ;;
    esac
fi 