pub struct EvolutionEngine;

impl EvolutionEngine {
    pub fn adjust_load(base: f64, dopamine: f64, cortisol: f64, serotonin: f64) -> f64 {
        let mut load = base;

        load *= 1.0 + (cortisol * 0.5);
        load *= 1.0 - (dopamine * 0.3);
        load *= 1.0 - (serotonin * 0.1);

        load.clamp(0.1, 1000.0)
    }

    pub fn fitness(cpu: f64, io: u64, net: u64) -> f64 {
        let io_f = io as f64 / 100.0;
        let net_f = net as f64 / 100.0;
        1.0 - ((cpu + io_f + net_f) / 3.0)
    }
}
