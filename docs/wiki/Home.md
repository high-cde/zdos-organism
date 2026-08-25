# ZDOS Organism

Benvenuto nella wiki di **ZDOS Organism**, il runtime bio-ispirato dell’ecosistema ZDOS / Z-GENESIS.

ZDOS Organism è un workspace Rust modulare che combina sensori di sistema, segnali neuro-computazionali, feedback omeostatico, decision engine, linguaggio interno ZLang e macchina virtuale ZVM. La release `0.1.0-foundation` rende operativo il percorso ZLang → compiler → ZVM e fornisce una CLI verificabile.

> La wiki descrive ciò che è implementato, ciò che è sperimentale e le condizioni necessarie per portare il runtime in staging o produzione.

## Indice

| Pagina | Contenuto |
|---|---|
| [Architettura](Architecture) | Confini dei crate, flusso dei segnali e responsabilità dei moduli. |
| [Guida operativa](Operations) | Installazione, CLI, configurazione, monitoraggio e troubleshooting. |
| [Roadmap](Roadmap) | Milestone di prodotto e criteri di completamento. |
| [Deployment](../DEPLOYMENT) | Staging, produzione, systemd e rollback. |
| [Changelog](../../CHANGELOG) | Cronologia delle modifiche e release. |
| [Release notes 0.1.0](../RELEASE_NOTES_0.1.0) | Note pubbliche della foundation release. |

## Quick start

```bash
git clone https://github.com/high-cde/zdos-organism.git
cd zdos-organism
cargo test --workspace --all-targets --all-features
cargo run -p organism-bin -- --eval "+ 2 3"
```

## Stato della documentazione

La documentazione è mantenuta insieme al codice. Le pagine distinguono le funzionalità verificate dai bridge sperimentali, evitano credenziali o segreti versionati e devono essere aggiornate insieme a ogni cambiamento architetturale o di deployment.
