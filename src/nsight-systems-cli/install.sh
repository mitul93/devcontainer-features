#!/usr/bin/env bash
set -euo pipefail

# ── Helpers ───────────────────────────────────────────────────────────────────
# For Ubuntu get OS version without dot
# For Debian, map debian version to appropriate Ubuntu version
# https://developer.nvidia.com/w/devtools/repos/
get_repo_os() {
    if grep -qi "ubuntu" /etc/os-release; then
        grep '^VERSION_ID=' /etc/os-release \
            | cut -d= -f2 \
            | tr -d '."'

    elif grep -qi "debian" /etc/os-release; then
        CODENAME="$(grep '^VERSION_CODENAME=' /etc/os-release | cut -d= -f2)"

        case "${CODENAME}" in
            duke) echo "2604" ;;
            trixie) echo "2404" ;;
            bookworm) echo "2204" ;;
            bullseye) echo "2004" ;;
            buster) echo "1804" ;;
            stretch) echo "1604" ;;
            *) echo "ERROR: Unsupported Debian codename: ${CODENAME}" >&2; exit 1 ;;
        esac
    else
        echo "ERROR: Unsupported distribution" >&2
        exit 1
    fi
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "ERROR: install.sh must be run as root (use sudo)." >&2
        exit 1
    fi
}

check_debian() {
    if ! command -v apt-get &>/dev/null; then
        echo "ERROR: This feature only supports Debian/Ubuntu-based distros." >&2
        exit 1
    fi
}

# Installs a package, optionally pinned to a version.
# Usage: install_package <package> [version]
install_package() {
    local pkg="$1"
    local ver="${2:-}"
    if [ -n "${ver}" ] && [ "${ver}" != "latest" ]; then
        echo "(*) Installing ${pkg}=${ver}..."
        apt-get install -y --no-install-recommends "${pkg}-${ver}"
    else
        echo "(*) Installing ${pkg} (latest)..."
        apt-get install -y --no-install-recommends "${pkg}"
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
# shellcheck disable=SC2034
DEBIAN_FRONTEND=noninteractive

VERSION="${VERSION:-"latest"}"

# Detect Ubuntu version and architecture
ARCH="$(dpkg --print-architecture)"
OS_NAME="$(grep ^NAME= /etc/os-release | cut -d= -f2 | tr -d '\"')"
OS_VERSION="$(grep ^VERSION= /etc/os-release | cut -d= -f2 | tr -d '\"')"

REPO_OS_VERSION="$(get_repo_os)"
NVIDIA_GPG_KEY_URL="https://developer.download.nvidia.com/devtools/repos/ubuntu${REPO_OS_VERSION}/${ARCH}/nvidia.pub"
NVIDIA_KEYRING="/usr/share/keyrings/nvidia-devtools-keyring.gpg"
NVIDIA_APT_LIST="/etc/apt/sources.list.d/nvidia-devtools.list"

check_root
check_debian

echo "(*) NVIDIA Nsight Systems CLI install"
echo "    version  : ${VERSION}"
echo "    os       : ${OS_NAME} ${OS_VERSION}"
echo "    repo os  : ubuntu${REPO_OS_VERSION}"
echo "    arch     : ${ARCH}"
echo ""

apt-get update -y
apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    ca-certificates

# ── NVIDIA devtools APT repository ───────────────────────────────────────────
if [ ! -f "${NVIDIA_APT_LIST}" ]; then
    echo "(*) Adding NVIDIA devtools APT repository..."
    echo "    repo: https://developer.download.nvidia.com/devtools/repos/ubuntu${REPO_OS_VERSION}/${ARCH}"

    echo "Getting $NVIDIA_GPG_KEY_URL"

    wget -qO- "${NVIDIA_GPG_KEY_URL}" \
        | gpg --dearmor \
        | tee "${NVIDIA_KEYRING}" > /dev/null

    echo "deb [signed-by=${NVIDIA_KEYRING}] https://developer.download.nvidia.com/devtools/repos/ubuntu${REPO_OS_VERSION}/${ARCH} /" \
        | tee "${NVIDIA_APT_LIST}"

    apt-get update -y
else
    echo "(*) NVIDIA devtools APT repository already configured, skipping."
fi

# ── Install: Nsight Systems CLI ───────────────────────────────────────────────
install_package "nsight-systems-cli" "${VERSION}"

# ── Cleanup ───────────────────────────────────────────────────────────────────
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*

echo ""
echo "(*) Installation complete."
echo "(*) Usage: nsys [command] [options]"