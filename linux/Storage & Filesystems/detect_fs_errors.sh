#!/bin/bash

# ===============================
# Detect Filesystem Errors
# ===============================

LOG_FILE="/var/log/filesystem_check.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "==============================" | tee -a $LOG_FILE
echo "Filesystem Error Detection - $DATE" | tee -a $LOG_FILE
echo "==============================" | tee -a $LOG_FILE

# List all mounted filesystems to check
FILESYSTEMS=$(df -hT | awk 'NR>1 {print $1 " " $7}')

for FS in $FILESYSTEMS; do
    DEVICE=$(echo $FS | awk '{print $1}')
    MOUNTPOINT=$(echo $FS | awk '{print $2}')

    echo "Checking $DEVICE mounted on $MOUNTPOINT ..." | tee -a $LOG_FILE
    
    # Run fsck in read-only mode (-n)
    sudo fsck -N $DEVICE 2>&1 | tee -a $LOG_FILE
done

echo "Filesystem check completed." | tee -a $LOG_FILE
echo