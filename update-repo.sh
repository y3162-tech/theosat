#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$repo_dir"

command -v dpkg-scanpackages >/dev/null 2>&1 || {
  echo "dpkg-scanpackages is required (install dpkg)." >&2
  exit 1
}

command -v dpkg >/dev/null 2>&1 || {
  echo "dpkg is required (install dpkg)." >&2
  exit 1
}

command -v dpkg-deb >/dev/null 2>&1 || {
  echo "dpkg-deb is required (install dpkg)." >&2
  exit 1
}

latest_version=
for deb in debs/*.deb; do
  [ -f "$deb" ] || continue
  ver=$(dpkg-deb -f "$deb" Version)
  if [ -z "$ver" ]; then
    echo "missing Version in $deb" >&2
    exit 1
  fi
  if [ -z "$latest_version" ] || dpkg --compare-versions "$ver" gt "$latest_version"; then
    latest_version=$ver
  fi
done

if [ -z "$latest_version" ]; then
  echo "no .deb packages found in debs/" >&2
  exit 1
fi

dpkg-scanpackages debs /dev/null > Packages
bzip2 -9c Packages > Packages.bz2

md5_for() {
  if command -v md5sum >/dev/null 2>&1; then
    md5sum "$1" | awk '{print $1}'
  else
    md5 -q "$1"
  fi
}

sha256_for() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

size_for() {
  wc -c < "$1" | tr -d '[:space:]'
}

{
  printf '%s\n' \
    'Origin: TheosAT' \
    'Label: TheosAT' \
    'Suite: stable'
  printf 'Version: %s\n' "$latest_version"
  printf '%s\n' \
    'Codename: theosat' \
    'Architectures: iphoneos-arm64' \
    'Components: main' \
    'Description: TheosAT Sileo repository'
  printf 'Date: %s\n' "$(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S +0000')"
  printf '%s\n' 'MD5Sum:'
  printf ' %s %s Packages\n' "$(md5_for Packages)" "$(size_for Packages)"
  printf ' %s %s Packages.bz2\n' "$(md5_for Packages.bz2)" "$(size_for Packages.bz2)"
  printf '%s\n' 'SHA256:'
  printf ' %s %s Packages\n' "$(sha256_for Packages)" "$(size_for Packages)"
  printf ' %s %s Packages.bz2\n' "$(sha256_for Packages.bz2)" "$(size_for Packages.bz2)"
} > Release

echo "Updated Packages, Packages.bz2, and Release (Version: $latest_version)"
