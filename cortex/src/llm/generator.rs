use serde_json::Value;
use super::interface::LLMInterface;

/// Generator: usa la LLM per generare codice Z-Lang, moduli HyperUniverse, script di orchestrazione.
pub struct ZLangGenerator<'a, T: LLMInterface> {
    llm: &'a T,
}

impl<'a, T: LLMInterface> ZLangGenerator<'a, T> {
    pub fn new(llm: &'a T) -> Self {
        Self { llm }
    }

    /// Genera un modulo Z-Lang a partire da una specifica testuale.
    pub fn generate_module(&self, spec: &str) -> anyhow::Result<String> {
        let prompt = format!(
            "Genera un modulo Z-Lang per ZDOS che rispetti questa specifica:\n{}",
            spec
        );
        self.llm.query_raw(&prompt)
    }

    /// Genera uno script di orchestrazione HyperUniverse.
    pub fn generate_universe_script(&self, universe_spec: &Value) -> anyhow::Result<String> {
        let prompt = format!(
            "Genera uno script di orchestrazione HyperUniverse per questa specifica:\n{}",
            universe_spec
        );
        self.llm.query_raw(&prompt)
    }
}
