use async_trait::async_trait;
use uuid::Uuid;
use serde_json::json;

use crate::bio::signal::{BioSignal, BioSignalKind, EnergyProfile};
use crate::cell::{Cell, CellContext};
use super::client::ChainClient;

pub struct ChainCell {
    pub client: ChainClient,
}

#[async_trait]
impl Cell for ChainCell {
    fn name(&self) -> &str { "chain" }

    async fn on_signal(&self, ctx: &CellContext, sig: BioSignal) {
        if sig.kind == BioSignalKind::Sense {
            if let Some(block) = self.client.latest_block().await {
                let out = BioSignal {
                    id: Uuid::new_v4().to_string(),
                    from: "chain".into(),
                    to: Some("cortex".into()),
                    kind: BioSignalKind::Sense,
                    payload: json!({ "block": block }),
                    energy: EnergyProfile::Balanced,
                    priority: 200,
                };
                let _ = ctx.bus.send(out).await;
            }
        }
    }
}
