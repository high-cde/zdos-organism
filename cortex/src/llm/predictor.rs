use serde_json::{Value, json};
use super::interface::LLMInterface;

/// Predictor: usa la LLM per predire anomalie, rischi, colli di bottiglia, eventi futuri.
pub struct AnomalyPredictor<'a, T: LLMInterface> {
    llm: &'a T,
}

impl<'a, T: LLMInterface> AnomalyPredictor<'a, T> {
    pub fn new(llm: &'a T) -> Self {
        Self { llm }
    }

    /// Predice anomalie sulla base di stato + log.
    pub fn predict_anomalies(&self, state: &Value, logs: &Value) -> anyhow::Result<Value> {
        let payload = json!({
            "task": "predict_anomalies",
            "state": state,
            "logs": logs
        });
        self.llm.query_structured(&payload)
    }
}
