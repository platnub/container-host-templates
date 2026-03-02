#!/bin/bash

if [ "$EUID" -eq 0 ]; then
    echo "This script must not be run as root."
    exit 1
fi

echo "Starting SSH key setup..."
ssh-keygen -t rsa
cat ~/.ssh/rd_rsa
read -p "Copy the FULL private key, import into Bitwarden, then press ENTER to continue..."
read -r -p "Paste your public key (single line): " PUBKEY
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Check if key already exists
if ! grep -qxF "$PUBKEY" ~/.ssh/authorized_keys; then
  printf '%s\n' "$PUBKEY" >> ~/.ssh/authorized_keys
  echo "Key added to ~/.ssh/authorized_keys"
else
  echo "Key already exists in ~/.ssh/authorized_keys"
fi
