# ZDOS Organism v0.1.0-foundation

**Data:** 25 agosto 2026
**Stato:** foundation release — pronta per staging e validazione operativa

## Cosa include

Questa release consolida ZDOS Organism come workspace Rust eseguibile e verificabile. Il percorso ZLang → compiler → ZVM è operativo dalla CLI e restituisce risultati JSON strutturati. La macchina virtuale dispone di errori espliciti per condizioni anomale e di un limite massimo di istruzioni per evitare esecuzioni senza controllo.

Il binario `organism-bin` offre una modalità `--once` per eseguire un singolo ciclo e una modalità `--eval` per eseguire espressioni ZLang. Endpoint LLM e directory dello stato sono configurabili tramite `ZDOS_LLM_URL` e `ZDOS_STATE_DIR`.

## Verifica

La release è stata verificata con:

```bash
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-targets --all-features
cargo run -p organism-bin -- --eval "+ 2 3"
```

Il test CLI produce `result: 5.0`, con un programma composto da una dichiarazione di espressione.

## Limiti noti

La release non include ancora un endpoint LLM distribuito, un’unità systemd installabile in modo universale o un bridge HighCoin con rete reale configurato per produzione. Questi elementi restano nel perimetro delle successive milestone e richiedono parametri operativi e credenziali dell’ambiente di deployment.

## Installazione rapida

```bash
git clone https://github.com/high-cde/zdos-organism.git
cd zdos-organism
cargo run -p organism-bin -- --eval "+ 2 3"
```

Per eseguire un singolo ciclo dell’organismo:

```bash
ZDOS_STATE_DIR=./var cargo run -p organism-bin -- --once
```

## Licenza

MIT License.
