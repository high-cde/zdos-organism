# ZDOS Organism — Bio‑Computational Adaptive System

![ZDOS](https://img.shields.io/badge/ZDOS-Organism-00ff99?style=for-the-badge&logo=linux&logoColor=white)
![HighCoin](https://img.shields.io/badge/HighCoin-Bridge-ffcc00?style=for-the-badge&logo=bitcoin&logoColor=black)
![BioSystem](https://img.shields.io/badge/Bio--Computational-System-8a2be2?style=for-the-badge)
![Rust](https://img.shields.io/badge/Rust-1.79+-orange?style=for-the-badge&logo=rust)
![AutoOpt](https://img.shields.io/badge/Auto--Optimization-Enabled-00ffaa?style=for-the-badge&logo=dependabot)
![Organism](https://img.shields.io/badge/Organism-Alive-ff66cc?style=for-the-badge&logo=heartbeat)
![Evolution](https://img.shields.io/badge/Evolution-Active-ff3366?style=for-the-badge&logo=dna)
![Neuro](https://img.shields.io/badge/NeuroSignals-Online-9933ff?style=for-the-badge&logo=neovim)
![Whitepaper](https://img.shields.io/badge/Whitepaper-Available-4444ff?style=for-the-badge&logo=readthedocs)

---

## 🧬 Overview
**ZDOS Organism** è un sistema computazionale avanzato che integra modelli bio‑ispirati, architetture adattive e un metabolismo blockchain basato su HighCoin.
Il progetto implementa un **organismo computazionale** capace di percepire, reagire, adattarsi, evolvere e ottimizzarsi in tempo reale.

Documentazione completa:
- **[Overview tecnica](docs/OVERVIEW.md)**
- **[Architettura del runtime](docs/wiki/Architecture.md)**
- **[Release notes](docs/RELEASE_NOTES_0.1.0.md)**

---

## 🧠 Architettura del Sistema
L’ecosistema è composto da moduli indipendenti e cooperanti:

- **Cortex Reattivo** — centro decisionale e bridge LLM (`cortex/`)
- **NeuroSignals** — segnali neuro-computazionali (`cortex/src/neuro/`)
- **BioFeedback** — omeostasi interna (`cortex/src/feedback/`)
- **Mutation Engine** — micro-evoluzione (`cortex/src/mutation_engine.rs`)
- **Evolution Engine** — fitness e selezione (`cortex/src/`)
- **ZLang / ZVM** — linguaggio interno e macchina virtuale (`zlang/`, `zvm/`)
- **Optimizer** — auto-ottimizzazione (`cortex/src/optimization/`)
- **HighCoin Bridge** — integrazione sperimentale (`cortex/src/`)
- **Identity Core** — stato persistente e memoria (`memzdos/`)

---

## 🔬 Ciclo Vitale
```
SENSING → NEURO → FEEDBACK → MUTATION → EVOLUTION → OPTIMIZATION → DECISION → LOOP
```

Ogni ciclo rappresenta un **battito vitale** dell’organismo.

---

## ⚡ Funzionalità Principali
- Percezione sensori (CPU, IO, rete, blockchain)
- Neuro‑modulazione computazionale
- Evoluzione parametrica
- Difficulty dinamica su HighCoin
- Reward adattiva
- Auto‑ottimizzazione persistente
- Linguaggio interno strutturato (BioComm)
- Identità computazionale persistente

---

## 📁 Struttura del Repository
```
organism-bin/      → ciclo vitale
cortex/            → decision engine
neuro/             → segnali interni
feedback/          → omeostasi
mutation/          → micro-evoluzione
evolution/         → fitness e selezione
comm/              → BioComm
optimization/      → auto-ottimizzazione
bio_sensors/       → sensori
```

---

## 🚀 Avvio del Sistema
### Avviare l’organismo
```bash
systemctl restart zdos-organism.service
```

### Log realtime
```bash
journalctl -u zdos-organism.service -f
```

### Avviare il nodo HighCoin
```bash
systemctl restart highcoin.service
```

---

## 🔗 Integrazione Blockchain
Il modulo **HighCoin Bridge** fornisce:

- difficulty dinamica
- reward adattiva
- costo metabolico delle mutazioni
- feedback economico

---

## 📚 Documentazione
- **[Overview tecnica](docs/OVERVIEW.md)**
- **[Wiki tecnica](docs/wiki/Home.md)**
- **[Deployment](docs/DEPLOYMENT.md)**
- **[Changelog](CHANGELOG.md)**

---

## 🛠️ Installazione e verifica

Il progetto richiede una toolchain Rust stabile. La configurazione è dichiarata in `rust-toolchain.toml` e include `rustfmt` e `clippy`.

```bash
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-targets --all-features
```

## ⚙️ CLI operativa

Per eseguire un programma ZLang attraverso il percorso reale parser → compiler → ZVM:

```bash
cargo run -p organism-bin -- --eval "+ 2 3"
```

Output previsto:

```json
{
  "result": 5.0,
  "statements": 1,
  "status": "ok"
}
```

Per eseguire un singolo battito dell’organismo senza avviare un loop infinito:

```bash
ZDOS_STATE_DIR=./var cargo run -p organism-bin -- --once
```

La modalità daemon resta disponibile senza `--once`. L’endpoint del cortex può essere configurato con `ZDOS_LLM_URL`; la directory dello stato persistente con `ZDOS_STATE_DIR`, che per impostazione predefinita è `./var`. Il processo non richiede più percorsi hard-coded sotto `/root`.

## ✅ Stato del prodotto

Il repository è ora compilabile con Rust stabile e la CI verifica automaticamente formattazione, Clippy, test e smoke test CLI. ZLang esegue effettivamente il bytecode ZVM; la macchina virtuale segnala underflow, divisione per zero e superamento del limite di istruzioni tramite errori tipizzati. Il loop dell’organismo supporta un ciclo singolo, stato locale portabile e configurazione dell’endpoint LLM via ambiente.

## 🌐 Documentazione pubblica

- **[Wiki Home](docs/wiki/Home.md)** — ingresso principale alla documentazione.
- **[Architettura](docs/wiki/Architecture.md)** — crate, flusso dei segnali e confini del runtime.
- **[Guida operativa](docs/wiki/Operations.md)** — installazione, CLI, configurazione e troubleshooting.
- **[Deployment](docs/DEPLOYMENT.md)** — staging, produzione, systemd e rollback.
- **[Roadmap](docs/wiki/Roadmap.md)** — milestone e criteri di completamento.
- **[Changelog](CHANGELOG.md)** — cronologia delle modifiche.
- **[Release notes v0.1.0](docs/RELEASE_NOTES_0.1.0.md)** — note della foundation release.
- **[Ecosystem Status](docs/ECOSYSTEM-STATUS.md)** — ruolo, stato verificabile e integrazione con ZDOS Lab, Zlang e Z-CYBERCORE.

## 🚦 Stato pubblico

| Superficie | Stato | Scopo |
|---|---|---|
| CI | Attiva | Format, Clippy, test e smoke test CLI |
| GitHub Pages | Attivabile da Actions | Pubblicazione automatica della documentazione |
| GitHub Releases | Automatizzata su tag `v*.*.*` | Binario Linux, checksum e note di rilascio |
| Runtime | Foundation / staging | ZLang, ZVM, sensori e cortex configurabile |

## 📝 Licenza
MIT License.
