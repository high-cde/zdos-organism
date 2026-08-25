use cortex::hyper_cortex::HyperCortex;
use serde_json::Value;

pub fn process_with_cortex(signal: Value) -> Value {
    let cortex = HyperCortex::new();
    cortex.process(signal)
}
