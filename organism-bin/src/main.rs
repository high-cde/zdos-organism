use anyhow::{Context, Result};
use std::{env, fs, path::PathBuf, thread, time::Duration};

mod bio_sensors;
use bio_sensors::*;
use cortex::bio::ReactiveCortex;
use cortex::comm::{BioComm, BioPacket};
use cortex::evolution::EvolutionEngine;
use cortex::feedback::BioFeedback;
use cortex::llm::http::HttpLLM;
use cortex::mutation::MutationEngine;
use cortex::neuro::NeuroSignals;
use cortex::optimization::OptimizerState;

fn main() -> Result<()> {
    let args: Vec<String> = env::args().skip(1).collect();
    if args.iter().any(|arg| arg == "--help" || arg == "-h") {
        print_help();
        return Ok(());
    }
    if args.iter().any(|arg| arg == "--version" || arg == "-V") {
        println!("zdos-organism 0.1.0");
        return Ok(());
    }
    if let Some(index) = args.iter().position(|arg| arg == "--eval") {
        let source = args
            .get(index + 1)
            .context("--eval richiede un programma ZLang")?;
        let result = zdos_zlang::runtime::execute(source).context("esecuzione ZLang fallita")?;
        println!("{}", serde_json::to_string_pretty(&result)?);
        return Ok(());
    }
    let once = args.iter().any(|arg| arg == "--once");
    let llm_url = env::var("ZDOS_LLM_URL").unwrap_or_else(|_| "http://127.0.0.1:8080/llm".into());
    let state_dir = env::var_os("ZDOS_STATE_DIR")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from("var"));
    fs::create_dir_all(&state_dir).context("impossibile creare ZDOS_STATE_DIR")?;
    let mut organism = Organism::new(&llm_url, state_dir);
    loop {
        organism.tick()?;
        if once {
            break;
        }
        thread::sleep(Duration::from_secs(organism.feedback.loop_delay));
    }
    Ok(())
}

struct Organism {
    cortex: ReactiveCortex<HttpLLM>,
    neuro: NeuroSignals,
    feedback: BioFeedback,
    optimizer: OptimizerState,
    state_dir: PathBuf,
    fitness_score: f64,
}

impl Organism {
    fn new(llm_url: &str, state_dir: PathBuf) -> Self {
        Self {
            cortex: ReactiveCortex::new(HttpLLM::new(llm_url)),
            neuro: NeuroSignals::new(),
            feedback: BioFeedback::new(),
            optimizer: OptimizerState::load(),
            state_dir,
            fitness_score: 0.5,
        }
    }

    fn tick(&mut self) -> Result<()> {
        let cpu_value = cpu();
        let net_value = net_latency();
        let io_value = io_load();
        let height = block_height();
        let diff = difficulty();
        let mem = mempool();
        println!("[ZDOS] sensors cpu={cpu_value:.2} net={net_value}ms io={io_value} h={height} diff={diff} mem={mem}");
        self.neuro.update(cpu_value, net_value, io_value);
        self.feedback.update(&self.neuro);
        BioComm::send(BioPacket {
            source: "NEURO".into(),
            signal: self.neuro.mood(),
            level: self.neuro.serotonin,
            priority: 2,
            hint: "adapt difficulty and mutation".into(),
        });
        self.fitness_score = EvolutionEngine::fitness(cpu_value, io_value, net_value);
        fs::write(
            self.state_dir.join("fitness.txt"),
            self.fitness_score.to_string(),
        )
        .context("impossibile salvare fitness")?;
        let mutated = MutationEngine::mutate(self.neuro.dopamine, self.feedback.mutation_rate);
        let new_diff = EvolutionEngine::adjust_difficulty(
            diff,
            self.neuro.dopamine,
            self.neuro.cortisol,
            self.neuro.serotonin,
        );
        self.optimizer
            .update(self.fitness_score, net_value as f64 / 100.0);
        self.optimizer.optimize(
            &mut self.feedback.loop_delay,
            &mut self.feedback.mutation_rate,
        );
        println!(
            "[ZDOS] fitness={:.3} mutation={mutated:.3} difficulty={new_diff:.3} interval={}s",
            self.fitness_score, self.feedback.loop_delay
        );
        match self.cortex.decide(cpu_value, net_value, io_value, height) {
            Ok(action) => println!("[ZDOS] decision={action}"),
            Err(error) => eprintln!("[ZDOS] cortex error: {error}"),
        }
        Ok(())
    }
}

fn print_help() {
    println!("ZDOS Organism\n\nUSAGE:\n  organism-bin [--once]\n  organism-bin --eval <zlang>\n\nOPTIONS:\n  --once              esegue un singolo ciclo senza daemonizzare\n  --eval <program>    esegue un programma ZLang e stampa JSON\n  ZDOS_LLM_URL        endpoint LLM (default: http://127.0.0.1:8080/llm)\n  ZDOS_STATE_DIR      directory stato (default: ./var)");
}
