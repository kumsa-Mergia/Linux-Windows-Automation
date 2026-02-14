#!/bin/bash
# ==========================================
# Zombie Process Detector
# ==========================================
# Date: $(date)
# Author: System Engineer
# ==========================================

echo "=========================================="
echo "      ZOMBIE PROCESS DETECTION"
echo "=========================================="

# Count zombie processes
zombie_count=$(ps -eo stat,ppid,pid,cmd | awk '$1 ~ /Z/ {print $0}' | wc -l)

if [ "$zombie_count" -eq 0 ]; then
    echo " No zombie processes detected."
else
    echo "⚠️  Zombie processes detected: $zombie_count"
    echo "------------------------------------------"
    echo "List of zombie processes:"
    ps -eo stat,ppid,pid,cmd | awk '$1 ~ /Z/ {print "PID: "$3", PPID: "$2", CMD: "$4}'
fi

echo "=========================================="
