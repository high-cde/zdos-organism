use crate::neuro::NeuroSignals;

#[derive(Debug, Clone)]
pub struct BioFeedback {
    pub loop_delay: u64,
    pub mutation_rate: f64,
}

impl BioFeedback {
    pub fn new() -> Self {
        Self { loop_delay: 2, mutation_rate: 0.05 }
    }

    pub fn update(&mut self, neuro: &NeuroSignals) {
        if neuro.cortisol > 0.7 {
            self.loop_delay = 4;
            self.mutation_rate = 0.01;
        } else if neuro.dopamine > 0.7 {
            self.loop_delay = 1;
            self.mutation_rate = 0.10;
        } else if neuro.serotonin > 0.7 {
            self.loop_delay = 2;
            self.mutation_rate = 0.03;
        }
    }
}
