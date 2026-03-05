# ── Configuration ─────────────────────────────────────────────────────────────
SHELL      := /usr/bin/env bash
BASE_IMAGE ?= debian:trixie-slim

# Detect container runtime: prefer Podman, fall back to Docker
# CONTAINER_RUNTIME := $(shell command -v podman 2>/dev/null || command -v docker 2>/dev/null)
# export DOCKER_HOST ?= unix:///run/user/$(shell id -u)/podman/podman.sock

# ── CI-safe scenario lists per feature ────────────────────────────────────────
# 'full' and hardware-dependent scenarios are excluded here.
# Run them locally with: make test-all FEATURE=vtune
SCENARIOS_vtune := minimal
# SCENARIOS_my-other-feature := scenario1 scenario2

# ── Help ──────────────────────────────────────────────────────────────────────
.PHONY: help
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-35s\033[0m %s\n", $$1, $$2}'

# ── Pull base image ───────────────────────────────────────────────────────────
.PHONY: pull-base
pull-base: ## Pull and cache the base image. Override: make pull-base BASE_IMAGE=ubuntu:24.04
	@echo "==> Pulling $(BASE_IMAGE)..."
	$(CONTAINER_RUNTIME) pull $(BASE_IMAGE)

# ── Clean ─────────────────────────────────────────────────────────────────────
.PHONY: clean
clean: ## Remove dangling container images left by test runs
	@echo "==> Cleaning up dangling images..."
	$(CONTAINER_RUNTIME) image prune -f

# ── Guards ────────────────────────────────────────────────────────────────────
.PHONY: _require-feature
_require-feature:
	@test -n "$(FEATURE)" \
	  || { echo "ERROR: FEATURE is not set. Usage: make <target> FEATURE=vtune"; exit 1; }

.PHONY: _require-scenario
_require-scenario:
	@test -n "$(SCENARIO)" \
	  || { echo "ERROR: SCENARIO is not set. Usage: make test FEATURE=vtune SCENARIO=minimal"; exit 1; }

# ── lint-all ──────────────────────────────────────────────────────────────────
.PHONY: lint-all
lint-all: ## Lint all features at once
	@echo "==> Linting all features..."
	@find src -name "install.sh" -print0 \
	  | xargs -0 shellcheck --severity=warning
	@echo "==> All lint passed."

# ── Generic targets ───────────────────────────────────────────────────────────
# All targets below require FEATURE to be set.
# Usage:
#   make lint        FEATURE=vtune
#   make test        FEATURE=vtune SCENARIO=minimal
#   make test-all    FEATURE=vtune   (all scenarios from SCENARIOS_<feature>)
#   make test-full   FEATURE=vtune   (all scenarios including hardware-dependent)
#   make test-images FEATURE=vtune

.PHONY: lint
lint: _require-feature ## Lint a feature. Usage: make lint FEATURE=vtune
	@echo "==> Linting src/$(FEATURE)/install.sh..."
	@shellcheck --severity=warning src/$(FEATURE)/install.sh
	@echo "==> Lint passed."

.PHONY: test
test: _require-feature _require-scenario lint ## Run a single scenario. Usage: make test FEATURE=vtune SCENARIO=minimal
	@echo "==> [$(FEATURE)] scenario: $(SCENARIO)"
	devcontainer features test \
	  -f $(FEATURE) \
	  -i $(BASE_IMAGE) \
	  --skip-scenarios \
	  . \
	  test/$(FEATURE)/$(SCENARIO).sh

.PHONY: test-all
test-all: _require-feature lint ## Run all CI-safe scenarios for a feature. Usage: make test-all FEATURE=vtune
	@test -n "$(SCENARIOS_$(FEATURE))" \
	  || { echo "ERROR: No scenarios defined for '$(FEATURE)'. Add SCENARIOS_$(FEATURE) to the Makefile."; exit 1; }
	@echo "==> [$(FEATURE)] running CI-safe scenarios: $(SCENARIOS_$(FEATURE))"
	@for scenario in $(SCENARIOS_$(FEATURE)); do \
	  $(MAKE) test FEATURE=$(FEATURE) SCENARIO=${scenario} || exit 1; \
	done
	@echo "==> [$(FEATURE)] all CI-safe scenarios passed."

.PHONY: test-full
test-full: _require-feature lint ## Run ALL scenarios including hardware-dependent ones. Usage: make test-full FEATURE=vtune
	@echo "==> [$(FEATURE)] running all scenarios (requires hardware PMU on host)..."
	devcontainer features test \
	  --features $(FEATURE) \
	  --base-image $(BASE_IMAGE) \
	  --scenarios test/$(FEATURE)/scenarios.json \
	  .
	@echo "==> [$(FEATURE)] all scenarios passed."

.PHONY: test-images
test-images: _require-feature lint ## Test a feature across multiple base images. Usage: make test-images FEATURE=vtune
	@for image in debian:trixie-slim debian:bookworm-slim ubuntu:24.04; do \
	  echo "==> [$(FEATURE)] testing on ${image}..."; \
	  $(MAKE) test-all FEATURE=$(FEATURE) BASE_IMAGE=${image} || exit 1; \
	done