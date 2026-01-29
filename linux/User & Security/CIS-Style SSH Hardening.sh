#!/bin/bash

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak.$(date +%F_%T)"

# Must be run as root
if [[ $EUID -ne 0 ]]; then
  echo "Run as root"
  exit 1
fi

echo "Backing up sshd_config to $BACKUP"
cp "$SSHD_CONFIG" "$BACKUP"

set_config () {
  local KEY=$1
  local VALUE=$2

  if grep -qE "^[#]*\s*${KEY}\s+" "$SSHD_CONFIG"; then
    sed -i "s|^[#]*\s*${KEY}\s+.*|${KEY} ${VALUE}|" "$SSHD_CONFIG"
  else
    echo "${KEY} ${VALUE}" >> "$SSHD_CONFIG"
  fi
}

echo "Applying CIS SSH hardening settings..."

# Protocol
set_config Protocol 2

# Root login
set_config PermitRootLogin no

# Password authentication
set_config PasswordAuthentication no
set_config ChallengeResponseAuthentication no
set_config UsePAM yes

# Public key auth
set_config PubkeyAuthentication yes

# Limit authentication attempts
set_config MaxAuthTries 4

# Login grace time
set_config LoginGraceTime 60

# Disable empty passwords
set_config PermitEmptyPasswords no

# X11 forwarding
set_config X11Forwarding no

# TCP forwarding
set_config AllowTcpForwarding no

# Agent forwarding
set_config AllowAgentForwarding no

# Client alive settings (timeout idle sessions)
set_config ClientAliveInterval 300
set_config ClientAliveCountMax 0

# Strong ciphers (CIS-ish safe defaults)
set_config Ciphers aes256-ctr,aes192-ctr,aes128-ctr
set_config MACs hmac-sha2-512,hmac-sha2-256
set_config KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group14-sha256

# Log level
set_config LogLevel VERBOSE

# Banner (optional – comment out if unwanted)
set_config Banner /etc/issue.net

echo "Validating sshd configuration..."
sshd -t

if [[ $? -eq 0 ]]; then
  echo "Restarting sshd..."
  systemctl restart sshd
  echo "SSH hardening applied successfully."
else
  echo "ERROR: sshd config invalid. Restoring backup."
  cp "$BACKUP" "$SSHD_CONFIG"
fi
