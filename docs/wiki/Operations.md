# Guida operativa

## Avvio rapido

Clona il repository e verifica il workspace prima di avviare il ciclo organismico:

```bash
git clone https://github.com/high-cde/zdos-organism.git
cd zdos-organism
cargo test --workspace --all-targets --all-features
```

Per provare il runtime ZLang localmente:

```bash
cargo run -p organism-bin -- --eval "+ 2 3"
```

Per un singolo battito senza loop infinito:

```bash
ZDOS_STATE_DIR=./var cargo run -p organism-bin -- --once
```

## Configurazione

| Variabile | Default | Funzione |
|---|---|---|
| `ZDOS_LLM_URL` | `http://127.0.0.1:8080/llm` | Endpoint del cortex LLM |
| `ZDOS_STATE_DIR` | `./var` | Directory per fitness e stato locale |

Le variabili devono essere fornite dal sistema di deployment o da un file protetto non versionato. Non inserire token, password o chiavi private nel repository.

## Daemon e monitoraggio

La modalità senza `--once` mantiene il ciclo attivo. In produzione usare un utente dedicato, systemd o un supervisore equivalente, con directory di stato separata e log centralizzati. Consultare la [guida deployment](../DEPLOYMENT.md) per un’unità systemd con sandboxing di base.

## Manutenzione

| Attività | Frequenza consigliata |
|---|---|
| `cargo fmt`, Clippy e test | A ogni modifica significativa |
| Verifica dipendenze | A ogni release |
| Aggiornamento documentazione | Insieme a ogni feature o cambio architetturale |
| Controllo segreti e diff | Prima di ogni push |
| Backup della directory di stato | Prima di upgrade o rollback |

## Troubleshooting

Se `cargo` non è disponibile, installare Rust stable tramite il metodo ufficiale o usare l’immagine CI. Se l’endpoint LLM non risponde, usare `--eval` per verificare il runtime locale e `--once` per diagnosticare i sensori senza bloccare il terminale. Se il processo non può scrivere lo stato, controllare `ZDOS_STATE_DIR` e i permessi dell’utente di servizio.

## Sicurezza

Non eseguire automazioni su sistemi non autorizzati. Conserva credenziali e token fuori dal repository, usa SSH o token a scadenza per GitHub e testa gli script sperimentali in ambienti isolati. Per segnalazioni responsabili consultare `SECURITY.md`.
