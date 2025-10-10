#!/bin/bash

set -e

echo "Proxmox Host Setup Script"
echo "=========================="

# ceph.sources
CEPH_SOURCES="/etc/apt/sources.list.d/ceph.sources"
if [ -f "$CEPH_SOURCES" ]; then
    echo "Backing up $CEPH_SOURCES..."
    cp "$CEPH_SOURCES" "${CEPH_SOURCES}.backup.$(date +%Y%m%d_%H%M%S)"
fi

echo "Updating $CEPH_SOURCES..."
tee "$CEPH_SOURCES" > /dev/null <<'EOF'
Types: deb
URIs: http://download.proxmox.com/debian/ceph-squid
Suites: trixie
Components: no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF

# pve-enterprise.sources
PVE_SOURCES="/etc/apt/sources.list.d/pve-enterprise.sources"
if [ -f "$PVE_SOURCES" ]; then
    echo "Backing up $PVE_SOURCES..."
    cp "$PVE_SOURCES" "${PVE_SOURCES}.backup.$(date +%Y%m%d_%H%M%S)"
fi

echo "Updating $PVE_SOURCES..."
tee "$PVE_SOURCES" > /dev/null <<'EOF'
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF

echo "Setup completed successfully!"
echo "Backup files have been created with timestamp suffix."
echo ""
echo "Running apt-get update..."
apt-get update

echo ""
echo "Installing Docker prerequisites..."
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo ""
echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo ""
echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo ""
echo "Updating apt cache..."
apt-get update

echo ""
echo "Installing Docker..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo ""
echo "Docker installation completed successfully!"

echo ""
echo "Installing OpenSSH server..."
apt-get install -y openssh-server

echo ""
echo "Configuring SSH..."
SSHD_CONFIG="/etc/ssh/sshd_config"
if [ -f "$SSHD_CONFIG" ]; then
    echo "Backing up $SSHD_CONFIG..."
    cp "$SSHD_CONFIG" "${SSHD_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
fi

echo "Updating $SSHD_CONFIG..."
cat > "$SSHD_CONFIG" <<'EOF'
# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/local/bin:/usr/bin:/bin:/usr/games

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

Include /etc/ssh/sshd_config.d/*.conf

#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key
#HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
PermitRootLogin yes
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

PubkeyAuthentication yes

# Expect .ssh/authorized_keys2 to be disregarded by default in future.
#AuthorizedKeysFile     .ssh/authorized_keys .ssh/authorized_keys2

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords, change to "no" here!
PasswordAuthentication no
PermitEmptyPasswords no

# Change to "yes" to enable keyboard-interactive authentication.  Depending on
# the system's configuration, this may involve passwords, challenge-response,
# one-time passwords or some combination of these and other methods.
# Beware issues with some PAM modules and threads.
KbdInteractiveAuthentication no

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the KbdInteractiveAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via KbdInteractiveAuthentication may bypass
# the setting of "PermitRootLogin prohibit-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and KbdInteractiveAuthentication to 'no'.
UsePAM yes

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
X11Forwarding yes
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
PrintMotd no
#PrintLastLog yes
#TCPKeepAlive yes
#PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS no
#PidFile /run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# Allow client to pass locale and color environment variables
AcceptEnv LANG LC_* COLORTERM NO_COLOR

# override default of no subsystems
Subsystem       sftp    /usr/lib/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
#       X11Forwarding no
#       AllowTcpForwarding no
#       PermitTTY no
#       ForceCommand cvs server
EOF

echo "SSH configuration completed!"

echo ""
echo "Starting and enabling SSH service..."
systemctl start ssh
systemctl enable ssh

echo ""
echo "All setup completed successfully!"
