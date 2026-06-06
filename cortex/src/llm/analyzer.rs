use serde_json::{Value, json};
use super::interface::LLMInterface;

/// Analyzer: usa la LLM per analizzare lo stato di memZDOS, log, pattern, anomalie.
pub struct StateAnalyzer<'a, T: LLMInterface> {
    llm: &'a T,
}

impl<'a, T: LLMInterface> StateAnalyzer<'a, T> {
    pub fn new(llm: &'a T) -> Self {
        Self { llm }
    }

    /// Analizza uno snapshot di stato (JSON) e restituisce un report testuale.
    pub fn analyze_state(&self, state_snapshot: &Value) -> anyhow::Result<String> {
        let prompt = format!(
            "Analizza questo stato ZDOS (memZDOS) e descrivi anomalie, pattern e rischi:\n{}",
            state_snapshot
        );
        self.llm.query_raw(&prompt)
    }

    /// Analizza log di eventi e restituisce un riassunto strutturato.
    pub fn summarize_logs(&self, logs: &Value) -> anyhow::Result<Value> {
        let payload = json!({
            "task": "summarize_logs",
            "logs": logs
        });
        self.llm.query_structured(&payload)
    }
}
