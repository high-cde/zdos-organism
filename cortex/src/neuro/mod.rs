#[derive(Debug, Clone)]
pub struct NeuroSignals {
    pub dopamine: f64,
    pub cortisol: f64,
    pub serotonin: f64,
}

impl NeuroSignals {
    pub fn new() -> Self {
        Self { dopamine: 0.5, cortisol: 0.5, serotonin: 0.5 }
    }

    pub fn update(&mut self, cpu: f64, net: u64, io: u64) {
        self.dopamine += (0.5 - cpu).max(0.0) * 0.05;
        self.dopamine = self.dopamine.clamp(0.0, 1.0);

        self.cortisol += ((net as f64 / 100.0) + (io as f64 / 100.0)) * 0.05;
        self.cortisol = self.cortisol.clamp(0.0, 1.0);

        let stability = 1.0 - ((cpu + (io as f64 / 100.0)) / 2.0);
        self.serotonin += stability * 0.03;
        self.serotonin = self.serotonin.clamp(0.0, 1.0);
    }

    pub fn mood(&self) -> String {
        if self.cortisol > 0.7 { "stress".into() }
        else if self.dopamine > 0.7 { "reward".into() }
        else if self.serotonin > 0.7 { "stable".into() }
        else { "neutral".into() }
    }
}
