#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC2034
export DEBIAN_FRONTEND=noninteractive

VERSION="${VERSION:-"latest"}"
SELF_CHECK="${SELF_CHECK:-"false"}"

INTEL_GPG_KEY_URL="https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB"
INTEL_KEYRING="/usr/share/keyrings/oneapi-archive-keyring.gpg"
INTEL_APT_LIST="/etc/apt/sources.list.d/oneAPI.list"
VTUNE_VARS="/opt/intel/oneapi/vtune/latest/env/vars.sh"

# ── Helpers ───────────────────────────────────────────────────────────────────
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
        apt-get install -y --no-install-recommends "${pkg}=${ver}"
    else
        echo "(*) Installing ${pkg} (latest)..."
        apt-get install -y --no-install-recommends "${pkg}"
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
check_root
check_debian

echo "(*) Intel VTune Profiler install"
echo "    version          : ${VERSION}"
echo "    self_check       : ${SELF_CHECK}"
echo ""

apt-get update -y
apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    ca-certificates \
    pkg-config \
    linux-headers-generic

# ── Intel oneAPI APT repository ───────────────────────────────────────────────
if [ ! -f "${INTEL_APT_LIST}" ]; then
    echo "(*) Adding Intel oneAPI APT repository..."
    wget -qO- "${INTEL_GPG_KEY_URL}" \
        | gpg --dearmor \
        | tee "${INTEL_KEYRING}" > /dev/null

    echo "deb [signed-by=${INTEL_KEYRING}] https://apt.repos.intel.com/oneapi all main" \
        | tee "${INTEL_APT_LIST}"

    apt-get update -y
else
    echo "(*) Intel oneAPI APT repository already configured, skipping."
fi

# ── Minimal install: VTune CLI ────────────────────────────────────────────────
install_package "intel-oneapi-vtune" "${VERSION}"

# ── Environment setup ─────────────────────────────────────────────────────────
cat << EOF > /etc/profile.d/vtune.sh
# Intel VTune Profiler environment
if [ -f "${VTUNE_VARS}" ]; then
    source "${VTUNE_VARS}"
fi
EOF

chmod +x /etc/profile.d/vtune.sh

# ── Optional: self-check ──────────────────────────────────────────────────────
if [ "${SELF_CHECK}" = "true" ]; then
    echo "(*) Running VTune self-checker..."
    # Source env vars first so vtune is on PATH
    # shellcheck disable=SC1090
    source "${VTUNE_VARS}"
    /opt/intel/oneapi/vtune/latest/bin64/vtune-self-checker.sh \
        && echo "(*) Self-check passed." \
        || echo "(!) Self-check reported issues — review the output above."
else
    echo "(*) Skipping self-check (self_check=false)."
fi

# ── Cleanup ───────────────────────────────────────────────────────────────────
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*

echo ""
echo "(*) Installation complete."
echo "(*) To activate manually: source ${VTUNE_VARS}"
echo "(*) GUI: make sure DISPLAY is forwarded and --device=/dev/dri is in runArgs."