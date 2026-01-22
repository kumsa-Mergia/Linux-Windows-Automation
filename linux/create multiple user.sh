#!/bin/bash
# -------------------------------------------------
# Script Name : create_users.sh
# Description : Creates multiple Linux users,
#               sets a common password,
#               forces password change on first login,
#               and adds users to the sudo group.
# -------------------------------------------------

# List of users to be created (space-separated)
USERS="naole kaleb zerihune"

# Prompt for password securely (input will not be shown)
read -s -p "Enter password for new users: " PASSWORD
echo
read -s -p "Confirm password: " CONFIRM
echo

# Check if both passwords match
if [ "$PASSWORD" != "$CONFIRM" ]; then
    echo " Passwords do not match. Exiting."
    exit 1
fi

# Loop through each user in the USERS list
for user in $USERS; do
    echo " Creating user: $user"

    # Create the user with:
    # -m : create home directory
    # -s : set default shell to /bin/bash
    /usr/sbin/useradd -m -s /bin/bash "$user"

    # Set the user's password
    echo "$user:$PASSWORD" | chpasswd

    # Force user to change password on first login
    passwd -e "$user"

    # Add user to sudo group for administrative privileges
    /usr/sbin/usermod -aG sudo "$user"

    echo " User $user created successfully"
done

echo " All users have been created and configured."
