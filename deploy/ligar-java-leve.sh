#!/usr/bin/env bash
set -euo pipefail
if [[ ${EUID} -ne 0 ]]; then
  echo "Use: sudo bash deploy/ligar-java-leve.sh"
  exit 1
fi
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dir="$root/minecraft-lite"
mkdir -p "$dir/data"
if [[ ! -e "$dir/.env" ]]; then
  cp "$dir/.env.exemplo" "$dir/.env"
  chmod 600 "$dir/.env"
  echo "Leia https://www.minecraft.net/en-us/eula e, se concordar, edite minecraft-lite/.env para EULA=TRUE."
  echo "Depois execute novamente sudo bash deploy/ligar-java-leve.sh"
  exit 0
fi
if ! grep -Eq '^EULA=TRUE([[:space:]]*)$' "$dir/.env"; then
  echo "A EULA ainda nao foi aceita. Leia-a e, se concordar, altere EULA=FALSE para EULA=TRUE em minecraft-lite/.env"
  exit 1
fi
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker ausente. Execute antes: sudo bash deploy/instalar-ubuntu.sh"
  exit 1
fi
cd "$dir"
docker compose config --quiet
docker compose up -d
docker compose ps
echo "Confira logs: cd minecraft-lite && sudo docker compose logs -f --tail=50 minecraft"
echo "Ao funcionar, compartilhe seu IP PUBLICO e porta TCP 25565; ou configure DuckDNS."
