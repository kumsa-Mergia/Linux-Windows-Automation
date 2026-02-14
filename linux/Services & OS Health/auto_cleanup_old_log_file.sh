#!/bin/bash

# =========================================
# Auto Cleanup Old Log Files
# =========================================

# CONFIGURATION
LOG_DIR="/var/log/myapp"   # Directory containing log files
DAYS_OLD=30                # Delete files older than this many days
DRY_RUN=true               # true = just show files, false = delete

# Check if log directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Log directory $LOG_DIR does not exist!"
    exit 1
fi

echo "========================================="
echo "Auto-cleanup old log files in $LOG_DIR"
echo "Files older than $DAYS_OLD days"
echo "Dry run mode: $DRY_RUN"
echo "========================================="

if [ "$DRY_RUN" = true ]; then
    echo "Files that would be deleted:"
    find "$LOG_DIR" -type f -name "*.log" -mtime +"$DAYS_OLD"
else
    echo "Deleting files..."
    find "$LOG_DIR" -type f -name "*.log" -mtime +"$DAYS_OLD" -exec rm -f {} \;
    echo "Cleanup complete."
fi
