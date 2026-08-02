#!/bin/sh
set -eu

IPHONE_IP=${1:-${IPHONE_IP_ADDRESS:-}}
[ -n "$IPHONE_IP" ] || { echo 'error: iPhone IP is required' >&2; exit 1; }
command -v sshpass >/dev/null 2>&1 || { echo 'error: sshpass not found' >&2; exit 1; }

sshpass -p 'alpine' ssh -T \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o KexAlgorithms=+diffie-hellman-group14-sha1 \
    -o HostKeyAlgorithms=+ssh-rsa \
    "root@$IPHONE_IP" sh -s <<'REMOTE'
set -eu

PACKAGE_ID=com.yourcompany.theosat
SOURCE_DIR=/var/jb/etc/apt/sources.list.d
DPKG=/var/jb/usr/bin/dpkg

[ "$(id -u)" -eq 0 ] || { echo 'error: run as root' >&2; exit 1; }
[ -x "$DPKG" ] || { echo 'error: dpkg not found' >&2; exit 1; }

status=$("$DPKG" -s "$PACKAGE_ID" 2>/dev/null | sed -n 's/^Status: //p' || true)
if [ "$status" = 'install ok installed' ]; then
    "$DPKG" --remove "$PACKAGE_ID"
fi
rm -f "$SOURCE_DIR/theosat.list" "$SOURCE_DIR"/theosat-*.list
echo "uninstalled: $PACKAGE_ID"
REMOTE
