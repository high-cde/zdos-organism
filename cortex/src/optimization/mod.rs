use std::fs;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OptimizerState {
    pub avg_fitness: f64,
    pub avg_latency: f64,
    pub cycles: u64,
}

impl OptimizerState {
    pub fn load() -> Self {
        fs::read_to_string("/root/zdos-organism/optimizer.json")
            .ok()
            .and_then(|t| serde_json::from_str(&t).ok())
            .unwrap_or(Self {
                avg_fitness: 0.5,
                avg_latency: 0.5,
                cycles: 0,
            })
    }

    pub fn save(&self) {
        let _ = fs::write(
            "/root/zdos-organism/optimizer.json",
            serde_json::to_string_pretty(self).unwrap(),
        );
    }

    pub fn update(&mut self, fitness: f64, latency: f64) {
        self.cycles += 1;
        self.avg_fitness = (self.avg_fitness * 0.9) + (fitness * 0.1);
        self.avg_latency = (self.avg_latency * 0.9) + (latency * 0.1);
        self.save();
    }

    pub fn optimize(&self, loop_delay: &mut u64, mutation_rate: &mut f64) {
        if self.avg_fitness > 0.75 {
            *mutation_rate = (*mutation_rate * 0.9).clamp(0.01, 0.2);
        }
        if self.avg_latency > 0.5 {
            *loop_delay = (*loop_delay + 1).min(5);
        }
        if self.avg_latency < 0.2 {
            *loop_delay = (*loop_delay - 1).max(1);
        }
    }
}
