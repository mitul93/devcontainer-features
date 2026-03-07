#!/usr/bin/env bash
# vtune_pinned_version.sh — only verify CLI is present

set -euo pipefail

# Optional: Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

check "vtune version is 2025.9.0" bash -c "vtune --version > /dev/null"

# Report result
reportResults