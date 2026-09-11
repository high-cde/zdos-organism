# ZDOS Organism in ZLang

## Scopo

`programs/organism/tick.zlang` è il programma canonico del feedback bounded dell’organismo. Rust resta il supervisore: raccoglie lo snapshot, fornisce le variabili alla ZVM, valida il risultato e applica soltanto valori entro i limiti dichiarati.

## Input ABI v1

Il programma riceve variabili numeriche normalizzate:

| Variabile | Intervallo | Significato |
|---|---:|---|
| `cortisol` | `0.0..=1.0` | pressione/stress osservato |
| `dopamine` | `0.0..=1.0` | segnale reward/adattamento |
| `serotonin` | `0.0..=1.0` | stabilità osservata |

La validazione dell’input e il fallback restano responsabilità Rust. Variabili assenti o non valide non autorizzano operazioni esterne.

## Output ABI v1

Il programma restituisce un codice numerico composto da:

```text
loop_delay_seconds * 1000 + mutation_rate_thousandths
```

| Codice | Modalità | Intervallo | Mutation rate |
|---:|---|---:|---:|
| `4010` | `stress` | 4 s | 0.01 |
| `1100` | `reward` | 1 s | 0.10 |
| `2030` | `stable` | 2 s | 0.03 |
| `2050` | `neutral` | 2 s | 0.05 |

Rust accetta soltanto `loop_delay` tra 1 e 4 secondi e `mutation_rate` tra 0.0 e 1.0. Ogni altro risultato attiva il fallback neutrale.

## Capability profile

Il profilo ZLang non dispone di accesso diretto a shell, rete, credenziali, processi o filesystem. Le capability sono applicate dall’host Rust:

| Capability | Stato | Limite |
|---|---|---|
| `sensor.*.read` | consentita | snapshot già raccolto e normalizzato |
| `organism.loop_delay.set` | consentita | solo 1–4 secondi |
| `organism.mutation_rate.set` | consentita | solo 0.0–1.0 |
| `state.read` | non esposta al programma | namespace host-controlled |
| `state.write` | non esposta al programma | host-controlled |
| `evidence.append` | host-controlled | solo receipt strutturate |
| `shell.exec` | negata | sempre |
| `network.open` | negata | sempre nel profilo local-only |
| `credential.read` | negata | sempre |
| `node.modify` | negata | sempre |

## Ciclo operativo

```text
snapshot read-only
  → variabili ZLang
  → compilazione/validazione ZLB2
  → esecuzione ZVM
  → decode bounded
  → applicazione di loop_delay e mutation_rate
  → stato locale e receipt
```

Il programma non decide autonomamente di aprire connessioni o eseguire comandi. In caso di errore di parsing, VM o validazione, il runtime usa la modalità neutrale e registra l’errore localmente.

## Verifica

```bash
cargo test --workspace --all-targets --all-features
cargo run -p organism-bin -- --eval '+ 2 3'
ZDOS_STATE_DIR=./var cargo run -p organism-bin -- --once
```

Il file ZLang è deliberatamente semplice e compatibile con il parser attuale. L’evoluzione futura dell’ABI potrà sostituire il codice numerico con record tipizzati quando il contratto ZLB2 del repository primario lo supporterà.
