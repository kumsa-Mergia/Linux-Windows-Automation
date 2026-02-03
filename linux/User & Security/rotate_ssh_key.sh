#!/bin/bash

# ==========================
# CONFIGURATION
# ==========================
USER_NAME="sysadmin"
SSH_DIR="/home/$USER_NAME/.ssh"
KEY_NAME="id_ed25519"
BACKUP_DIR="$SSH_DIR/backup"
LOG_FILE="/var/log/ssh_key_rotation.log"
DATE=$(date +%F_%H-%M)

# ==========================
# SAFETY CHECKS
# ==========================
if [[ $EUID -ne 0 ]]; then
  echo "Run as root"
  exit 1
fi

if [[ ! -d "$SSH_DIR" ]]; then
  echo "SSH directory not found"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

echo "[$DATE] Starting SSH key rotation for $USER_NAME" | tee -a "$LOG_FILE"

# ==========================
# BACKUP EXISTING KEYS
# ==========================
cp "$SSH_DIR/$KEY_NAME" "$BACKUP_DIR/$KEY_NAME.$DATE" 2>/dev/null
cp "$SSH_DIR/$KEY_NAME.pub" "$BACKUP_DIR/$KEY_NAME.pub.$DATE" 2>/dev/null
cp "$SSH_DIR/authorized_keys" "$BACKUP_DIR/authorized_keys.$DATE"

# ==========================
# GENERATE NEW KEY
# ==========================
ssh-keygen -t ed25519 -f "$SSH_DIR/$KEY_NAME" -N "" -C "rotated-$DATE" <<<y >/dev/null

# ==========================
# UPDATE AUTHORIZED KEYS
# ==========================
cat "$SSH_DIR/$KEY_NAME.pub" >> "$SSH_DIR/authorized_keys"
sort -u "$SSH_DIR/authorized_keys" -o "$SSH_DIR/authorized_keys"

# ==========================
# PERMISSIONS
# ==========================
chown -R "$USER_NAME:$USER_NAME" "$SSH_DIR"
chmod 700 "$SSH_DIR"
chmod 600 "$SSH_DIR"/*
chmod 600 "$SSH_DIR/authorized_keys"

# ==========================
# RELOAD SSH (NO DISCONNECT)
# ==========================
systemctl reload sshd

echo "[$DATE] SSH key rotation completed successfully" | tee -a "$LOG_FILE"
