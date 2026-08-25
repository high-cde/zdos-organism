# Overview tecnica: ZDOS Organism

## Scopo

ZDOS Organism è un runtime Rust sperimentale per modellare ZDOS come organismo digitale modulare, osservabile e componibile. Questa overview definisce il contesto operativo, il ruolo del repository nell’ecosistema e i quality gate necessari per l’evoluzione verso un prodotto di staging.

## Contesto architetturale

Il repository è collegato alla visione **ZDOS / Z-GENESIS**, dove ogni componente deve avere un ruolo esplicito, dipendenze documentate e una superficie operativa comprensibile. Il percorso principale usa Cargo workspace; Python e Shell restano strumenti ausiliari e non costituiscono il runtime canonico.

| Dimensione | Indicazione |
|---|---|
| Identità | `high-cde/zdos-organism` |
| Tecnologia principale | Rust stable |
| Componenti | `core`, `cortex`, `zvm`, `zlang`, `organism-bin`, `memzdos` |
| Stato repository | Foundation release / staging |
| Visibilità | Public |
| Versione documentata | `0.1.0-foundation` |

## Contratto operativo

La CLI deve supportare un’esecuzione locale deterministica di ZLang con `--eval` e un battito osservabile dell’organismo con `--once`. Il servizio LLM è opzionale per la verifica del runtime e viene configurato con `ZDOS_LLM_URL`; lo stato locale usa `ZDOS_STATE_DIR`. Nessuna di queste configurazioni deve contenere segreti versionati.

## Qualità e manutenzione

Ogni modifica deve passare `cargo fmt`, Clippy con warning trattati come errori e la suite `cargo test`. La CI applica questi controlli su push e pull request. Le decisioni architetturali importanti devono essere annotate nella wiki o in file `docs/ADR-*.md`; le modifiche utente devono aggiornare changelog e note di release.

## Release e governance

Le release sono attivate da tag semantici `vMAJOR.MINOR.PATCH`. Il workflow di release ricompila il binario, esegue i quality gate, genera checksum SHA-256 e pubblica le note di rilascio. GitHub Pages pubblica la documentazione dal ramo `main` e può essere avviato manualmente.

## Prossimi passi consigliati

| Priorità | Azione |
|---|---|
| Alta | Aggiungere metriche, health status e test di integrazione. |
| Alta | Completare configurazione systemd e rollback di staging. |
| Media | Estendere parser e diagnostica ZLang con posizioni sorgente. |
| Media | Rendere il bridge LLM resiliente con timeout, retry e fallback. |
| Bassa | Pubblicare ADR, diagrammi e report di benchmark. |
