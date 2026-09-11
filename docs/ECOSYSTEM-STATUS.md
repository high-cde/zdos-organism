# ZDOS Organism · Ecosystem Status

## Ruolo

`zdos-organism` è il runtime bio-computazionale dell’ecosistema ZDOS: modella segnali, feedback, stato persistente ed esecuzione ZLang attraverso una workspace Rust.

## Stato verificabile

| Superficie | Stato | Prova |
|---|---|---|
| Workspace Rust | `VERIFIED` | `Cargo.toml`, toolchain e CI presenti |
| ZLang/ZVM | `VERIFIED` | smoke test e test workspace dichiarati nel README |
| Loop organismo | `FOUNDATION` | modalità `--once` e daemon documentate |
| BioFeedback ZLang | `VERIFIED` | policy omeostatica eseguita dalla ZVM |
| Endpoint LLM | `CONFIGURABLE` | `ZDOS_LLM_URL` via ambiente |

## Verifica locale

```bash
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-targets --all-features
ZDOS_STATE_DIR=./var cargo run -p organism-bin -- --once
```

## Integrazione

- **ZDOS:** catalogo, manifest, policy, Evidence Chain e release gate.
- **Zlang:** linguaggio e VM del programma canonico dell’organismo.
- **ZDOS Hub:** ingresso pubblico per repository, wiki, release e contribution flow.

Non confondere la presenza nel catalogo dell’ecosistema con una prova di produzione: mantenere `FOUNDATION`, `EXPERIMENTAL` o `CONFIGURABLE` finché non esiste un’evidenza riproducibile.
