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
  local force="${1:-}"
  local dotfiles_dir="${DOTFILES_ROOT:-$HOME/.dotfiles}"

  # Create cache dir if needed
  mkdir -p "$(dirname "$DOTFILES_SYNC_CACHE_FILE")"

  # Check if we should run (throttle checks) - skip if forced
  if [[ "$force" != "--force" ]] && [[ -f "$DOTFILES_SYNC_CACHE_FILE" ]]; then
    local last_check=$(cat "$DOTFILES_SYNC_CACHE_FILE" 2>/dev/null || echo 0)
    local now=$(date +%s)
    local elapsed=$((now - last_check))

    if [[ $elapsed -lt $DOTFILES_SYNC_CHECK_INTERVAL ]]; then
      return 0
    fi
  fi

  # Update timestamp
  date +%s > "$DOTFILES_SYNC_CACHE_FILE"

  # Change to dotfiles directory, saving previous directory on stack
  pushd -q "$dotfiles_dir" || return 1

  # Ensure we return to original directory even on interrupt
  trap "popd -q 2>/dev/null; return 130" INT TERM

  # Fetch quietly
  git fetch origin master 2>/dev/null || { popd -q; trap - INT TERM; return 1; }

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
    # Flush any pending input before prompting (prevents accidental responses)
    while read -t 0 -k 1 2>/dev/null; do :; done

    printf "Apply updates? [y/N]: "
    read -k 1 response
    echo  # newline
    echo ""

    if [[ "$response" =~ ^[Yy]$ ]]; then
      echo "\033[1mPulling changes...\033[0m"
      local old_head=$(git rev-parse HEAD)
      git pull origin master

      echo ""
      echo "\033[1mRebuilding configuration...\033[0m"
      local flavor="${DOTFILES_FLAVOR:-}"
      if [[ -z "$flavor" ]]; then
        case "$OSTYPE" in
          darwin*) flavor="personal" ;;
          linux*)
            if [[ -f /etc/NIXOS ]]; then
              flavor="server"
            else
              flavor="linux"
            fi
            ;;
        esac
      fi
      "$dotfiles_dir/scripts/bootstrap.sh" switch "$flavor"

      echo ""
      echo "\033[1;32m✓ Dotfiles updated and reapplied\033[0m"
    else
      echo "Skipped. Run \033[1;36mdotsync\033[0m anytime to apply."
    fi
    echo ""
  fi

  # Return to original directory and remove trap
  popd -q
  trap - INT TERM
}

# Function to manually trigger sync (always forces, bypasses throttle)
dotsync() {
  _dotfiles_sync --force
}

# Run check on shell startup (synchronous to allow for interactive prompt)
_dotfiles_sync
