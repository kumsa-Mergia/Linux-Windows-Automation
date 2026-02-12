#!/bin/bash
# --------------------------------------------------
# Linux Password Policy Hardening
# Enforces complexity, aging, and account lockout
# Supports: RHEL/CentOS/Rocky/Alma & Ubuntu/Debian
# Run as root
# --------------------------------------------------

set -e

LOG_FILE="/var/log/password_policy_hardening.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "============================================"
echo " PASSWORD POLICY HARDENING - $DATE"
echo "============================================"

# Detect OS
if [ -f /etc/redhat-release ]; then
    OS="rhel"
elif [ -f /etc/debian_version ]; then
    OS="debian"
else
    echo "Unsupported OS"
    exit 1
fi

echo "🖥 Detected OS: $OS"

# Install pwquality
echo "Installing pwquality..."
if [ "$OS" = "rhel" ]; then
    yum install -y libpwquality
else
    apt install -y libpam-pwquality -qq
fi

# Password Complexity
PWQUALITY_CONF="/etc/security/pwquality.conf"
cat > "$PWQUALITY_CONF" <<EOF
minlen = 12
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
retry = 3
EOF
echo "Configured password complexity."

# Enforce PAM pwquality
for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth /etc/pam.d/common-password; do
    if [ -f "$pam_file" ]; then
        grep -q pam_pwquality.so "$pam_file" || \
        sed -i '/pam_unix.so/ i password requisite pam_pwquality.so retry=3' "$pam_file"
    fi
done

# Password Aging
LOGIN_DEFS="/etc/login.defs"
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' "$LOGIN_DEFS"
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' "$LOGIN_DEFS"
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' "$LOGIN_DEFS"

awk -F: '$3 >= 1000 {print $1}' /etc/passwd | while read -r user; do
    chage -M 90 -m 7 -W 14 "$user"
done

# Account Lockout (pam_faillock)
if [ "$OS" = "rhel" ]; then
    for pam in system-auth password-auth; do
        PAM_FILE="/etc/pam.d/$pam"
        grep -q pam_faillock.so "$PAM_FILE" || cat >> "$PAM_FILE" <<EOF

auth required pam_faillock.so preauth silent deny=5 unlock_time=900
auth [default=die] pam_faillock.so authfail deny=5 unlock_time=900
account required pam_faillock.so
EOF
    done
else
    PAM_FILE="/etc/pam.d/common-auth"
    grep -q pam_faillock.so "$PAM_FILE" || cat >> "$PAM_FILE" <<EOF

auth required pam_faillock.so preauth silent deny=5 unlock_time=900
auth [default=die] pam_faillock.so authfail deny=5 unlock_time=900
account required pam_faillock.so
EOF
fi

# Log summary
echo "[$DATE] OS:$OS | Password policy hardening applied successfully" >> "$LOG_FILE"

echo "Password policy hardening completed successfully!"
echo "Log saved to $LOG_FILE"
