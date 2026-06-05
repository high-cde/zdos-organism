use async_trait::async_trait;
use uuid::Uuid;
use crate::bio::signal::{BioSignal, BioSignalKind};
use crate::cell::{Cell, CellContext};
use crate::memory::store::MemoryStore;
use crate::memory::item::MemoryItem;

pub struct MemoryCell {
    pub store: MemoryStore,
}

#[async_trait]
impl Cell for MemoryCell {
    fn name(&self) -> &str { "memory" }

    async fn on_signal(&self, _ctx: &CellContext, sig: BioSignal) {
        if sig.kind == BioSignalKind::Sense {
            let item = MemoryItem {
                id: Uuid::new_v4().to_string(),
                kind: "sense".into(),
                data: sig.payload,
            };
            self.store.push(item);
        }
    }
}
