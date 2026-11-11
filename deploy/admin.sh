#!/usr/bin/env bash
# Comandos de administração local. NÃO abra RCON ou Portainer publicamente.
set -euo pipefail
if [[ ${EUID} -ne 0 ]]; then echo "Execute com sudo"; exit 1; fi
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT/minecraft"
cmd="${1:-}"
case "$cmd" in
  status) docker compose ps ;;
  logs) docker compose logs -f --tail=80 minecraft ;;
  jogadores) docker exec rafael-minecraft rcon-cli list ;;
  iniciar) docker compose up -d ;;
  parar) docker compose down ;;
  reiniciar) docker compose restart minecraft ;;
  java)
    name="${2:-}"
    if [[ ! "$name" =~ ^[A-Za-z0-9_]{3,16}$ ]]; then echo "Nome Java inválido"; exit 1; fi
    docker exec rafael-minecraft rcon-cli whitelist add "$name" ;;
  bedrock)
    name="${2:-}"
    if [[ -z "$name" || ${#name} -gt 30 || "$name" =~ [[:cntrl:]] ]]; then echo "Gamertag Bedrock inválido"; exit 1; fi
    docker exec rafael-minecraft rcon-cli fwhitelist add "$name" ;;
  op)
    name="${2:-}"
    if [[ ! "$name" =~ ^[A-Za-z0-9_]{3,16}$ ]]; then echo "Nome Java inválido"; exit 1; fi
    docker exec rafael-minecraft rcon-cli op "$name" ;;
  console)
    shift
    if (( $# == 0 )); then echo "Informe comando"; exit 1; fi
    docker exec rafael-minecraft rcon-cli "$*" ;;
  backup) bash "$ROOT/deploy/backup.sh" ;;
  *) echo 'Comandos: status, logs, jogadores, iniciar, parar, reiniciar, java NOME, bedrock GAMERTAG, op NOME, console "COMANDO", backup'; exit 1 ;;
esac
