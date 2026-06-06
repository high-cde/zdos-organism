use anyhow::Result;

pub trait LLMInterface {
    fn complete(&self, prompt: &str) -> Result<String>;
}
