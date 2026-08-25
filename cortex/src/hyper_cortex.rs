use crate::mutation_engine::MutationEngine;
use crate::predictive_layer::PredictiveLayer;
use serde_json::{json, Value};

pub struct HyperCortex {
    predictive: PredictiveLayer,
    engine: MutationEngine,
}

impl Default for HyperCortex {
    fn default() -> Self {
        Self::new()
    }
}

impl HyperCortex {
    pub fn new() -> Self {
        HyperCortex {
            predictive: PredictiveLayer::new(),
            engine: MutationEngine::new(),
        }
    }

    pub fn process(&self, signal: Value) -> Value {
        let prediction = self.predictive.predict(&signal);
        let ctx = json!({ "signal": signal, "prediction": prediction });
        self.engine.mutate(&ctx)
    }
}
