#!/usr/bin/env bash
set -euo pipefail

# ── Test suite for devcontainer-feature-vtune ─────────────────────────────────
# Follows the devcontainer feature testing spec:
# https://github.com/devcontainers/cli/blob/main/docs/features/test.md

VTUNE_BASE="/opt/intel/oneapi/vtune/latest"
VTUNE_BIN="${VTUNE_BASE}/bin64/vtune"
VTUNE_VARS="${VTUNE_BASE}/env/vars.sh"
VTUNE_SELF_CHECKER="${VTUNE_BASE}/bin64/vtune-self-checker.sh"
VTUNE_GUI_BIN="${VTUNE_BASE}/bin64/vtune-gui"
VTUNE_DRIVERS_DIR="${VTUNE_BASE}/sepdk"
PROFILE_D="/etc/profile.d/vtune.sh"

PASS=0
FAIL=0

# ── Helpers ───────────────────────────────────────────────────────────────────
pass() {
    echo "  [PASS] $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "  [FAIL] $1" >&2
    FAIL=$((FAIL + 1))
}

check() {
    local description="$1"
    local condition="$2"
    if eval "${condition}"; then
        pass "${description}"
    else
        fail "${description}"
    fi
}

section() {
    echo ""
    echo "── $1 ──"
}

# ── Core: always present ──────────────────────────────────────────────────────
section "Core installation"

check "vtune binary exists"          "[ -f '${VTUNE_BIN}' ]"
check "vtune binary is executable"   "[ -x '${VTUNE_BIN}' ]"
check "vtune env vars script exists" "[ -f '${VTUNE_VARS}' ]"
check "profile.d entry exists"       "[ -f '${PROFILE_D}' ]"
check "profile.d entry is executable" "[ -x '${PROFILE_D}' ]"

# Source env vars so vtune is on PATH for subsequent checks
# shellcheck disable=SC1090
source "${VTUNE_VARS}"

check "vtune is on PATH after sourcing vars" "command -v vtune &>/dev/null"
check "vtune --version exits successfully"   "${VTUNE_BIN} --version &>/dev/null"

# Verify version string is non-empty
VTUNE_VERSION_OUTPUT=$("${VTUNE_BIN}" --version 2>&1 || true)
check "vtune --version outputs non-empty string" "[ -n '${VTUNE_VERSION_OUTPUT}' ]"

# ── GUI: only checked if binary is present ────────────────────────────────────
section "GUI components (skipped if not installed)"

if [ -f "${VTUNE_GUI_BIN}" ]; then
    check "vtune-gui binary exists"        "[ -f '${VTUNE_GUI_BIN}' ]"
    check "vtune-gui binary is executable" "[ -x '${VTUNE_GUI_BIN}' ]"
else
    echo "  [SKIP] GUI not installed — skipping GUI checks."
fi

# ── Sampling drivers: only checked if sepdk dir is present ───────────────────
section "Sampling drivers (skipped if not installed)"

if [ -d "${VTUNE_DRIVERS_DIR}" ]; then
    check "sampling drivers directory exists" "[ -d '${VTUNE_DRIVERS_DIR}' ]"
    check "insmod-sep script exists" \
        "[ -f '${VTUNE_DRIVERS_DIR}/src/insmod-sep' ] || \
         [ -f '${VTUNE_DRIVERS_DIR}/insmod-sep' ]"
else
    echo "  [SKIP] Sampling drivers not installed — skipping driver checks."
fi

# ── Self-checker: only run if available ──────────────────────────────────────
section "Self-checker (skipped if not installed)"

if [ -f "${VTUNE_SELF_CHECKER}" ]; then
    check "vtune-self-checker.sh exists"        "[ -f '${VTUNE_SELF_CHECKER}' ]"
    check "vtune-self-checker.sh is executable" "[ -x '${VTUNE_SELF_CHECKER}' ]"
    echo "  [INFO] Running vtune-self-checker.sh (may take a moment)..."
    if "${VTUNE_SELF_CHECKER}" &>/dev/null; then
        pass "vtune-self-checker.sh passed"
    else
        fail "vtune-self-checker.sh reported issues"
    fi
else
    echo "  [SKIP] Self-checker not present — skipping."
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════"
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo "════════════════════════════════"

if [ "${FAIL}" -gt 0 ]; then
    exit 1
fi