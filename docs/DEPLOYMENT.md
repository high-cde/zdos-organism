# Deployment ZDOS Organism

## Obiettivo

Questa guida descrive un deployment riproducibile e reversibile del runtime ZDOS Organism. Il percorso raccomandato separa sviluppo, staging e produzione e non richiede credenziali nel repository.

## Prerequisiti

Sono necessari Git, una toolchain Rust stabile e, per il cortex remoto, un endpoint HTTP compatibile con l’implementazione configurata in `cortex`. La toolchain di progetto è dichiarata in `rust-toolchain.toml`.

```bash
sudo apt-get install -y git build-essential pkg-config libssl-dev
```

## Installazione e verifica

```bash
git clone https://github.com/high-cde/zdos-organism.git
cd zdos-organism
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-targets --all-features
cargo build -p organism-bin --release
```

## Staging senza endpoint LLM

La modalità `--eval` è completamente locale. La modalità `--once` completa il ciclo anche quando il servizio LLM non è disponibile: registra l’errore del cortex e conserva lo stato di fitness nella directory configurata.

```bash
ZDOS_STATE_DIR=./var ZDOS_LLM_URL=http://127.0.0.1:8080/llm \
  cargo run -p organism-bin -- --once
```

## Produzione

In produzione è preferibile eseguire il binario con un utente dedicato, una directory di stato non condivisa e variabili d’ambiente gestite dal sistema operativo o da un secret manager. Non usare `root` salvo necessità documentata. Il servizio deve essere supervisionato da systemd, con riavvio controllato e log consultabili tramite journalctl.

Esempio di unità locale, da adattare ai percorsi reali:

```ini
[Unit]
Description=ZDOS Organism runtime
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=zdos
WorkingDirectory=/opt/zdos-organism
Environment=ZDOS_STATE_DIR=/var/lib/zdos-organism
Environment=ZDOS_LLM_URL=http://127.0.0.1:8080/llm
ExecStart=/opt/zdos-organism/target/release/organism-bin
Restart=on-failure
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=/var/lib/zdos-organism

[Install]
WantedBy=multi-user.target
```

## Rollback

Prima di ogni deployment registrare il commit installato. Il rollback consiste nel selezionare un tag o commit noto, ricompilare e riavviare il servizio. Non usare `git reset --hard` su una directory contenente stato operativo senza backup.

## Controlli post-deployment

Verificare che il servizio sia attivo, che lo stato venga scritto nella directory prevista e che i log non contengano segreti o token. In caso di endpoint LLM non raggiungibile, il processo deve restare osservabile e non deve entrare in un ciclo di retry incontrollato.
