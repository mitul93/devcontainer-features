#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

VTUNE_BASE="/opt/intel/oneapi/vtune/latest"

# Core
check "vtune binary exists" test -f "${VTUNE_BASE}/bin64/vtune"

reportResults