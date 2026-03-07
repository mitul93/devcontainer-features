#!/usr/bin/env bash
# full.sh — verify CLI + sampling drivers

set -euo pipefail

# Optional: Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

# shellcheck disable=SC1091
vtune --version
check "vtune-self-checker.sh exists" test -f /opt/intel/oneapi/vtune/latest/bin64/vtune-self-checker.sh

# Report result
reportResults