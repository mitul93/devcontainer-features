# devcontainer feature NVIDIA nsight-systems-cli

A [devcontainer feature](https://containers.dev/implementors/features/) that installs [NVIDIA Nsight Sytems CLI](https://developer.nvidia.com/nsight-systems) via NVIDIA's official public APT repository.

## Usage

Add the feature to your `.devcontainer/devcontainer.json`. Example,

```json
{
  "features": {
    "ghcr.io/mitul93/devcontainer-features/nsight-systems-cli:latest": {
      "version" : "latest",
    }
  }
}
```

By default, the **latest published version** of this feature is used. Both of the following statements are equivalent.

```json
"ghcr.io/mitul93/devcontainer-features/nsight-systems-cli:latest": {}
"ghcr.io/mitul93/devcontainer-features/nsight-systems-cli": {}
```

To use a **specific feature version**, append the version tag to the feature reference:

```json
"ghcr.io/mitul93/devcontainer-features/nsight-systems-cli:1": {}
"ghcr.io/mitul93/devcontainer-features/nsight-systems-cli:1.1.0": {}
```

>[!NOTE]
All published feature versions are available at:
https://github.com/mitul93/devcontainer-features/pkgs/container/devcontainer-features%2Fnsight-systems-cli/versions

## Available Versions

To find all available versions, browse the `Packages` index for your platform at:

```
https://developer.download.nvidia.com/devtools/repos/<os>/<arch>/Packages
```

For example, for `ubuntu:24.04` on `x86_64`: [`https://developer.download.nvidia.com/devtools/repos/ubuntu2604/amd64/Packages`](https://developer.download.nvidia.com/devtools/repos/ubuntu2404/amd64/Packages)

Look for entries like:
```
Package: nsight-systems-cli-2020.2.1
Architecture: amd64
Version: 2020.2.1.71-64a8f98
...
...
Package: nsight-systems-cli-2026.3.1
Architecture: amd64
Version: 2026.3.1.157-263138048394v0
...
...
```
Use only the `YYYY.MAJOR.MINOR` part as the [version option](#options) — for example `2020.2.1`.

> [!WARNING]
> Do not use the full version string including the build hash (e.g. `2020.2.1.71-64a8f98`)

## Options

| Option | Type | Default | Description |
|---|---|---|---|
| `version` | string | `latest` | NVIDIA Nsight Systems CLI version to install (e.g. `2026.3.1`). Use `latest` for the newest available. |

## Examples

### Latest version

```json
{
  "features": {
    "ghcr.io/mitul93/devcontainer-features/nsight-systems-cli:latest": {
      "version": "latest"
    }
  }
}
```
### Pinned version

```json
{
  "features": {
    "ghcr.io/mitul93/devcontainer-features/nsight-systems-cli:latest": {
      "version": "2026.3.1"
    }
  }
}
```

## Capabilities required

TODO

## Verify the installation:

```bash
nsys --version
```

## Limitations

- Only works with Debian or Ubuntu based container (uses `apt`)
- Container must be run as `root` during feature installation (standard for all devcontainer features)

## License

This feature is licensed under the terms in [LICENSE](LICENSE).