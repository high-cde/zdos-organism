use reqwest::blocking::Client;

pub fn cpu() -> f64 { 0.42 }
pub fn net_latency() -> u64 { 12 }
pub fn io_load() -> u64 { 7 }

pub fn block_height() -> u64 {
    Client::new()
        .get("http://127.0.0.1:8765/height")
        .send()
        .and_then(|r| r.text())
        .ok()
        .and_then(|t| t.parse().ok())
        .unwrap_or(0)
}

pub fn difficulty() -> f64 {
    Client::new()
        .get("http://127.0.0.1:8765/difficulty")
        .send()
        .and_then(|r| r.text())
        .ok()
        .and_then(|t| t.parse().ok())
        .unwrap_or(1.0)
}

pub fn mempool() -> u64 {
    Client::new()
        .get("http://127.0.0.1:8765/mempool")
        .send()
        .and_then(|r| r.text())
        .ok()
        .and_then(|t| t.parse().ok())
        .unwrap_or(0)
}
