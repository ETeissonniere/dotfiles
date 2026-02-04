#!/bin/bash
set -e

# ─── autofs SMB mount setup for macOS ───
# Sets up an on-demand SMB mount using macOS autofs.
# Credentials are stored in the macOS keychain (not plaintext).
# Mount auto-connects when you access the path, disconnects after idle.

MOUNT_BASE="/Volumes/NAS"

echo "=== autofs SMB Mount Setup ==="
echo ""

# ─── Gather inputs ───
read -p "NAS hostname or IP: " NAS_HOST
if [[ -z "$NAS_HOST" ]]; then
    echo "Error: hostname cannot be empty"
    exit 1
fi

read -p "SMB share name (e.g. 'Documents', 'Eliott'): " SHARE_NAME
if [[ -z "$SHARE_NAME" ]]; then
    echo "Error: share name cannot be empty"
    exit 1
fi

read -p "SMB username: " SMB_USER
if [[ -z "$SMB_USER" ]]; then
    echo "Error: username cannot be empty"
    exit 1
fi

read -p "Mount name [documents]: " MOUNT_NAME
MOUNT_NAME="${MOUNT_NAME:-documents}"

MOUNT_POINT="${MOUNT_BASE}/${MOUNT_NAME}"
AUTO_MAP="/etc/auto_nas"

echo ""
echo "Summary:"
echo "  NAS:         ${NAS_HOST}"
echo "  Share:        //${NAS_HOST}/${SHARE_NAME}"
echo "  Mount point:  ${MOUNT_POINT}"
echo "  Username:     ${SMB_USER}"
echo ""
read -p "Proceed? [y/N]: " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

# ─── Store credentials in macOS keychain ───
echo ""
echo "Storing SMB credentials in macOS keychain..."
echo "You'll be prompted for your SMB password (for the NAS)."

# Delete existing entry if present (ignore errors)
security delete-internet-password \
    -s "$NAS_HOST" \
    -a "$SMB_USER" \
    -r "smb " \
    /Users/"$(whoami)"/Library/Keychains/login.keychain-db 2>/dev/null || true

# Add new keychain entry — prompt for password
read -s -p "SMB password: " SMB_PASS
echo ""

security add-internet-password \
    -s "$NAS_HOST" \
    -a "$SMB_USER" \
    -w "$SMB_PASS" \
    -r "smb " \
    -T /usr/bin/security \
    -T /sbin/mount_smbfs \
    /Users/"$(whoami)"/Library/Keychains/login.keychain-db

unset SMB_PASS
echo "Credentials stored in keychain."

# ─── Create mount point ───
echo ""
if [[ ! -d "$MOUNT_BASE" ]]; then
    echo "Creating ${MOUNT_BASE}..."
    sudo mkdir -p "$MOUNT_BASE"
fi

# ─── Write auto_nas map file ───
echo "Writing ${AUTO_MAP}..."

# Build the autofs map line
# macOS autofs uses mount_smbfs under the hood for -fstype=smbfs
MAP_LINE="${MOUNT_NAME} -fstype=smbfs,soft,nodev,nosuid ://${SMB_USER}@${NAS_HOST}/${SHARE_NAME}"

# Check if map file exists and if this mount is already configured
if [[ -f "$AUTO_MAP" ]]; then
    if grep -q "^${MOUNT_NAME} " "$AUTO_MAP" 2>/dev/null; then
        echo "Updating existing entry for '${MOUNT_NAME}' in ${AUTO_MAP}..."
        sudo sed -i '' "s|^${MOUNT_NAME} .*|${MAP_LINE}|" "$AUTO_MAP"
    else
        echo "Appending entry for '${MOUNT_NAME}' to ${AUTO_MAP}..."
        echo "$MAP_LINE" | sudo tee -a "$AUTO_MAP" > /dev/null
    fi
else
    echo "$MAP_LINE" | sudo tee "$AUTO_MAP" > /dev/null
fi

# ─── Register in auto_master if needed ───
echo "Checking /etc/auto_master..."

if ! grep -q "^${MOUNT_BASE}" /etc/auto_master; then
    echo "Adding ${MOUNT_BASE} to /etc/auto_master..."
    echo "${MOUNT_BASE} auto_nas" | sudo tee -a /etc/auto_master > /dev/null
else
    echo "${MOUNT_BASE} already in auto_master."
fi

# ─── Add Spotlight exclusion ───
echo ""
echo "Adding Spotlight exclusion for ${MOUNT_BASE}..."
# This prevents Spotlight from keeping the mount alive
SPOTLIGHT_PLIST="/System/Volumes/Data/.Spotlight-V100/VolumeConfiguration.plist"
if [[ -f "$SPOTLIGHT_PLIST" ]]; then
    # Check if already excluded
    if ! sudo /usr/libexec/PlistBuddy -c "Print :Exclusions" "$SPOTLIGHT_PLIST" 2>/dev/null | grep -q "$MOUNT_BASE"; then
        sudo /usr/libexec/PlistBuddy -c "Add :Exclusions: string ${MOUNT_BASE}" "$SPOTLIGHT_PLIST" 2>/dev/null || true
        echo "Added Spotlight exclusion."
    else
        echo "Spotlight exclusion already exists."
    fi
else
    echo "Spotlight plist not found — add ${MOUNT_BASE} manually in System Settings → Spotlight → Search Privacy"
fi

# ─── Reload autofs ───
echo ""
echo "Reloading autofs..."
sudo automount -vc

echo ""
echo "=== Done! ==="
echo ""
echo "Usage:"
echo "  ls ${MOUNT_POINT}          # triggers mount on demand"
echo "  cd ${MOUNT_POINT}          # same — just access the path"
echo "  open ${MOUNT_POINT}        # open in Finder"
echo ""
echo "The mount auto-disconnects after ~5 min idle."
echo ""
echo "To change the NAS host later (e.g. switch to Tailscale IP):"
echo "  sudo nano ${AUTO_MAP}"
echo "  sudo automount -vc"
echo ""
echo "To remove:"
echo "  sudo nano /etc/auto_master   # remove the ${MOUNT_BASE} line"
echo "  sudo rm ${AUTO_MAP}"
echo "  sudo automount -vc"
echo "  security delete-internet-password -s ${NAS_HOST} -a ${SMB_USER} -r 'smb '"
