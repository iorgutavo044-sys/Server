#!/usr/bin/env bash
# Inicia serviços após aceite explícito da EULA e tenta configurar o Geyser.
set -euo pipefail
if [[ ${EUID} -ne 0 ]]; then echo "Execute: sudo bash deploy/ligar.sh"; exit 1; fi
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT/minecraft"
if [[ ! -f .env ]]; then echo "Falta .env. Execute primeiro o instalador."; exit 1; fi
if ! grep -Eqi '^EULA=TRUE[[:space:]]*$' .env; then
  echo "Leia https://www.minecraft.net/en-us/eula e, se concordar, altere EULA=FALSE para TRUE em minecraft/.env."
  exit 1
fi
docker compose up -d
CONFIG="$ROOT/minecraft/data/plugins/Geyser-Spigot/config.yml"
echo "Aguardando a primeira inicialização..."
for i in $(seq 1 90); do
  if [[ -s "$CONFIG" ]]; then break; fi
  sleep 3
done
if [[ ! -s "$CONFIG" ]]; then
  echo "Geyser não criou config.yml. Confira: sudo docker logs --tail 100 rafael-minecraft"
  exit 1
fi
python3 "$ROOT/deploy/ajustar-geyser.py" "$CONFIG"
docker compose restart minecraft
echo "Pronto para verificar: sudo bash deploy/admin.sh logs"
echo "Libere na nuvem TCP 25565, TCP 19132 e UDP 19132. Painel Portainer somente via SSH."
