#!/bin/bash

# ==============================
# Disk Usage Threshold Monitor
# Author: Kumsa (System Engineer)
# ==============================

THRESHOLD=80
HOSTNAME=$(hostname)
DATE=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="/var/log/disk_usage_alert.log"
ALERT=0

echo "[$DATE] Checking disk usage on $HOSTNAME" >> $LOG_FILE

# Exclude unwanted filesystem types
df -hP -x tmpfs -x devtmpfs | tail -n +2 | while read output;
do
    usage=$(echo $output | awk '{print $5}' | sed 's/%//g')
    partition=$(echo $output | awk '{print $6}')

    if [ $usage -ge $THRESHOLD ]; then
        echo "[$DATE] ALERT: Partition $partition is ${usage}% full on $HOSTNAME" | tee -a $LOG_FILE
        ALERT=1
    fi
done

if [ $ALERT -eq 1 ]; then
    exit 1
else
    echo "[$DATE] Disk usage is under control." >> $LOG_FILE
    exit 0
fi