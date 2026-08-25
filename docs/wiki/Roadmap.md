# Roadmap

## Stato delle milestone

| Milestone | Stato | Criterio di completamento |
|---|---|---|
| `0.1.0-foundation` | Completata | Build Rust, CI, CLI `--eval`/`--once`, test ZLang/ZVM e documentazione base |
| `0.2.0-observable` | Pianificata | Logging strutturato, metriche del ciclo, health status e test di integrazione |
| `0.3.0-runtime` | Pianificata | Parser con diagnostica a posizione, semantica ZLang estesa e API runtime stabile |
| `0.4.0-cortex` | Pianificata | Endpoint LLM configurabile con timeout, retry, fallback e contratti testabili |
| `1.0.0-production` | Obiettivo | Deployment riproducibile, security review, compatibilità documentata e rollback verificato |

## Priorità operative

| Priorità | Azione | Esito atteso |
|---|---|---|
| Alta | Aggiungere telemetria e test di integrazione | Diagnosi affidabile del ciclo organismico |
| Alta | Formalizzare configurazione e systemd | Deployment ripetibile e reversibile |
| Alta | Definire API ZLang/ZVM versionate | Compatibilità tra release |
| Media | Completare parser, diagnostica e semantica | Linguaggio interno utilizzabile oltre il prototipo |
| Media | Consolidare LLM bridge e fallback offline | Operatività anche senza endpoint remoto |
| Bassa | Pubblicare ADR e diagrammi | Governance tecnica e onboarding avanzato |

## Criteri di release

Ogni release deve avere CI verde, changelog aggiornato, note di rilascio, comando di quick start verificato e nessun segreto o artefatto locale nel diff. Le milestone che introducono comportamento runtime devono includere test automatici e una strategia di rollback.
