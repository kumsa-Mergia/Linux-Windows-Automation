#!/bin/bash

REPORT="/tmp/sudo_audit_$(hostname)_$(date +%F).txt"

echo "SUDO ACCESS AUDIT REPORT" > "$REPORT"
echo "Hostname: $(hostname)" >> "$REPORT"
echo "Generated on: $(date)" >> "$REPORT"
echo "==========================================" >> "$REPORT"
echo "" >> "$REPORT"

# 1. Sudo groups
echo "[1] Users in sudo-enabled groups" >> "$REPORT"
echo "------------------------------------------" >> "$REPORT"

for grp in sudo wheel; do
    if getent group "$grp" >/dev/null; then
        echo "Group: $grp" >> "$REPORT"
        getent group "$grp" | cut -d: -f4 | tr ',' '\n' | sed 's/^/  - /' >> "$REPORT"
    fi
done
echo "" >> "$REPORT"

# 2. Sudoers file entries
echo "[2] /etc/sudoers entries" >> "$REPORT"
echo "------------------------------------------" >> "$REPORT"
grep -Ev '^\s*#|^\s*$' /etc/sudoers >> "$REPORT"
echo "" >> "$REPORT"

# 3. Sudoers.d files
echo "[3] /etc/sudoers.d entries" >> "$REPORT"
echo "------------------------------------------" >> "$REPORT"
for f in /etc/sudoers.d/*; do
    [ -f "$f" ] || continue
    echo "File: $f" >> "$REPORT"
    grep -Ev '^\s*#|^\s*$' "$f" >> "$REPORT"
    echo "" >> "$REPORT"
done

# 4. Passwordless sudo
echo "[4] Passwordless sudo (NOPASSWD)" >> "$REPORT"
echo "------------------------------------------" >> "$REPORT"
grep -R "NOPASSWD" /etc/sudoers /etc/sudoers.d 2>/dev/null >> "$REPORT"
echo "" >> "$REPORT"

# 5. Recent sudo usage
echo "[5] Recent sudo usage (last 30 days)" >> "$REPORT"
echo "------------------------------------------" >> "$REPORT"

if command -v journalctl >/dev/null; then
    journalctl _COMM=sudo --since "30 days ago" >> "$REPORT"
elif [ -f /var/log/auth.log ]; then
    grep sudo /var/log/auth.log >> "$REPORT"
elif [ -f /var/log/secure ]; then
    grep sudo /var/log/secure >> "$REPORT"
else
    echo "No sudo logs found" >> "$REPORT"
fi
# 6 Highlight unauthorized attempts automatically
echo "[6] Unauthorized sudo attempts" >> "$REPORT"
echo "------------------------------------------" >> "$REPORT"
grep "NOT in sudoers" /var/log/auth.log >> "$REPORT"

# 7 Count sudo usage per user
echo "[7] Sudo command count by user" >> "$REPORT"
grep "COMMAND=" /var/log/auth.log | awk '{print $NF}' | sort | uniq -c >> "$REPORT"


chmod 600 "$REPORT"
echo "Audit complete: $REPORT"