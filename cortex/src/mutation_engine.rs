use serde_json::Value;

pub struct MutationEngine;

impl MutationEngine {
    pub fn new() -> Self {
        MutationEngine
    }

    pub fn mutate(&self, ctx: &Value) -> Value {
        let stability = ctx["prediction"]["stability"].as_f64().unwrap_or(0.5);

        if stability > 0.9 {
            ctx.clone()
        } else {
            let mut out = ctx.clone();
            out["mutation_applied"] = Value::String("reinforce-pathway".to_string());
            out
        }
    }
}
