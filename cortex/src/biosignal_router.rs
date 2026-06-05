use serde_json::Value;
use crate::mutation_engine::MutationEngine;
use crate::policy::allow_mutation;

pub struct BioSignalRouter {
    engine: MutationEngine,
}

impl BioSignalRouter {
    pub fn new() -> Self {
        Self { engine: MutationEngine::new() }
    }

    pub async fn route(&self, signal: &Value) -> Value {
        if !allow_mutation(signal) {
            return serde_json::json!({ "status": "blocked" });
        }

        // Se è un pensiero Z-Lang
        if signal.get("kind").and_then(|k| k.as_str()) == Some("thought") {
            if let Some(src) = signal.get("zlang").and_then(|v| v.as_str()) {
                return self.engine.mutate(&serde_json::json!({ "zlang": src })).await;
            }
        }

        // Se è mutazione bytecode
        if signal.get("kind").and_then(|k| k.as_str()) == Some("mutation-bytecode") {
            if let Some(bytecode) = signal.get("bytecode") {
                return self.engine.mutate(&serde_json::json!({ "bytecode": bytecode })).await;
            }
        }

        serde_json::json!({ "status": "routed-noop" })
    }
}
