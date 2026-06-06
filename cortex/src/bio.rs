use crate::llm::interface::LLMInterface;
use serde_json::json;
use anyhow::Result;

pub struct ReactiveCortex<L: LLMInterface> {
    llm: L,
}

impl<L: LLMInterface> ReactiveCortex<L> {
    pub fn new(llm: L) -> Self {
        Self { llm }
    }

    pub fn decide(
        &self,
        cpu: f64,
        net_latency: u64,
        io_load: u64,
        height: u64,
    ) -> Result<String> {
        let state = json!({
            "cpu": cpu,
            "net_latency": net_latency,
            "io_load": io_load,
            "height": height
        });

        let prompt = format!(
            "Sei il cortex reattivo di ZDOS. Stato sensori: {}.              Fornisci una singola azione concreta.",
            state
        );

        self.llm.complete(&prompt)
    }
}
