# See https://stackoverflow.com/a/27776822
case "$(uname -s)" in

   Darwin)
        # Require password immediately on sleep
        defaults write com.apple.screensaver askForPassword -int 1
        defaults write com.apple.screensaver askForPasswordDelay -int 0

        # Firewall
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setblockall off
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned on
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
     ;;

    Linux)
        # If we are on linux, we assume we are in a github codespace
        # environment and thus disable git signing
        git config --global commit.gpgsign false
     ;;

esac