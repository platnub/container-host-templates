#!/bin/bash

# Must be run as root (sudo)
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (use sudo)."
    exit 1
fi

# Determine target user
if [ -n "$1" ]; then
    TARGET_USER="$1"
else
    # Fall back to the user who invoked sudo, or current user
    TARGET_USER="${SUDO_USER:-$(whoami)}"
fi

echo "Setting up SSH keys for user: $TARGET_USER"

# Verify the target user exists and has a home directory
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

if [ -z "$TARGET_HOME" ]; then
    echo "Error: User '$TARGET_USER' does not exist."
    exit 1
fi

if [ ! -d "$TARGET_HOME" ]; then
    echo "Error: Home directory '$TARGET_HOME' does not exist for user '$TARGET_USER'."
    exit 1
fi

echo "Starting SSH key setup..."

SSH_DIR="$TARGET_HOME/.ssh"

if [ ! -d "$SSH_DIR" ]; then
    echo "Creating SSH directory: $SSH_DIR"
    mkdir -p "$SSH_DIR"
fi

# Generate SSH key pair for the target user
ssh-keygen -t rsa -f "$SSH_DIR/id_rsa" -C "$TARGET_USER"

cat "$SSH_DIR/id_rsa"
read -p "Copy the FULL private key, import into Bitwarden, then press ENTER to continue..."
read -r -p "Paste your public key (single line): " PUBKEY

touch "$SSH_DIR/authorized_keys"

# Check if key already exists
if ! grep -qxF "$PUBKEY" "$SSH_DIR/authorized_keys"; then
    printf '%s\n' "$PUBKEY" >> "$SSH_DIR/authorized_keys"
    echo "Key added to $SSH_DIR/authorized_keys"
else
    echo "Key already exists in $SSH_DIR/authorized_keys"
fi

# Set correct ownership (recursive) and permissions
echo "Setting ownership and permissions..."
chown -R "$TARGET_USER":"$TARGET_USER" "$SSH_DIR"
chmod 700 "$SSH_DIR"
chmod 600 "$SSH_DIR/id_rsa"
chmod 600 "$SSH_DIR/id_rsa.pub"
chmod 600 "$SSH_DIR/authorized_keys"

echo "SSH key setup complete for user '$TARGET_USER'."
