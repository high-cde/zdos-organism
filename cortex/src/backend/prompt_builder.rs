use serde_json::Value;

pub fn build_prompt_from_signal(signal: &Value) -> String {
    format!("[ZDOS] SIGNAL: {}", signal)
}
