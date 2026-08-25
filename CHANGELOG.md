# Changelog ZDOS Organism

Tutte le modifiche rilevanti del progetto sono registrate in questo documento. Le versioni seguono una convenzione semantica finché il runtime resta in fase di consolidamento.

## [Unreleased]

Questa sezione raccoglie il lavoro successivo alla prima release foundation: telemetria strutturata, configurazione del servizio systemd, test di integrazione del cortex e documentazione dell’integrazione HighCoin.

## [0.1.0-foundation] — 2026-08-25

La prima release foundation rende il workspace Rust riproducibile e introduce un percorso end-to-end verificato tra ZLang, compiler e ZVM. La CLI supporta `--help`, `--version`, `--eval` e `--once`; il loop dell’organismo usa `ZDOS_LLM_URL` e `ZDOS_STATE_DIR` invece di percorsi hard-coded.

La macchina virtuale ora segnala in modo tipizzato stack underflow, divisione per zero, programma senza risultato e superamento del limite di istruzioni. Sono stati aggiunti test unitari per stack, aritmetica, runtime ZLang e gestione degli errori.

Il repository include `rust-toolchain.toml`, workflow CI per format, Clippy, test e smoke test CLI, oltre a regole `.gitignore` per escludere artefatti di build e stato locale.

## Riferimenti

- [README](README.md)
- [Overview tecnica](docs/OVERVIEW.md)
- [Roadmap](docs/wiki/Roadmap.md)
- [Security policy](SECURITY.md)
