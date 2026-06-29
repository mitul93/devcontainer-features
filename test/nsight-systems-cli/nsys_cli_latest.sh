#!/usr/bin/env bash
# verify Nsight Systems CLI install
set -euo pipefail

# shellcheck disable=SC1091
source dev-container-features-test-lib

nsys --version
check "nsys binary exists" command -v nsys

# Report result
reportResults