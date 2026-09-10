use crate::neuro::NeuroSignals;
use std::collections::HashMap;

const BIO_FEEDBACK_PROGRAM: &str = "if > cortisol 0.7 { 4010 } else if > dopamine 0.7 { 1100 } else if > serotonin 0.7 { 2030 } else { 2050 }";

#[derive(Debug, Clone)]
pub struct BioFeedback {
    pub loop_delay: u64,
    pub mutation_rate: f64,
}

impl Default for BioFeedback {
    fn default() -> Self {
        Self::new()
    }
}

impl BioFeedback {
    pub fn new() -> Self {
        Self {
            loop_delay: 2,
            mutation_rate: 0.05,
        }
    }

    pub fn update(&mut self, neuro: &NeuroSignals) {
        let mut vars = HashMap::new();
        vars.insert("cortisol".into(), neuro.cortisol);
        vars.insert("dopamine".into(), neuro.dopamine);
        vars.insert("serotonin".into(), neuro.serotonin);

        match zdos_zlang::runtime::execute_with_vars(BIO_FEEDBACK_PROGRAM, vars)
            .ok()
            .and_then(|output| output["result"].as_f64())
            .and_then(Self::decode_result)
        {
            Some((loop_delay, mutation_rate)) => {
                self.loop_delay = loop_delay;
                self.mutation_rate = mutation_rate;
            }
            None => self.update_rust_fallback(neuro),
        }
    }

    fn decode_result(result: f64) -> Option<(u64, f64)> {
        let encoded = result.round() as u64;
        let loop_delay = encoded / 1000;
        let mutation_rate = (encoded % 1000) as f64 / 1000.0;
        (matches!(loop_delay, 1..=4) && mutation_rate <= 1.0).then_some((loop_delay, mutation_rate))
    }

    fn update_rust_fallback(&mut self, neuro: &NeuroSignals) {
        if neuro.cortisol > 0.7 {
            self.loop_delay = 4;
            self.mutation_rate = 0.01;
        } else if neuro.dopamine > 0.7 {
            self.loop_delay = 1;
            self.mutation_rate = 0.10;
        } else if neuro.serotonin > 0.7 {
            self.loop_delay = 2;
            self.mutation_rate = 0.03;
        } else {
            self.loop_delay = 2;
            self.mutation_rate = 0.05;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn feedback(cortisol: f64, dopamine: f64, serotonin: f64) -> BioFeedback {
        let mut value = BioFeedback::new();
        value.update(&NeuroSignals {
            cortisol,
            dopamine,
            serotonin,
        });
        value
    }

    #[test]
    fn maps_stress_to_slow_safe_feedback() {
        let value = feedback(0.8, 0.1, 0.1);
        assert_eq!((value.loop_delay, value.mutation_rate), (4, 0.01));
    }

    #[test]
    fn preserves_priority_stress_over_reward_and_stability() {
        let value = feedback(0.8, 0.8, 0.8);
        assert_eq!((value.loop_delay, value.mutation_rate), (4, 0.01));
    }

    #[test]
    fn maps_reward_stability_and_neutral_states() {
        assert_eq!(
            (
                feedback(0.1, 0.8, 0.1).loop_delay,
                feedback(0.1, 0.8, 0.1).mutation_rate
            ),
            (1, 0.10)
        );
        assert_eq!(
            (
                feedback(0.1, 0.1, 0.8).loop_delay,
                feedback(0.1, 0.1, 0.8).mutation_rate
            ),
            (2, 0.03)
        );
        assert_eq!(
            (
                feedback(0.1, 0.1, 0.1).loop_delay,
                feedback(0.1, 0.1, 0.1).mutation_rate
            ),
            (2, 0.05)
        );
    }
}
