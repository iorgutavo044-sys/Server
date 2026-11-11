# 🟩 RAFAEL HOST — Minecraft Java + Bedrock de verdade

**Projeto para um Minecraft público e painel de administração privado:**
- `minecraft/` e `deploy/`: **servidor Minecraft Paper** numa máquina **Ubuntu na nuvem**, com Geyser/Floodgate para Bedrock e painel Portainer privado.
- `docs/`: site opcional **não publicado**; GitHub Pages não é necessário.

**Importante:** GitHub Pages não hospeda o jogo. É necessário ter uma máquina na nuvem (ex.: Oracle Cloud Always Free, se disponível). Essa modalidade pode ficar sem capacidade, e não garante uptime ou instância permanente. O Minecraft não foi ligado automaticamente apenas porque os arquivos foram publicados aqui.

## O site não precisa ficar público

A **Rafael Host** será uma rede de Minecraft **aberta a todos os jogadores**, mas o painel de administração será **privado**, acessível por túnel SSH. Você não precisa configurar GitHub Pages. A publicação automática do site foi desativada; os arquivos de `docs/` são apenas um modelo opcional, sem necessidade de publicação.

O **GitHub guarda o código**, não executa o Minecraft. Para funcionar 24 horas sem ligar o PC, precisamos de uma máquina externa. Ainda não há uma instância na nuvem conectada ou servidor Minecraft comprovadamente online.

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

## PASSO 5 — Servidor público: qualquer jogador pode entrar

A whitelist do Minecraft está DESLIGADA por padrão: o servidor é público para qualquer jogador Java original ou Bedrock via Geyser/Floodgate. A autenticação Java permanece ligada. Para conceder administração ao seu amigo (não compartilhe sua senha do painel), use no Ubuntu:

```bash
sudo bash deploy/admin.sh op NOME_JAVA_DO_SEU_AMIGO
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

## PASSO 7 — Convidar jogadores

Compartilhe apenas o IP público do Minecraft (Java: porta 25565; Bedrock: porta 19132), **nunca** credenciais de SSH ou do painel.

Para dar poderes de operador ao amigo que ajuda no servidor, use `sudo bash deploy/admin.sh op NOME_JAVA`; para remover, `sudo bash deploy/admin.sh console "deop NOME_JAVA"`. O acesso de administrador total é poderoso: considere um plugin de permissões para dar somente os comandos necessários. Não deixe todos os jogadores com OP.

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

## Acesso público e administração

O Minecraft está configurado para aceitar jogadores em geral (`ENABLE_WHITELIST=FALSE`, `ENFORCE_WHITELIST=FALSE`). **O painel Portainer continua privado**, via túnel SSH; não compartilhe senha SSH, chave privada, senha do painel ou token. O comando `op NOME` concede poderes amplos no jogo: só faça isso depois de conhecer e confiar na pessoa. Para revogar, rode `sudo bash deploy/admin.sh console "deop NOME"`. Plugins de permissões como LuckPerms podem dar funções limitadas a moderadores. Se a máquina já estiver executando uma configuração anterior, faça backup e recrie os contêineres com `cd minecraft && sudo docker compose up -d --force-recreate minecraft` para aplicar a whitelist desativada. Minigames ainda precisam ser configurados.

## Controlar Minecraft pelo GitHub (botões)

O arquivo [`.github/workflows/controlar-minecraft.yml`](.github/workflows/controlar-minecraft.yml) adiciona em **Actions → Controlar Rafael Host → Run workflow** as opções **iniciar**, **reiniciar**, **status** e **parar**.

**Isso NÃO executa Minecraft nos servidores do GitHub.** Cada botão abre uma conexão SSH para **sua própria máquina Linux** já criada e preparada com `deploy/instalar-ubuntu.sh` e `deploy/ligar.sh`. Nenhum botão funcionará antes de existir a máquina.

O proprietário responsável pela conta deve configurar, em **Settings → Secrets and variables → Actions**, estes **segredos de repositório** (nunca adicionar no código):
- `RAFAEL_SSH_HOST`: IP ou DNS da máquina.
- `RAFAEL_SSH_USER`: usuário Linux, normalmente `ubuntu`.
- `RAFAEL_SSH_PRIVATE_KEY`: chave SSH privada dedicada para essa automação.
- `RAFAEL_SSH_KNOWN_HOSTS`: linha de host-key SSH validada por impressão digital previamente conferida com a máquina real. **Não copie uma chave não verificada.**

É necessário preparar autenticação SSH por chave, acesso SSH de rede e capacidade de executar `sudo -n bash deploy/admin.sh` nessa máquina. **Não desative checagem da chave do host e não abra Portainer/RCON na internet.** Uma chave específica com privilégios limitados é preferível à chave pessoal de administração. O workflow executa somente comandos predefinidos, sem aceitar comandos livres.

Em `minecraft/docker-compose.yml`, `restart: always` faz o contêiner do Minecraft **reiniciar se encerrar inesperadamente** e voltar após o Docker reiniciar. **Não mantém o servidor vivo se a VPS for desligada, perdida ou recolhida pelo provedor.** Para aplicar essa alteração numa instalação anterior, no Ubuntu execute: `cd ~/Server && git pull --ff-only && cd minecraft && sudo docker compose up -d --force-recreate minecraft`.

**Atenção:** o código está no GitHub, mas nenhuma VPS real ou chave foi configurada por esta automação; não é possível garantir 24 horas grátis apenas pelo GitHub.

## Playit.gg + computador na nuvem (opcional)

O Playit **não executa o Minecraft** e não mantém uma VPS desligada ligada. Ele oferece endereços de conexão para os jogadores e dispensa abrir portas públicas para o jogo. A opção Playit já foi adicionada ao `minecraft/docker-compose.yml` como perfil opcional.

Depois de instalar a Rafael Host numa **máquina Ubuntu ligada na nuvem** e iniciar o Minecraft, crie sua conta Playit em [playit.gg](https://playit.gg/) e gere uma chave de agente em [Playit para Docker](https://playit.gg/account/setup/wizard/new-account/docker/docker-name). **Nunca compartilhe a chave e nunca publique no GitHub.**

No terminal SSH da máquina Ubuntu, a partir do diretório `~/Server`:

```bash
cd ~/Server
umask 077
nano minecraft/playit-secret
```

Cole **apenas** a chave secreta do agente no arquivo, salve, e então execute:

```bash
cd ~/Server/minecraft
sudo docker compose --profile playit up -d
sudo docker logs --tail=80 rafael-playit
```

No painel do Playit, crie os túneis necessários: **Minecraft Java** com destino `127.0.0.1:25565`, e, se for usar Bedrock, o protocolo **Bedrock NetherNet** com destino `127.0.0.1:19132`. Escolha o tipo de túnel apropriado que o painel oferecer; o protocolo Bedrock pode ter exigências diferentes de RakNet tradicional. **Geyser/Floodgate também devem estar funcionando no servidor.** Compartilhe com os jogadores os endereços gerados pelo Playit (não as chaves).

O Playit usa rede do host nesse Compose. As portas do Minecraft já estão mapeadas no host local. Não é necessário expor o painel Portainer na internet. Para desligar o Playit sem desligar o Minecraft, execute `sudo docker stop rafael-playit` (com a política `restart: always`, ele poderá voltar ao reiniciar Docker; para removê-lo do Compose, use o perfil e `docker compose --profile playit stop playit`).

**Importante:** se a máquina na nuvem ficar desligada, suspensa ou for recuperada pelo provedor gratuito, Playit e Minecraft ficarão offline. O GitHub não substitui o computador na nuvem.
