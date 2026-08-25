# ADR-0001: Runtime Rust come base di ZDOS Organism

- **Stato:** accettato
- **Data:** 2026-08-25
- **Decisione:** Rust stable come runtime canonico

## Contesto

ZDOS Organism nasce come prototipo modulare con componenti bio-ispirati, bridge LLM e strumenti ausiliari. La prima struttura non distingueva sempre chiaramente codice runtime, artefatti generati e automazioni sperimentali. Per un prodotto distribuibile servono un contratto di build riproducibile, errori osservabili e dipendenze con confini espliciti.

## Decisione

Il runtime canonico è un workspace Cargo Rust. `organism-bin` espone la superficie operativa; `cortex` gestisce decisioni e feedback; `zlang` e `zvm` implementano il linguaggio interno e la sua esecuzione; `core` e `memzdos` forniscono primitive condivise. Python e Shell possono restare strumenti di laboratorio, ma non devono diventare dipendenze implicite dell’esecuzione Rust.

La toolchain è dichiarata in `rust-toolchain.toml`. Ogni cambiamento deve superare format, Clippy e test nella CI. I bridge remoti, inclusi LLM e HighCoin, sono opzionali rispetto al percorso locale e devono essere configurati dall’ambiente di deployment.

## Conseguenze

La scelta consente binari nativi, gestione esplicita degli errori e una pipeline CI uniforme. Richiede invece disciplina sui manifest Cargo, attenzione alla compatibilità della toolchain e test dedicati per i bridge esterni. La release `0.1.0-foundation` costituisce il primo punto verificabile di questa decisione.

## Alternative considerate

Un runtime Python puro avrebbe ridotto il costo iniziale, ma avrebbe mantenuto ambiguità tra prototipo e prodotto e una superficie di deployment più fragile. Un’architettura distribuita completa sarebbe prematura senza contratti stabili per telemetria, persistenza e bridge remoti.
