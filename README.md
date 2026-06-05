# Distroless smartctl container

Bare-bones distroless smartctl container image.

## Building

| Build Arg | Description |
|---|---|
| `GCC_VERSION` | Version of GCC to use
| `SMARTCTL_VERSION` | Version of smartmontools to use

Build container using build-args from versions.yaml:

```bash
docker build -t smartctl $(yq -r 'to_entries | .[] | "--build-arg \(.key | ascii_upcase)_VERSION=\(.value)"' versions.yaml) -f Containerfile .
```

## License

Repository contents (e.g., `Containerfile`, build scripts, and configuration) are licensed under the **MIT License**.

Software included in built container images (such as **smartmontools**, **gcc**, etc...) are provided under their respective upstream licenses and are not covered by the MIT license for this repository.

## Acknowledgements

This project depends on several upstream components that provide essential runtime libraries, toolchains, and platform capabilities:

- **Smartmontools** – Control and Monitor Utility for SMART Disks.  
  https://smartmontools.org

- **GCC** - GNU Compiler Collection.  
  https://gcc.gnu.org
