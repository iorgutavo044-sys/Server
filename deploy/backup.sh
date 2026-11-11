#!/usr/bin/env bash
set -euo pipefail
if [[ ${EUID} -ne 0 ]]; then echo "Execute com sudo"; exit 1; fi
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$ROOT/backups"
if docker inspect -f '{{.State.Running}}' rafael-minecraft 2>/dev/null | grep -qx true; then
  docker exec rafael-minecraft rcon-cli 'save-all flush'
fi
FILE="$ROOT/backups/minecraft-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf "$FILE" -C "$ROOT/minecraft" data
chmod 600 "$FILE"
echo "Backup local criado: $FILE"
echo "Não publique backups no GitHub (contêm dados do mundo e chave Floodgate)."
