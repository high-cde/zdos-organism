use serde_json::Value;
use serde_json::json;
use zdos_cortex::hyper_cortex::HyperCortex;

pub fn process_with_cortex(signal: Value) -> Value {
    let cortex = HyperCortex::new();
    cortex.process(signal)
}
