# Dotfiles sync module - checks for updates and applies changes with user confirmation.

DOTFILES_SYNC_CHECK_INTERVAL=${DOTFILES_SYNC_CHECK_INTERVAL:-86400}  # 24 hours in seconds
DOTFILES_SYNC_CACHE_FILE="$HOME/.cache/dotfiles-last-check"

# Detect if running in a VM
_is_vm() {
  case "$OSTYPE" in
    darwin*)
      # Check model identifier (VMs have specific patterns)
      local model=$(sysctl -n hw.model 2>/dev/null)
      if [[ "$model" == "VirtualMac"* ]] || [[ "$model" == "QEMU"* ]]; then
        return 0
      fi
      return 1
      ;;
    linux*)
      # Try systemd-detect-virt first (most reliable)
      if command -v systemd-detect-virt >/dev/null 2>&1; then
        if systemd-detect-virt -q; then
          return 0
        fi
      fi

      # Fallback: check DMI product name
      if [[ -r /sys/class/dmi/id/product_name ]]; then
        local product=$(cat /sys/class/dmi/id/product_name 2>/dev/null)
        if echo "$product" | grep -qi "vmware\|virtualbox\|qemu\|kvm\|virtual"; then
          return 0
        fi
      fi

      return 1
      ;;
    *)
      return 1
      ;;
  esac
}

_dotfiles_sync() {
  local dotfiles_dir="${DOTFILES_ROOT:-$HOME/.dotfiles}"

  # Create cache dir if needed
  mkdir -p "$(dirname "$DOTFILES_SYNC_CACHE_FILE")"

  # Check if we should run (throttle checks)
  if [[ -f "$DOTFILES_SYNC_CACHE_FILE" ]]; then
    local last_check=$(cat "$DOTFILES_SYNC_CACHE_FILE" 2>/dev/null || echo 0)
    local now=$(date +%s)
    local elapsed=$((now - last_check))

    if [[ $elapsed -lt $DOTFILES_SYNC_CHECK_INTERVAL ]]; then
      return 0
    fi
  fi

  # Update timestamp
  date +%s > "$DOTFILES_SYNC_CACHE_FILE"

  # Check for updates
  cd "$dotfiles_dir" || return 1

  # Fetch quietly
  git fetch origin master 2>/dev/null || return 1

  local local_rev=$(git rev-parse HEAD 2>/dev/null)
  local remote_rev=$(git rev-parse origin/master 2>/dev/null)

  local commits_behind=$(git rev-list --count HEAD..origin/master 2>/dev/null)

  if [[ $commits_behind -gt 0 ]]; then
    # Updates available
    echo ""
    echo "\033[1;33m==> Dotfiles Update Available\033[0m"
    echo "Your dotfiles are \033[1;36m${commits_behind}\033[0m commit(s) behind origin/master"
    echo ""
    echo "\033[1mNew commits:\033[0m"

    # Show commit messages
    git log --oneline HEAD..origin/master | while read -r line; do
      echo "  \033[0;36m→\033[0m $line"
    done

    echo ""
    printf "Apply updates? [y/N]: "
    read -k 1 response
    echo  # newline
    echo ""

    if [[ "$response" =~ ^[Yy]$ ]]; then
      echo "\033[1mPulling changes...\033[0m"
      git pull origin master

      echo ""
      echo "\033[1mReapplying configuration files...\033[0m"
      make -C "$dotfiles_dir" link

      echo ""
      echo "\033[1mReapplying system settings...\033[0m"
      # Detect VM and pass flags to settings script
      if _is_vm; then
        VM=1 SKIP_RENAMING=1 make -C "$dotfiles_dir" settings
      else
        SKIP_RENAMING=1 make -C "$dotfiles_dir" settings
      fi

      echo ""
      echo "\033[1;32m✓ Dotfiles updated and reapplied\033[0m"
    else
      echo "Skipped. Run \033[1;36mdotsync\033[0m anytime to apply."
    fi
    echo ""
  fi
}

# Alias to manually trigger sync
alias dotsync="_dotfiles_sync"

# Run check on shell startup (synchronous to allow for interactive prompt)
_dotfiles_sync
