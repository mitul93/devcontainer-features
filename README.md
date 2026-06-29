# devcontainer-features

A collection of [dev container features](https://containers.dev/implementors/features/) for use with any devcontainer-compatible editors.

Features are published to the GitHub Container Registry (GHCR) and can be referenced directly in your `.devcontainer/devcontainer.json`.

---

## Available features

| Feature | Description | Docs |
|---|---|---|
| [nsight-systems-cli](src/nsight-systems-cli) | NVIDIA Nsight Systems CLI | [README](src/nsight-systems-cli/README.md) |
| [vtune](src/vtune) | Intel VTune Profiler | [README](src/vtune/README.md) |

---

## Usage

Add a feature to your `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/mitul93/devcontainer-features/<feature-id>:<feature-version>": {}
  }
}
```

Each feature has its own `README.md` under `src/<feature>/` with full options and examples.

---

## Repository structure

```
devcontainer-features/
├── src/
│   └── <feature>/
│       ├── devcontainer-feature.json   ← feature metadata and options
│       ├── install.sh                  ← installation script
│       └── README.md                   ← feature-specific docs
├── test/
│   └── <feature>/
│       ├── test.sh                     ← baseline tests (always runs)
│       ├── scenarios.json              ← option combinations to test
│       ├── <scenario>.sh               ← per-scenario assertions
│       └── ...
├── .github/
│   └── workflows/
│       └── manual-test-publish.yml     ← manually tests and publish via GitHub UI
├── Makefile                            ← local development and test targets
└── README.md
```

---

## Local development

### Prerequisites

```bash
# devcontainer CLI
npm install -g @devcontainers/cli

# shellcheck for linting
sudo apt install shellcheck   # Debian/Ubuntu
brew install shellcheck       # macOS

# Podman (Optional) Also works with docker
export DOCKER_HOST=unix:///run/user/$(id -u)/podman/podman.sock
```

### Common Makefile targets

```bash
make lint FEATURE=vtune                        # lint a feature
make lint-all                                  # lint all features
make test FEATURE=vtune SCENARIO=minimal       # run one scenario
make test-all FEATURE=vtune                    # run all CI-safe scenarios
make clean                                     # remove dangling container images
```

---

## Publishing

You can trigger test and publishing manually via **Actions → Test & Publish Feature (manual) → Run workflow** in the GitHub UI. Select **Branch: main** and write **feature** name you want to publish in the input box.

The published feature reference will be:
```
ghcr.io/mitul93/devcontainer-features/<feature-id>:<version>
```

The version is read from [`devcontainer-feature.json`](src/nsight-systems-cli/devcontainer-feature.json). Before triggering the workflow, bump the version in that file or the publish will overwrite the existing tag.