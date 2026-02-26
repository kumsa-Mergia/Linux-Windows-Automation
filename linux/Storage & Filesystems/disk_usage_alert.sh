#!/bin/bash
# ===========================================
# Disk Usage Alert Script (Enterprise Version)
# Author: Kumsa Mergia
# Description: Checks all mounted partitions for disk usage.
# Flags each partition as OK / WARNING / CRITICAL based on thresholds.
# Logs alerts and exits with proper status for monitoring systems.
# ===========================================

# -----------------------------
# User-configurable thresholds
# -----------------------------
WARNING_THRESHOLD=${1:-70}    # Default warning threshold (%)
CRITICAL_THRESHOLD=${2:-85}   # Default critical threshold (%)

HOSTNAME=$(hostname)
DATE=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="/var/log/disk_usage_alert.log"

# Exit code tracker
# 0 = all OK
# 1 = warning or critical found
EXIT_CODE=0

# -----------------------------
# Print header
# -----------------------------
echo "=============================="
echo "Disk Usage Report - $HOSTNAME"
echo "Warning Threshold: $WARNING_THRESHOLD% | Critical Threshold: $CRITICAL_THRESHOLD%"
echo "Checked at: $DATE"
echo "=============================="

# -----------------------------
# Loop over all relevant partitions
# Excluding system/virtual filesystems
# -----------------------------
while read -r filesystem size used avail usepercent mountpoint
do
    # Remove the '%' from the usage
    usage=${usepercent%\%}

    # Determine status
    if [ "$usage" -ge "$CRITICAL_THRESHOLD" ]; then
        # CRITICAL status
        echo "❌ CRITICAL: $mountpoint is ${usage}% full"
        echo "[$DATE] CRITICAL: $mountpoint is ${usage}% full on $HOSTNAME" >> $LOG_FILE
        EXIT_CODE=1
    elif [ "$usage" -ge "$WARNING_THRESHOLD" ]; then
        # WARNING status
        echo "⚠ WARNING: $mountpoint is ${usage}% used"
        echo "[$DATE] WARNING: $mountpoint is ${usage}% used on $HOSTNAME" >> $LOG_FILE
        EXIT_CODE=1
    else
        # OK status
        echo "✅ OK: $mountpoint is ${usage}% used"
    fi

done < <(df -hP -x tmpfs -x devtmpfs -x efivarfs -x overlay -x squashfs | tail -n +2)

# -----------------------------
# Summary and exit code
# -----------------------------
echo "=============================="
if [ "$EXIT_CODE" -eq 1 ]; then
    echo "⚠ One or more partitions exceeded thresholds."
    exit 1
else
    echo "✔ All partitions are under control."
    exit 0
fi