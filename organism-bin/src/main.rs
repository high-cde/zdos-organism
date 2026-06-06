use std::time::Duration;
use std::fs;

mod bio_sensors;
use bio_sensors::*;

use cortex::bio::ReactiveCortex;
use cortex::llm::http::HttpLLM;
use cortex::neuro::NeuroSignals;
use cortex::feedback::BioFeedback;
use cortex::mutation::MutationEngine;
use cortex::evolution::EvolutionEngine;
use cortex::comm::{BioComm, BioPacket};
use cortex::optimization::OptimizerState;

fn main() {
    let llm = HttpLLM::new("http://127.0.0.1:8080/llm");
    let cortex = ReactiveCortex::new(llm);

    let mut neuro = NeuroSignals::new();
    let mut feedback = BioFeedback::new();
    let mut fitness_score = 0.5;
    let mut optimizer = OptimizerState::load();

    loop {
        let cpu = cpu();
        let net = net_latency();
        let io = io_load();
        let h = block_height();
        let diff = difficulty();
        let mem = mempool();

        println!(
            "[ZDOS] 🧩 Sensors: cpu={:.2}, net={}ms, io={}, h={}, diff={}, mem={}",
            cpu, net, io, h, diff, mem
        );

        neuro.update(cpu, net, io);
        println!(
            "[ZDOS] 🧬 NeuroSignals → dopamine={:.2}, cortisol={:.2}, serotonin={:.2}, mood={}",
            neuro.dopamine, neuro.cortisol, neuro.serotonin, neuro.mood()
        );

        feedback.update(&neuro);

        BioComm::send(BioPacket {
            source: "NEURO".into(),
            signal: neuro.mood(),
            level: neuro.serotonin,
            priority: 2,
            hint: "adatta difficulty e mutation".into(),
        });

        let new_fitness = EvolutionEngine::fitness(cpu, io, net);
        fitness_score = new_fitness;
        let _ = fs::write("/root/zdos-organism/fitness.txt", format!("{}", fitness_score));
        println!("[ZDOS] 🧬 Fitness: {:.3}", fitness_score);

        let mutated = MutationEngine::mutate(neuro.dopamine, feedback.mutation_rate);
        println!("[ZDOS] 🧬 Mutation: dopamine mutated → {:.3}", mutated);

        let new_diff =
            EvolutionEngine::adjust_difficulty(diff, neuro.dopamine, neuro.cortisol, neuro.serotonin);
        println!("[ZDOS] 🔧 Difficulty adjusted → {:.3}", new_diff);

        optimizer.update(fitness_score, net as f64 / 100.0);
        optimizer.optimize(&mut feedback.loop_delay, &mut feedback.mutation_rate);
        println!(
            "[ZDOS] 🔧 AutoOpt → loop_delay={}s, mutation_rate={:.3}",
            feedback.loop_delay, feedback.mutation_rate
        );

        match cortex.decide(cpu, net, io, h) {
            Ok(action) => println!("[ZDOS] 🧠 Decisione: {}", action),
            Err(e) => println!("[ZDOS] ⚠️ Errore cortex: {e}")
        }

        std::thread::sleep(Duration::from_secs(feedback.loop_delay));
    }
}
