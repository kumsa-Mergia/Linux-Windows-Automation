#!/bin/bash
# --------------------------------------------------
# Linux OS Password Aging & Complexity Hardening
# Supports: RHEL/CentOS/Rocky/Alma & Ubuntu/Debian
# Run as root
# --------------------------------------------------

set -e

echo " Starting password policy hardening..."

# -------------------------------
# Detect OS
# -------------------------------
if [ -f /etc/redhat-release ]; then
    OS="rhel"
elif [ -f /etc/debian_version ]; then
    OS="debian"
else
    echo " Unsupported OS"
    exit 1
fi

echo "🖥 Detected OS: $OS"

# -------------------------------
# Install required packages
# -------------------------------
echo " Installing pwquality..."

if [ "$OS" = "rhel" ]; then
    yum install -y libpwquality
else
    apt update -y
    apt install -y libpam-pwquality
fi

# -------------------------------
# Password Complexity
# -------------------------------
PWQUALITY_CONF="/etc/security/pwquality.conf"

echo " Configuring password complexity..."

cat > "$PWQUALITY_CONF" <<EOF
minlen = 12
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
retry = 3
EOF

# -------------------------------
# Ensure PAM uses pwquality
# -------------------------------
echo " Enforcing PAM pwquality..."

for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth /etc/pam.d/common-password; do
    if [ -f "$pam_file" ]; then
        grep -q pam_pwquality.so "$pam_file" || \
        sed -i '/pam_unix.so/ i password requisite pam_pwquality.so retry=3' "$pam_file"
    fi
done

# -------------------------------
# Password Aging Policy
# -------------------------------
LOGIN_DEFS="/etc/login.defs"

echo " Configuring password aging..."

sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' "$LOGIN_DEFS"
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' "$LOGIN_DEFS"
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' "$LOGIN_DEFS"

# -------------------------------
# Apply aging to existing users
# (UID >= 1000, non-system users)
# -------------------------------
echo " Applying aging policy to existing users..."

awk -F: '$3 >= 1000 {print $1}' /etc/passwd | while read -r user; do
    chage -M 90 -m 7 -W 14 "$user"
done

# -------------------------------
# Account Lockout (pam_faillock)
# -------------------------------
echo " Configuring account lockout..."

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

echo " Password policy hardening completed successfully!"
