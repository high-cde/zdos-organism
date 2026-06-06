use serde_json::Value;
use serde_json::json;
use crate::predictive_layer::PredictiveLayer;
use crate::mutation_engine::MutationEngine;

pub struct HyperCortex {
    predictive: PredictiveLayer,
    engine: MutationEngine,
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
