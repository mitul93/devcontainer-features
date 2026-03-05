# devcontainer-feature-vtune

A [devcontainer feature](https://containers.dev/implementors/features/) that installs [Intel VTune Profiler](https://www.intel.com/content/www/us/en/developer/tools/oneapi/vtune-profiler.html) via Intel's official public APT repository.

## Usage

Add the feature to your `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/mitul93/devcontainer-feature-vtune/vtune:1": {}
  }
}
```

## Options

| Option | Type | Default | Description |
|---|---|---|---|
| `version` | string | `latest` | VTune version to install (e.g. `2025.9.0`). Use `latest` for the newest available. |
| `gui` | boolean | `false` | Install VTune GUI components. Requires a display server forwarded into the container. |
| `sampling_drivers` | boolean | `false` | Install hardware PMU sampling drivers for accurate profiling. Requires host-level configuration (see below). |
| `self_check` | boolean | `false` | Run `vtune-self-checker.sh` after install to validate the setup. |

## Examples

### Minimal — CLI only

```json
{
  "features": {
    "ghcr.io/mitul93/devcontainer-feature-vtune/vtune:1": {
      "version": "latest"
    }
  }
}
```

### With GUI

```json
{
  "features": {
    "ghcr.io/mitul93/devcontainer-feature-vtune/vtune:1": {
      "gui": true
    }
  }
}
```

Also add to your `devcontainer.json`:

```json
"containerEnv": {
  "DISPLAY": "${localEnv:DISPLAY}"
},
"runArgs": ["--device=/dev/dri"]
```

### Pinned version with all options

```json
{
  "features": {
    "ghcr.io/mitul93/devcontainer-feature-vtune/vtune:1": {
      "version": "2025.9.0",
      "gui": true,
      "sampling_drivers": true,
      "self_check": true
    }
  }
}
```

## Capabilities required

Depending on the options you enable, add the following to your `devcontainer.json`:

```json
"capAdd": ["SYS_PTRACE", "SYS_ADMIN"],
"securityOpt": ["seccomp=unconfined"]
```

| Capability | Required for |
|---|---|
| `SYS_PTRACE` | Basic VTune profiling |
| `SYS_ADMIN` | Hardware sampling drivers (`sampling_drivers=true`) |
| `seccomp=unconfined` | VTune system call tracing |

## Sampling drivers — host configuration

When `sampling_drivers=true`, VTune uses the CPU Performance Monitoring Unit (PMU)
for hardware event-based sampling, which is significantly more accurate than
software-based collection.

This requires setting `perf_event_paranoid` on the **host** (not inside the container,
as containers share the host kernel):

```bash
# Temporary (until next reboot)
sudo sysctl -w kernel.perf_event_paranoid=1

# Permanent
echo 'kernel.perf_event_paranoid=1' | sudo tee /etc/sysctl.d/99-perf.conf
sudo sysctl --system
```

| `perf_event_paranoid` value | Effect |
|---|---|
| `3` | Disallow all perf profiling (some distros default) |
| `2` | Allow only user-space profiling |
| `1` | Allow kernel profiling (recommended for VTune) |
| `0` | Allow CPU event sampling |
| `-1` | No restrictions |

## Environment

VTune environment variables are sourced automatically for all users via
`/etc/profile.d/vtune.sh`. To activate manually in a running shell:

```bash
source /opt/intel/oneapi/vtune/latest/env/vars.sh
```

Verify the installation:

```bash
vtune --version
```

## Requirements

- Debian or Ubuntu based container (uses `apt`)
- Container must be run as `root` during feature installation (standard for all devcontainer features)

## License

This feature is licensed under the terms in [LICENSE](LICENSE).

Intel VTune Profiler is subject to the
[Intel End User License Agreement](https://www.intel.com/content/www/us/en/developer/articles/license/end-user-license-agreement.html).