# ZDOS Organism

> Runtime bio-ispirato, modulare e verificabile dell’ecosistema ZDOS / Z-GENESIS.

## Foundation release

[Scarica la ISO ZDOS x86_64 · Zlang v1](https://github.com/high-cde/ZDOS/releases/latest/download/zdos-x86_64-zlang-v1.iso)
SHA-256: `f2f9e5003f86f7f2f0ce702b321dc55490e782341896d8b1860a8fe8c28dc023`

La release `0.1.0-foundation` offre un workspace Rust stabile, una macchina virtuale ZVM con gestione degli errori, il percorso eseguibile ZLang → compiler → ZVM e una CLI con modalità `--eval` e `--once`.

```bash
cargo test --workspace --all-targets --all-features
cargo run -p organism-bin -- --eval "+ 2 3"
```

## Download e compatibilità

La ISO è verificata su QEMU x86_64 con boot seriale. Non è una distro general-purpose e non include un installer Windows. Per sorgenti, note e checksum consulta la [release ZDOS](https://github.com/high-cde/ZDOS/releases).

## Documentazione

- [README del progetto](../README.md)
- [Overview tecnica](docs/OVERVIEW.md)
- [Architettura](docs/wiki/Architecture.md)
- [Guida operativa](docs/wiki/Operations.md)
- [Deployment](docs/DEPLOYMENT.md)
- [Roadmap](docs/wiki/Roadmap.md)
- [Changelog](../CHANGELOG.md)
- [Release notes 0.1.0](docs/RELEASE_NOTES_0.1.0.md)

## Stato

Il runtime è pronto per sviluppo e staging. Il bridge LLM, il deployment systemd e l’integrazione HighCoin in ambiente reale richiedono configurazione specifica del deployment e restano soggetti alle milestone successive.
