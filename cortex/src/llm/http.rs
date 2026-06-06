use anyhow::Result;
use crate::llm::interface::LLMInterface;
use std::env;

pub struct HttpLLM {
    pub url: String,
}

impl HttpLLM {
    pub fn new(default_url: &str) -> Self {
        let url = env::var("ZDOS_LLM_URL").unwrap_or_else(|_| default_url.to_string());
        Self { url }
    }
}

impl LLMInterface for HttpLLM {
    fn complete(&self, prompt: &str) -> Result<String> {
        let client = reqwest::blocking::Client::new();
        let body = serde_json::json!({ "prompt": prompt });

        let resp = client
            .post(&self.url)
            .json(&body)
            .send()?
            .error_for_status()?
            .text()?;

        Ok(resp)
    }
}
