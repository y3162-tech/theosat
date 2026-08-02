#!/bin/sh
set -eu

IPHONE_IP=${1:-${IPHONE_IP_ADDRESS:-}}
REPO_URL=${2:-https://y3162-tech.github.io/theosat/}
PACKAGE_ID=${3:-com.yourcompany.theosat}

[ -n "$IPHONE_IP" ] || { echo 'error: iPhone IP is required' >&2; exit 1; }
command -v sshpass >/dev/null 2>&1 || { echo 'error: sshpass not found' >&2; exit 1; }

sshpass -p 'alpine' ssh -T -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=+ssh-rsa "root@$IPHONE_IP" sh -s -- "$REPO_URL" "$PACKAGE_ID" <<'REMOTE'
set -eu

REPO_URL=$1
PACKAGE_ID=$2
SOURCE_DIR=/var/jb/etc/apt/sources.list.d
SOURCE_FILE=$SOURCE_DIR/theosat.list
APT_GET=/var/jb/usr/bin/apt-get
DPKG=/var/jb/usr/bin/dpkg

error() { echo "error: $*" >&2; exit 1; }
[ "$(id -u)" -eq 0 ] || error "run as root"
[ -x "$APT_GET" ] || error "apt-get not found"
[ -x "$DPKG" ] || error "dpkg not found"

apt() { "$APT_GET" -o "Dir::Etc::sourcelist=$SOURCE_FILE" -o Dir::Etc::sourceparts=- -o APT::Get::List-Cleanup=0 -o APT::Get::AllowUnauthenticated=true -o Acquire::AllowInsecureRepositories=true "$@"; }

mkdir -p "$SOURCE_DIR"
rm -f "$SOURCE_DIR"/theosat-*.list
printf 'deb %s ./\n' "$REPO_URL" > "$SOURCE_FILE"
chmod 0644 "$SOURCE_FILE"
apt update
apt install -y "$PACKAGE_ID"
status=$("$DPKG" -s "$PACKAGE_ID" 2>/dev/null | sed -n 's/^Status: //p' || true)
[ "$status" = 'install ok installed' ] || error "package was not installed"
echo "installed: $PACKAGE_ID"
REMOTE
