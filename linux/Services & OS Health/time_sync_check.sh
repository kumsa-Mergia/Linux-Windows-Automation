#!/bin/bash

# Time Sync Verification Script
# Author: Kumsa Mega
# Purpose: Check NTP/Chrony time synchronization status

echo "=============================="
echo "     Time Sync Verification    "
echo "=============================="
echo ""

# Check if chrony is installed
if command -v chronyc &>/dev/null; then
    echo "Chrony detected."
    
    # Check chrony service status
    systemctl is-active --quiet chronyd
    if [ $? -eq 0 ]; then
        echo "Chrony service is running "
    else
        echo "Chrony service is NOT running "
    fi
    
    # Check synchronization status
    echo ""
    echo "Chrony Tracking Info:"
    chronyc tracking
    echo ""
    
    # Check chrony sources
    echo "Chrony Sources:"
    chronyc sources -v

# Check if ntpd is installed
elif command -v ntpq &>/dev/null; then
    echo "NTP detected."
    
    # Check ntpd service status
    systemctl is-active --quiet ntpd
    if [ $? -eq 0 ]; then
        echo "NTP service is running "
    else
        echo "NTP service is NOT running "
    fi
    
    # Check synchronization status
    echo ""
    echo "NTP Peers Info:"
    ntpq -p

# Neither NTP nor Chrony installed
else
    echo "No time synchronization service (NTP/Chrony) detected on this system "
fi

echo ""
echo "Current System Time: $(date)"
echo "=============================="
