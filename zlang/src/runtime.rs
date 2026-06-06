use serde_json::json;
use serde_json::Value;

pub fn execute(code: &str) -> Value {
    json!({
        "zlang_code": code,
        "status": "ok"
    })
}
