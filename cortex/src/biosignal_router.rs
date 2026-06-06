use serde_json::Value;
use serde_json::json;
use crate::hyper_cortex::HyperCortex;

pub struct BioSignalRouter;

impl BioSignalRouter {
    pub fn new() -> Self {
        BioSignalRouter
    }

    pub fn route(&self, signal: Value) -> Value {
        let cortex = HyperCortex::new();
        cortex.process(signal)
    }
}
