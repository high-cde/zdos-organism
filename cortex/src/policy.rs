use serde_json::Value;

pub fn allow_mutation(signal: &Value) -> bool {
    signal
        .get("block")
        .map(|v| !v.is_null())
        .unwrap_or(false)
}
