# ZDOS Organism

ZDOS Organism è un runtime Rust sperimentale, organizzato come workspace Cargo, per modellare un organismo digitale modulare. Il repository comprende componenti per il core, il cortex, la macchina virtuale ZDOS, il linguaggio ZLang, il binario eseguibile e `memzdos`.

## Funzionalità disponibili

Il binario `organism-bin` offre due modalità principali:

- `--eval <programma>` esegue una stringa ZLang e stampa il risultato in JSON.
- `--once` esegue un singolo ciclo dell’organismo. Il ciclo aggiorna i segnali e il feedback, calcola un valore di fitness e lo scrive in `fitness.txt` nella directory di stato. Interroga inoltre il cortex e registra l’eventuale errore senza interrompere il ciclo.

La modalità di ciclo usa le funzioni definite in `organism-bin/src/bio_sensors.rs`; nell’implementazione corrente queste restituiscono valori costanti, non misure effettive dell’hardware o della rete.

Il client HTTP del cortex usa la variabile `ZDOS_LLM_URL`. Se non è impostata, l’endpoint predefinito è `http://127.0.0.1:8080/llm`. La directory per i dati locali è controllata da `ZDOS_STATE_DIR` e, per impostazione predefinita, è `./var`.

## Prerequisiti

Il progetto dichiara Rust `stable` in `rust-toolchain.toml` e usa Cargo. Su Debian o Ubuntu, la guida di deployment indica anche Git e questi pacchetti di sistema:

```bash
sudo apt-get install -y git build-essential pkg-config libssl-dev
```

## Installazione e compilazione

```bash
git clone https://github.com/high-cde/zdos-organism.git
cd zdos-organism
cargo build -p organism-bin --release
```

## Uso

Mostra le opzioni CLI:

```bash
cargo run -p organism-bin -- --help
```

Esegui una semplice espressione ZLang:

```bash
cargo run -p organism-bin -- --eval '+ 2 3'
```

Esegui un ciclo e specifica directory di stato ed endpoint LLM:

```bash
ZDOS_STATE_DIR=./var \
ZDOS_LLM_URL=http://127.0.0.1:8080/llm \
  cargo run -p organism-bin -- --once
```

Le variabili d’ambiente sono facoltative: se omesse, il programma usa i valori predefiniti descritti sopra. `--version` stampa la versione del binario; `--once` esegue un solo ciclo invece di ripeterlo.

## Controlli

Dalla radice del repository, i seguenti comandi eseguono i controlli documentati per il workspace:

```bash
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-targets --all-features
```

## Struttura del repository

- `core/`, `cortex/`, `zvm/`, `zlang/` e `memzdos/` contengono i crate Rust del workspace.
- `organism-bin/` contiene il binario e il relativo punto d’ingresso.
- `programs/` contiene programmi dell’organismo, incluso `programs/organism/tick.zlang`.
- `docs/` raccoglie documentazione tecnica, operativa e note architetturali.

Per approfondire, consulta [la panoramica tecnica](docs/OVERVIEW.md), [la guida di deployment](docs/DEPLOYMENT.md) e [la documentazione dell’integrazione ZLang](docs/ORGANISM_ZLANG.md).
