use std::sync::{Arc, RwLock};
use crate::memory::item::MemoryItem;

#[derive(Clone)]
pub struct MemoryStore {
    inner: Arc<RwLock<Vec<MemoryItem>>>,
}

impl MemoryStore {
    pub fn new() -> Self {
        Self { inner: Arc::new(RwLock::new(Vec::new())) }
    }

    pub fn push(&self, item: MemoryItem) {
        if let Ok(mut guard) = self.inner.write() {
            guard.push(item);
        }
    }
}
