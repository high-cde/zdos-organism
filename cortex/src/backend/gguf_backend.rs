use serde_json::Value;

pub struct GgufBackend {
    pub model_path: String,
}

impl GgufBackend {
    pub fn new(model_path: &str) -> Self {
        Self { model_path: model_path.to_string() }
    }

    pub async fn infer(&self, prompt: &str) -> Value {
        serde_json::json!({
            "model": self.model_path,
            "prompt": prompt,
            "response": "stubbed-response"
        })
    }
}
