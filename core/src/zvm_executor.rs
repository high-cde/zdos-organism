use serde_json::json;
use serde_json::Value;

pub struct ZVMExecutor;

impl Default for ZVMExecutor {
    fn default() -> Self {
        Self::new()
    }
}

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
