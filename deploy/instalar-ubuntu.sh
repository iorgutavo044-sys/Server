#!/usr/bin/env bash
# Instala Docker e prepara a Rafael Host em Ubuntu amd64/arm64.
set -euo pipefail
if [[ ${EUID} -ne 0 ]]; then echo "Execute: sudo bash deploy/instalar-ubuntu.sh"; exit 1; fi
. /etc/os-release
if [[ "${ID:-}" != ubuntu ]]; then echo "Este instalador requer Ubuntu"; exit 1; fi
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
apt-get update
apt-get install -y ca-certificates curl git python3
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-${VERSION_CODENAME}}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
mkdir -p "$ROOT/minecraft/data" "$ROOT/minecraft/portainer-data" "$ROOT/backups"
if [[ ! -e "$ROOT/minecraft/.env" ]]; then cp "$ROOT/minecraft/.env.exemplo" "$ROOT/minecraft/.env"; fi
chmod 600 "$ROOT/minecraft/.env"
(cd "$ROOT/minecraft" && docker compose config --quiet)
echo "Docker instalado. Leia https://www.minecraft.net/en-us/eula"
echo "Se concordar, abra: sudo nano minecraft/.env"
echo "Depois execute: sudo bash deploy/ligar.sh"
echo "Atenção: portas da Oracle devem ser abertas separadamente (25565/TCP e 19132/TCP+UDP)."
