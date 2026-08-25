# ZDOS Organism

> Runtime bio-ispirato, modulare e verificabile dell’ecosistema ZDOS / Z-GENESIS.

## Foundation release

La release `0.1.0-foundation` offre un workspace Rust stabile, una macchina virtuale ZVM con gestione degli errori, il percorso eseguibile ZLang → compiler → ZVM e una CLI con modalità `--eval` e `--once`.

```bash
cargo test --workspace --all-targets --all-features
cargo run -p organism-bin -- --eval "+ 2 3"
```

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
