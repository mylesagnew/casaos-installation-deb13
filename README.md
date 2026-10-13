# CasaOS installer for Debian 13

[![ShellCheck](https://github.com/mylesagnew/casaos-installation-deb13/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/mylesagnew/casaos-installation-deb13/actions/workflows/shellcheck.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Debian 13](https://img.shields.io/badge/Debian-13%20trixie-A81D33?logo=debian&logoColor=white)

A single Bash script that prepares a fresh **Debian 13 (trixie)** host and installs [CasaOS](https://casaos.io), a web-based home-server and app dashboard, with Docker Engine from Docker's official apt repository.

It's for homelab and self-hosting boxes: a fresh VM, a mini-PC, or a spare machine.

---

## What it does

1. Checks that it is running as root and on Debian 13 (exits otherwise).
2. `apt update && apt upgrade -y`, then installs `curl`, `wget` and `tar`.
3. **Removes** distro Docker packages (`docker.io`, `docker-engine`, `containerd`, `runc`) if present.
4. Adds Docker's signed apt repo for trixie and installs `docker-ce`, the CLI, containerd, and the buildx and compose plugins.
5. Enables Docker and verifies it with a `hello-world` container.
6. Runs the official CasaOS installer (`curl -fsSL https://get.casaos.io | bash`).
7. Enables the `casaos` service and prints the URL to open.

## Requirements

- Debian 13 (trixie), amd64 or arm64
- Root or `sudo`
- Outbound internet access
- Port 80 free (CasaOS serves its UI there)

## Install

```bash
git clone https://github.com/mylesagnew/casaos-installation-deb13.git
cd casaos-installation-deb13
less install_casaos_debian13.sh   # read it first; it runs as root
sudo bash install_casaos_debian13.sh
```

When it finishes, open `http://<host-ip>` and complete the CasaOS setup wizard.

**Example output (illustrative, abridged):**

```
[2026-08-12 10:02:11] Updating system packages...
[2026-08-12 10:03:40] Docker installed successfully.
[2026-08-12 10:03:44] Docker verified with hello-world container.
[2026-08-12 10:05:02] CasaOS service is running.
[2026-08-12 10:05:02] Access CasaOS at: http://192.168.1.50:80
```

## Update

```bash
sudo casaos-upgrade
```

## Uninstall / rollback

CasaOS ships its own uninstaller:

```bash
sudo casaos-uninstall
```

That removes CasaOS but leaves Docker. To remove Docker as well (this **deletes all containers, images and volumes**):

```bash
sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo rm -rf /var/lib/docker /var/lib/containerd
sudo rm -f /etc/apt/sources.list.d/docker.list /etc/apt/keyrings/docker.asc
```

## Safety notes

- **Use a dedicated host.** The script upgrades every package and removes any existing distro-packaged Docker.
- **It pipes a remote script into `bash` as root** (`get.casaos.io`). That is CasaOS's official install method, but review it first if that matters to you: `curl -fsSL https://get.casaos.io -o casaos-install.sh`.
- **The CasaOS UI is plain HTTP on port 80** and manages Docker, which is effectively root on the host. Keep it on your LAN or behind a VPN, and don't port-forward it to the internet.
- Report problems with this script privately via [GitHub security advisories](https://github.com/mylesagnew/casaos-installation-deb13/security/advisories/new). Report CasaOS issues upstream at [IceWhaleTech/CasaOS](https://github.com/IceWhaleTech/CasaOS).

## License

[MIT](LICENSE) © 2025 Myles Agnew. CasaOS and Docker are separate projects with their own licenses.
