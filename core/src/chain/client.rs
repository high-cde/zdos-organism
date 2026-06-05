use serde_json::Value;
use reqwest::Client;

pub const RPC_URL: &str = "http://127.0.0.1:8765";

pub struct ChainClient {
    http: Client,
}

impl ChainClient {
    pub fn new() -> Self {
        Self { http: Client::new() }
    }

    pub async fn latest_block(&self) -> Option<Value> {
        let payload = serde_json::json!({
            "jsonrpc": "2.0",
            "method": "chain_getLatestBlock",
            "params": [],
            "id": 1
        });

        let res = self.http.post(RPC_URL)
            .json(&payload)
            .send()
            .await
            .ok()?;

        res.json::<Value>().await.ok()
    }
}
