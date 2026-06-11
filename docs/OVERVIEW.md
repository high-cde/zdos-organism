# Overview tecnica: ZDOS Organism

## Scopo

Runtime Python sperimentale per modellare ZDOS come organismo digitale modulare, osservabile e componibile. Questa overview definisce il contesto operativo del repository, il suo ruolo nell'ecosistema e le convenzioni minime da seguire durante l'evoluzione del progetto.

## Contesto architetturale

Il repository è collegato alla visione **ZDOS / Z-GENESIS**, dove ogni componente dovrebbe avere un ruolo esplicito, dipendenze documentate e una superficie operativa comprensibile. La priorità è mantenere il progetto semplice da analizzare, sicuro da estendere e coerente con gli altri moduli.

| Dimensione | Indicazione |
|---|---|
| Identità | `high-cde/zdos-organism` |
| Tecnologia principale | Python |
| Stato repository | Repository principale |
| Visibilità | PUBLIC |

## Convenzioni operative

Ogni modifica dovrebbe essere piccola, tracciabile e accompagnata da una nota nel README o nella wiki quando introduce nuove funzionalità. Le configurazioni sensibili non devono essere versionate; per credenziali e token è necessario usare variabili d'ambiente o secret manager.

## Qualità e manutenzione

Il progetto dovrebbe evolvere verso una struttura con test automatici, controlli statici e changelog. Quando possibile, le decisioni architetturali importanti dovrebbero essere annotate nella wiki o in file `docs/ADR-*.md`.

## Prossimi passi consigliati

| Priorità | Azione |
|---|---|
| Alta | Verificare dipendenze, script di avvio e prerequisiti reali. |
| Alta | Definire o confermare la licenza del repository. |
| Media | Aggiungere esempi minimi di utilizzo o screenshot quando applicabile. |
| Media | Integrare test, lint e workflow CI. |
| Bassa | Pubblicare una roadmap con milestone e tag di release. |
