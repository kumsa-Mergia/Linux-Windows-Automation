#!/bin/bash

# ===============================
# Verify Mount Points After Reboot
# ===============================

# List of critical mount points to verify
MOUNT_POINTS=(
    "/"
    "/home"
    "/data"
    "/var"
    "/opt"
    "/data"

)

LOG_FILE="/var/log/mount_check.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "==============================" | tee -a $LOG_FILE
echo "Mount Point Verification - $DATE" | tee -a $LOG_FILE
echo "==============================" | tee -a $LOG_FILE

for MP in "${MOUNT_POINTS[@]}"; do
    if mountpoint -q "$MP"; then
        echo "✅ $MP is mounted." | tee -a $LOG_FILE
    else
        echo "❌ $MP is NOT mounted!" | tee -a $LOG_FILE
    fi
done

echo "Check completed." | tee -a $LOG_FILE
echo