use rand::Rng;
use std::fs;

pub struct MutationEngine;

impl MutationEngine {
    pub fn mutate(value: f64, rate: f64) -> f64 {
        let mut rng = rand::thread_rng();
        let delta: f64 = rng.gen_range(-rate..rate);
        let new = (value + delta).clamp(0.0, 1.0);

        let _ = fs::write("/root/highcoin-node/mutation_cost.txt", format!("{}", rate * 10.0));

        new
    }
}
