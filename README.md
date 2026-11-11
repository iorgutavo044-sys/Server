# 🟩 RAFAEL HOST — Minecraft Java + Bedrock de verdade

**Este repositório tem duas partes separadas:**
- `docs/`: site público e gratuito para o **GitHub Pages**.
- `minecraft/` e `deploy/`: **servidor real Minecraft Paper** numa máquina **Ubuntu na nuvem**, com Geyser/Floodgate para Bedrock e painel Portainer privado.

**Importante:** GitHub Pages não hospeda o jogo. É necessário ter uma máquina na nuvem (ex.: Oracle Cloud Always Free, se disponível). Essa modalidade pode ficar sem capacidade, e não garante uptime ou instância permanente. O Minecraft não foi ligado automaticamente apenas porque os arquivos foram publicados aqui.

## PASSO 1 — Publicar o site

Este repositório se chama **Server**, na conta **iorgutavo044-sys**.

1. Abra **Settings → Pages** no repositório.
2. Em **Build and deployment**, em **Source**, selecione **GitHub Actions** e salve.
3. O arquivo `.github/workflows/publicar-site.yml` já está no repositório e foi preparado para publicar automaticamente a pasta `/docs` depois dessa ativação.
4. O endereço esperado será **https://iorgutavo044-sys.github.io/Server/** se o GitHub Pages estiver habilitado e a implantação for concluída.

O site ficará no ar, porém mostrará **IP ainda não configurado** até que você crie a máquina Minecraft real. Quando tiver o IP, edite `docs/config.js`, altere `host` e faça commit.

## PASSO 2 — Criar a máquina para o jogo (com ajuda de responsável)

Uma opção é criar uma instância Ubuntu 24.04 ARM64 na **Oracle Cloud**. Escolha recursos marcados **Always Free**, como a `VM.Standard.A1.Flex` caso esteja disponível, com IPv4 público e uma chave privada SSH. **Não selecione máquina paga.** O cadastro pode exigir cartão. Guarde a chave privada SSH em segredo.

Na configuração de rede da Oracle (VCN/Security List ou NSG), libere somente as portas necessárias do jogo:
- **TCP 25565** (Java).
- **TCP 19132 e UDP 19132** (Bedrock com NetherNet).
- **Não libere 9443** (painel) nem 25575 (RCON) publicamente.
- Restrinja **SSH TCP 22** aos IPs autorizados sempre que possível.

## PASSO 3 — Entrar no Ubuntu

Abra PowerShell no Windows e substitua os exemplos:

```powershell
ssh -i "C:\CAMINHO\DA\SUA_CHAVE.key" ubuntu@IP_PUBLICO
```

No terminal Ubuntu que abrir, execute uma linha por vez:

```bash
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/iorgutavo044-sys/Server.git
cd Server
sudo bash deploy/instalar-ubuntu.sh
```

O instalador usa o repositório oficial Docker para Ubuntu, instala Docker/Compose e cria `minecraft/.env` a partir do modelo. Não aceita a EULA por você.

## PASSO 4 — Ligar o Minecraft

Leia os [termos oficiais Minecraft](https://www.minecraft.net/en-us/eula). Se você **concordar**, execute:

```bash
sudo nano minecraft/.env
```

Altere **EULA=FALSE** para **EULA=TRUE**. No Nano, salve com **Ctrl+O**, Enter e saia com **Ctrl+X**. Então execute:

```bash
sudo bash deploy/ligar.sh
sudo bash deploy/admin.sh logs
```

Na primeira vez, o Docker baixa a imagem Paper e os plugins Geyser e Floodgate. Quando o console mostrar **Done**, o servidor deve estar inicializado. Pressione **Ctrl+C** para sair da visualização de logs (isso não desliga o servidor).

Se o script relatar problema no Geyser, confira os logs e a versão instalada: projetos atualizam seu formato de configuração. O script tenta habilitar Floodgate e a conexão Bedrock por NetherNet.

## PASSO 5 — Liberar acesso dos jogadores

A whitelist está ligada por segurança. No Ubuntu:

```bash
sudo bash deploy/admin.sh java SEU_NOME_JAVA
sudo bash deploy/admin.sh bedrock GAMERTAG_BEDROCK
sudo bash deploy/admin.sh jogadores
```

- **Java original:** `IP_PUBLICO:25565`.
- **Bedrock:** IP `IP_PUBLICO` com porta **19132**.

Se não conectar, confirme o estado do Docker, liberação das portas TCP/UDP na Oracle e o firewall local Ubuntu (`sudo ufw status`). Se o UFW estiver ativo, você pode liberar `sudo ufw allow 25565/tcp`, `sudo ufw allow 19132/tcp` e `sudo ufw allow 19132/udp`. **Não ative ou reconfigure o UFW sem garantir SSH**; você pode perder o acesso.

Java não original não está habilitado: o servidor mantém a verificação oficial de identidades Java; Bedrock entra via Floodgate. Desativar autenticação Java traz risco de falsificação de contas e exige planejamento adicional.

## PASSO 6 — Abrir o painel real no Windows

Mantenha a máquina Ubuntu ligada. Num **segundo PowerShell** do Windows, abra o túnel:

```powershell
ssh -i "C:\CAMINHO\DA\SUA_CHAVE.key" -L 9443:127.0.0.1:9443 ubuntu@IP_PUBLICO
```

Deixe essa janela aberta e acesse **https://localhost:9443** no Windows. O certificado local pode mostrar um aviso; confira se é mesmo seu túnel. Crie uma **senha de administrador forte** no Portainer. Em **Containers**, gerencie `rafael-minecraft`. **Nunca publique essa porta para a internet.**

## Comandos de administração

```bash
cd ~/Server
sudo bash deploy/admin.sh status
sudo bash deploy/admin.sh logs
sudo bash deploy/admin.sh jogadores
sudo bash deploy/admin.sh reiniciar
sudo bash deploy/admin.sh backup
sudo bash deploy/admin.sh parar
sudo bash deploy/admin.sh iniciar
```

Os backups locais ficam em `backups/`, que **não deve ser enviado ao GitHub**. Guarde cópias criptografadas fora da máquina para não perder o mundo. Os backups podem conter chaves e dados privados do servidor.

## PASSO 7 — Colocar o IP real no site

Depois de conseguir entrar no Minecraft, edite [docs/config.js](docs/config.js) no GitHub:

```js
host: "IP_PUBLICO_DA_SUA_MAQUINA",
```

O GitHub Pages mostrará o endereço e consultará o status Java por um serviço externo. Esse status pode demorar, falhar ou não refletir imediatamente o estado real.

## Minigames

**BedWars, SkyWars e Parkour estão planejados, não instalados.** Depois de testar Java e Bedrock, será preciso baixar plugins compatíveis com a versão do Paper, criar mapas, configurar lobby, proteção e backups. Para vários servidores simultâneos, considere os recursos e limites da máquina.

### Documentação oficial

- [GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
- [Docker Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server)
- [GeyserMC](https://geysermc.org/wiki/geyser/setup/)
- [Floodgate](https://geysermc.org/wiki/floodgate/setup/)
- [Portainer](https://docs.portainer.io/start/install-ce/server/docker/linux)
- [Oracle Always Free](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)

Projeto independente, não afiliado à Mojang Studios ou Microsoft. Tenha a ajuda de um responsável para contas, segurança e cobrança.
