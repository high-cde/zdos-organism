use serde_json::Value;

#[derive(Debug, Clone)]
pub struct BioSignal {
    pub kind: String,
    pub source: String,
    pub payload: Value,
}

pub fn send_biosignal(signal: &BioSignal) {
    println!("[BUS][SEND] kind={} source={} payload={}",
        signal.kind, signal.source, signal.payload);
}
