#!/bin/bash
# ===========================================
# Snapshot Cleanup Script
# Author: Kumsa Mergia
# Description: Cleans up old LVM snapshots or filesystem snapshots
# Logs deleted snapshots and exits with proper status
# ===========================================

# -----------------------------
# User-configurable variables
# -----------------------------
SNAPSHOT_DIR="/snapshots"        # Directory where snapshots are stored
RETENTION_DAYS=7                 # Keep snapshots newer than this number of days
LOG_FILE="/var/log/snapshot_cleanup.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
ALERT=0

echo "=============================="
echo "Snapshot Cleanup - $(hostname)"
echo "Checked at: $DATE"
echo "Retention Days: $RETENTION_DAYS"
echo "Directory: $SNAPSHOT_DIR"
echo "=============================="

# -----------------------------
# Find snapshots older than RETENTION_DAYS
# -----------------------------
OLD_SNAPSHOTS=$(find "$SNAPSHOT_DIR" -maxdepth 1 -type f -mtime +$RETENTION_DAYS)

if [ -z "$OLD_SNAPSHOTS" ]; then
    echo "✔ No snapshots older than $RETENTION_DAYS days"
else
    for SNAP in $OLD_SNAPSHOTS; do
        echo "Deleting old snapshot: $SNAP"
        echo "[$DATE] Deleting $SNAP" >> $LOG_FILE
        rm -f "$SNAP"
        if [ $? -ne 0 ]; then
            echo "❌ Failed to delete $SNAP"
            ALERT=1
        fi
    done
fi

echo "=============================="

if [ "$ALERT" -eq 1 ]; then
    echo "⚠ Some snapshots could not be deleted. Check log: $LOG_FILE"
    exit 1
else
    echo "✔ Snapshot cleanup completed successfully"
    exit 0
fi