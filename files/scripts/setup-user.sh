#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# User Creation Script for Acer Minimal OS
# This runs at IMAGE BUILD TIME, baking the user into the OCI container
# =============================================================================

USERNAME="dj"
# Password: changeme (SHA-512 hash)
# Generated with: openssl passwd -6 changeme
PASSWORD_HASH='$6$rounds=4096$randomsalt$kJ8QjK2vPBhJE.jU3tGh0KcLZqW5mN7rY1xV9bC4dF6gH8iI0jK2lL3mM4nN5oO6pP7qQ8rR9sS0tT1uU2vV3w'

echo "=== Creating default user: ${USERNAME} ==="

# Create user with home directory and bash shell
if ! id "${USERNAME}" &>/dev/null; then
    useradd -m -G wheel -s /bin/bash "${USERNAME}"
    echo "User ${USERNAME} created"
else
    echo "User ${USERNAME} already exists"
fi

# Set password using chpasswd (accepts plaintext, easier for hobby project)
echo "${USERNAME}:changeme" | chpasswd
echo "Password set for ${USERNAME}"

# Ensure wheel group has passwordless sudo for convenience
cat > /etc/sudoers.d/wheel-nopasswd << 'EOF'
# Allow wheel group passwordless sudo (for hobby/development use)
%wheel ALL=(ALL) NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/wheel-nopasswd

# Create standard user directories
mkdir -p /home/${USERNAME}/{Desktop,Documents,Downloads}
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

echo "=== User setup complete ==="
echo "Username: ${USERNAME}"
echo "Password: changeme"
echo "CHANGE YOUR PASSWORD ON FIRST LOGIN with: passwd"
