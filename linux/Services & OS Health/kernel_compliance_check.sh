#!/bin/bash

# ================================
# Kernel Version Compliance Check
# ================================

REQUIRED_KERNEL="5.4.0"

HOSTNAME=$(hostname)
CURRENT_KERNEL=$(uname -r | cut -d'-' -f1)

# Function to compare versions
version_ge() {
    printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1 | grep -qx "$2"
}

echo "========================================"
echo " Kernel Version Compliance Check"
echo "========================================"
echo " Hostname        : $HOSTNAME"
echo " Required Kernel : $REQUIRED_KERNEL"
echo " Current Kernel  : $CURRENT_KERNEL"
echo "----------------------------------------"

if version_ge "$CURRENT_KERNEL" "$REQUIRED_KERNEL"; then
    echo " STATUS : COMPLIANT "
    exit 0
else
    echo " STATUS : NON-COMPLIANT "
    echo " ACTION : Kernel upgrade required"
    exit 1
fi
