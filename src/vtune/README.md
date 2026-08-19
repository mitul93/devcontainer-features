# devcontainer-feature-vtune

A [devcontainer feature](https://containers.dev/implementors/features/) that installs [Intel VTune Profiler](https://www.intel.com/content/www/us/en/developer/tools/oneapi/vtune-profiler.html) via Intel's official public APT repository.

> [!IMPORTANT]
> `vtune-gui` command will not run inside the devcontainer and it is not supported by `devcontainer-feature-vtune`. See [how to run vtune as backend in a container](#running-the-vtune-backend-in-a-container) for instructions on running VTune as a backend.

## Usage

Add the feature to your `.devcontainer/devcontainer.json`. Example,

```json
{
  "features": {
    "ghcr.io/mitul93/devcontainer-features/vtune:latest": {
      "version" : "latest",
      "self_check": false
    }
  }
}
```

## Finding Available Versions

To find the available VTune versions, use this devcontainer feature with any version (use `latest` if you're unsure which version to use), then run the following command in the devcontainer terminal:

```shell
devcontainer@74a5ce9b6876:/ apt-get update

devcontainer@74a5ce9b6876:/ apt-cache policy intel-oneapi-vtune
intel-oneapi-vtune:
  Installed: 2025.9.0-10
  Candidate: 2025.9.0-10
  Version table:
 *** 2025.9.0-10 500
        500 https://apt.repos.intel.com/oneapi all/main amd64 Packages
        100 /var/lib/dpkg/status
     2025.8.1-5 500
        500 https://apt.repos.intel.com/oneapi all/main amd64 Packages
...
```

## Options

| Option | Type | Default | Description |
|---|---|---|---|
| `version` | string | `latest` | VTune version to install (e.g. `2025.9.0-10`). Use `latest` for the newest available. |
| `self_check` | boolean | `false` | Run `vtune-self-checker.sh` after install to validate the setup. |


## Examples

### latest version

```json
{
  "features": {
    "ghcr.io/mitul93/devcontainer-features/vtune:latest": {
      "version": "latest"
    }
  }
}
```
### Pinned version with all options

```json
{
  "features": {
    "ghcr.io/mitul93/devcontainer-features/vtune:latest": {
      "version": "2025.9.0-10",
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

## Running the VTune Backend in a Container

Launching the VTune GUI directly inside the container requires installing a large number of apt packages, which may not remain compatible across subsequent releases; running the VTune backend in the container is a much easier and more reliable solution.

The following command starts the VTune backend inside the container. You will need to port-forward the selected port to access the VTune web UI from your host. You can choose **any available port** number instead of 7788.

```shell
devcontainer@74a5ce9b6876:/ vtune-backend --allow-remote-ui --web-port=7788 --enable-server-profiling --usage-statistics-opt-out
```

> [!NOTE]  
> The first time you connect, VTune will prompt you to set a password. If you want to disable password authentication, you can change the authentication type to anonymous.

> [!CAUTION]
> Security warning: Disabling authentication allows anyone who can access the forwarded port to connect to the VTune backend. Only use this in a trusted environment. Do this only if you understand the security implications.

```shell
devcontainer@74a5ce9b6876:/ whereis vtune
    vtune: /opt/intel/oneapi/vtune/2025.9/bin64/vtune

devcontainer@74a5ce9b6876:/ sed -i 's/type: passphrase/type: anonymous/' \
    /opt/intel/oneapi/vtune/2025.9/backend/config.yml

devcontainer@74a5ce9b6876:/ vtune-backend --allow-remote-ui --web-port=7788 --enable-server-profiling --usage-statistics-opt-out
```

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

## Reference

- https://www.intel.com/content/www/us/en/docs/vtune-profiler/installation-guide/2026-0/package-managers.html
- https://www.intel.com/content/www/us/en/docs/vtune-profiler/user-guide/2023-0/run-from-container.html
- https://www.intel.com/content/www/us/en/docs/vtune-profiler/user-guide/2026-1/overview.html
- https://www.intel.com/content/www/us/en/docs/vtune-profiler/cookbook/2025-0/overview.html
- https://www.intel.com/content/www/us/en/docs/vtune-profiler/tutorial-common-bottlenecks-linux/2025-0/overview.html


## License

This feature is licensed under the terms in [LICENSE](LICENSE).

Intel VTune Profiler is subject to the
[Intel End User License Agreement](https://www.intel.com/content/www/us/en/developer/articles/license/end-user-license-agreement.html).
