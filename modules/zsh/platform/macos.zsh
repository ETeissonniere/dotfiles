# macOS-specific Zsh customisations.

path=(/opt/homebrew/bin $path)

if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
  chpwd() {
    printf '\e]7;%s\a' "file://$HOSTNAME${PWD// /%20}"
  }
  chpwd
fi

init_ssh() {
  if ! pgrep -q ssh-agent; then
    eval "$(ssh-agent -s)"
  fi
  ssh-add --apple-load-keychain >/dev/null 2>&1
}

init_ssh >/dev/null 2>&1 &!
