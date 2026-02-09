#!/bin/bash
set -e

# ===== VARIABLES =====
DISK="/dev/sdb"
VG_NAME="datavg"
LV_NAME="datalv"
MOUNT_POINT="/data"
LV_SIZE="100%FREE"
FS_TYPE="xfs"

# ===== FUNCTIONS =====
log() {
    echo -e "\n[INFO] $1"
}

error_exit() {
    echo -e "\n[ERROR] $1"
    exit 1
}

# ===== CHECKS =====
[ "$EUID" -ne 0 ] && error_exit "Run this script as root"

[ ! -b "$DISK" ] && error_exit "Disk $DISK not found"

lsblk "$DISK" | grep -q part && error_exit "$DISK already has partitions"

# ===== CREATE LVM =====
log "Creating Physical Volume on $DISK"
pvcreate "$DISK"

log "Creating Volume Group $VG_NAME"
vgcreate "$VG_NAME" "$DISK"

log "Creating Logical Volume $LV_NAME"
lvcreate -n "$LV_NAME" -l "$LV_SIZE" "$VG_NAME"

LV_PATH="/dev/$VG_NAME/$LV_NAME"

# ===== FORMAT =====
log "Formatting $LV_PATH with $FS_TYPE"
mkfs.$FS_TYPE "$LV_PATH"

# ===== MOUNT =====
log "Creating mount point $MOUNT_POINT"
mkdir -p "$MOUNT_POINT"

log "Mounting $LV_PATH to $MOUNT_POINT"
mount "$LV_PATH" "$MOUNT_POINT"

# ===== FSTAB =====
UUID=$(blkid -s UUID -o value "$LV_PATH")

log "Adding entry to /etc/fstab"
echo "UUID=$UUID  $MOUNT_POINT  $FS_TYPE  defaults  0  0" >> /etc/fstab

# ===== VERIFY =====
log "Verifying mount"
df -h "$MOUNT_POINT"

log "LVM setup completed successfully 🎉"