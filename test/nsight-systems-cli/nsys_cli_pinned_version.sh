#!/usr/bin/env bash
# verify Nsight Systems CLI install
set -euo pipefail

# shellcheck disable=SC1091
source dev-container-features-test-lib

EXPECTED_VERSION="2026.3.1"

nsys --version
check "nsys binary exists" command -v nsys

if [ "${EXPECTED_VERSION}" != "latest" ]; then
    INSTALLED_VERSION=""
    INSTALLED_VERSION="$(nsys --version | grep -oP '\d+\.\d+\.\d+'| head -1)"
    check "nsys version matches expected (${EXPECTED_VERSION})" \
        test "${INSTALLED_VERSION}" = "${EXPECTED_VERSION}"
fi

# Report result
reportResults