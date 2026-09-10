use rand::Rng;
use std::fs;

pub struct MutationEngine;

impl MutationEngine {
    pub fn mutate(value: f64, rate: f64) -> f64 {
        let mut rng = rand::thread_rng();
        let delta: f64 = rng.gen_range(-rate..rate);
        let new = (value + delta).clamp(0.0, 1.0);

        if let Ok(state_dir) = std::env::var("ZDOS_STATE_DIR") {
            let _ = fs::write(
                std::path::Path::new(&state_dir).join("mutation_cost.txt"),
                format!("{}", rate * 10.0),
            );
        }

        new
    }
}
