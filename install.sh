#!/bin/bash
set -e

REPO="https://github.com/Purplenodes007/purpleos-apt.git"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "=================================="
echo "       PURPLE OS INSTALLER"
echo "=================================="

if [ "$EUID" -ne 0 ]; then
    echo "Please run this installer as root."
    exit 1
fi

if [ ! -f /etc/debian_version ]; then
    echo "Error: Debian Linux is required."
    exit 1
fi

echo "[1/4] Checking dependencies..."

if ! command -v git >/dev/null 2>&1; then
    apt-get update
    apt-get install -y git
fi

echo "[2/4] Downloading Purple OS..."

git clone --depth 1 "$REPO" "$TMP_DIR/repo"

echo "[3/4] Finding latest Purple OS package..."

PACKAGE="$(find "$TMP_DIR/repo/pool" -maxdepth 1 -type f -name 'purpleos_*_all.deb' | sort -V | tail -n 1)"

if [ -z "$PACKAGE" ]; then
    echo "Error: Purple OS package not found!"
    exit 1
fi

VERSION="$(dpkg-deb -f "$PACKAGE" Version)"

echo "Installing Purple OS version: $VERSION"

echo "[4/4] Installing package..."
dpkg -i "$PACKAGE"

echo ""
echo "=================================="
echo " PURPLE OS INSTALLATION FINISHED!"
echo "=================================="
echo "Installed version: $VERSION"
echo "Run: purple-version"
echo "Run: purple-dashboard-setup"
echo ""
