# ZDOS Organism · Ecosystem Status

## Ruolo

`zdos-organism` è il runtime bio-computazionale dell’ecosistema ZDOS: modella segnali, feedback, stato persistente ed esecuzione ZLang attraverso una workspace Rust.

## Stato verificabile

| Superficie | Stato | Prova |
|---|---|---|
| Workspace Rust | `VERIFIED` | `Cargo.toml`, toolchain e CI presenti |
| ZLang/ZVM | `VERIFIED` | smoke test e test workspace dichiarati nel README |
| Loop organismo | `FOUNDATION` | modalità `--once` e daemon documentate |
| HighCoin bridge | `EXPERIMENTAL` | integrazione descritta come sperimentale |
| Endpoint LLM | `CONFIGURABLE` | `ZDOS_LLM_URL` via ambiente |

## Verifica locale

```bash
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-targets --all-features
ZDOS_STATE_DIR=./var cargo run -p organism-bin -- --once
```

## Integrazione

- **ZDOS Lab:** catalogo, manifest, policy e release gate.
- **Zlang:** linguaggio e VM condivisi.
- **Z-CYBERCORE:** piano operativo di sicurezza separato, non eseguito dal runtime senza policy.
- **ZDOS Hub:** ingresso pubblico per repository, wiki, release e contribution flow.

Non confondere la presenza nel catalogo dell’ecosistema con una prova di produzione: mantenere `FOUNDATION`, `EXPERIMENTAL` o `CONFIGURABLE` finché non esiste un’evidenza riproducibile.
