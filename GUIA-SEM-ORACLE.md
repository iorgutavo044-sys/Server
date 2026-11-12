# Rafael Host — alternativas à Oracle + endereço personalizado

**Situação atual:** o Minecraft Java já funciona no PC Windows. Para continuar ligado com o PC **desligado**, precisa de uma máquina que permaneça ligada em outro lugar. GitHub, Playit, VPN e DuckDNS **não executam** o Minecraft sozinhos.

## Alternativas reais à Oracle
- **Google Cloud Free Tier:** oferece a VM `e2-micro` (1 GB de RAM) em regiões específicas, mas não é boa para minigames. Exige conta de faturamento e pode cobrar IP público, tráfego e extras. Não configure nada sem um responsável verificar os custos e alertas.
- **Serviços de Minecraft com plano gratuito** (ex.: Apect): facilitam instalar Paper e compartilhar um endereço, mas não são uma **VPS com controle completo de sistema operacional**; limite de RAM e garantias de disponibilidade devem ser conferidos. São uma alternativa prática, não exatamente a própria infraestrutura de host.
- **VPS de pequenos provedores que anunciam 24/7 sem cartão:** cuidado. Nem sempre é possível confirmar se a oferta é real, persistente ou segura para armazenar mundos. Faça backup antes de enviar qualquer arquivo, nunca envie documento ou cartão sem um adulto responsável.

## Instalador da Rafael Host leve, para qualquer VPS Ubuntu compatível

**Necessário:** uma VPS Ubuntu real que você já tenha criado e possa acessar por SSH com permissão adequada, internet e pelo menos cerca de 2 GB de RAM (desempenho não garantido). Peça ajuda a um responsável para o cadastro e a proteção da conta.

No terminal da VPS:

```bash
sudo apt update
sudo apt install -y git
git clone https://github.com/iorgutavo044-sys/Server.git
cd Server
sudo bash deploy/instalar-ubuntu.sh
sudo bash deploy/ligar-java-leve.sh
```

A primeira execução prepara `minecraft-lite/.env`. Leia [a EULA oficial](https://www.minecraft.net/en-us/eula). **Somente se concordar**, altere `EULA=FALSE` para `EULA=TRUE`:

```bash
nano minecraft-lite/.env
sudo bash deploy/ligar-java-leve.sh
```

O contêiner usa `restart: always`, isto é, volta depois de falhas e reinicializações do sistema com Docker ativo. Não consegue voltar sozinho se a própria VPS for removida ou desligada pelo provedor.

No firewall de sua VPS, autorize **TCP 25565** para jogadores; restrinja SSH e nunca publique portas administrativas.

## Nome personalizado grátis para o Minecraft Java

Se sua VPS tiver **IPv4 público realmente acessível** e a porta 25565 TCP estiver liberada, poderá usar [DuckDNS](https://www.duckdns.org/) gratuitamente. Com ajuda de um responsável:
1. Entre no DuckDNS e crie um subdomínio, como `rafaelgames.duckdns.org` (**somente se estiver disponível**).
2. Configure o IP de destino para o **IPv4 público da VPS**, não o IP privado 192.168.x.x e não `127.0.0.1`.
3. No Minecraft Java, entre usando `rafaelgames.duckdns.org` (a porta 25565 é padrão).
4. Atualize o DNS se o IP público da máquina mudar. O token do DuckDNS é **secreto**; nunca publique no GitHub.

Esse nome **não cria IP público nem substitui a VPS**. Se estiver usando apenas Playit, use o endereço de túnel já fornecido; o suporte oficial do Playit a domínio externo é recurso Premium e pode requerer outras configurações.

## Se você só tem seu Windows

A Rafael Host 3.0 instalada no Windows continua útil. Para o IP público, use o endereço do Playit; para 24h com o PC desligado, primeiro será necessário conseguir uma máquina na nuvem. Não use GitHub Actions ou Codespaces como suposta VPS 24/7: eles são temporários.

Links: [Google Cloud Free Tier](https://docs.cloud.google.com/free/docs/free-cloud-features?hl=pt-br) · [Google Cloud IP externo](https://cloud.google.com/vpc/pricing?hl=pt-BR) · [DuckDNS](https://www.duckdns.org/) · [Playit](https://playit.gg/)
