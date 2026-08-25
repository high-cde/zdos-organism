# Architettura

## Ruolo del repository

ZDOS Organism è il runtime bio-ispirato dell’ecosistema ZDOS / Z-GENESIS. Il percorso principale è implementato in Rust come workspace Cargo; Python è utilizzato soltanto per strumenti e mock LLM ausiliari. Il repository deve rimanere comprensibile, tracciabile e installabile senza dipendere da artefatti locali.

| Area | Descrizione |
|---|---|
| Identità | `high-cde/zdos-organism` |
| Tecnologia principale | Rust stable |
| Componenti ausiliari | Shell e Python per strumenti sperimentali |
| Tipo | Runtime modulare e laboratorio di ricerca |
| Visibilità | Public |
| Release corrente | `0.1.0-foundation` |

## Modello a strati

| Strato | Crate/modulo | Responsabilità |
|---|---|---|
| Interfaccia | `organism-bin` | CLI, ciclo vitale, configurazione e stato |
| Cognizione | `cortex` | Decisioni, feedback, evoluzione e bridge LLM |
| Runtime | `zlang`, `zvm` | AST, compiler, bytecode e esecuzione sicura |
| Fondazione | `core`, `memzdos` | Bridge, memoria e primitive condivise |
| Percezione | `bio` e `organism-bin/src/bio_sensors.rs` | CPU, rete, I/O e segnali ambientali |

## Flusso di un battito

```text
SENSORS → NEURO SIGNALS → BIO FEEDBACK → FITNESS
       → MUTATION → OPTIMIZATION → CORTEX DECISION → STATE
```

Il percorso ZLang è separato dal ciclo organismico ma utilizzabile dalla stessa CLI:

```text
source ZLang → Parser → AST → Compiler → BytecodeProgram → ZVM → JSON result
```

## Principi

La progettazione privilegia modularità, leggibilità, sicurezza operativa e verificabilità. I componenti sperimentali devono essere isolati, configurabili tramite variabili d’ambiente e testati prima dell’uso in ambienti condivisi. Il runtime non deve incorporare segreti, path assoluti o dipendenze da directory generate.
