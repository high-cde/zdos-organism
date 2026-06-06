use serde_json::Value;
use serde_json::json;

pub struct ZVMExecutor;

impl ZVMExecutor {
    pub fn new() -> Self {
        ZVMExecutor
    }

    pub fn execute(&self, input: Value) -> Value {
        json!({
            "zvm_status": "ok",
            "input": input
        })
    }
}
