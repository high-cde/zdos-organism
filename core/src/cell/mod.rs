use async_trait::async_trait;
use crate::bio::signal::BioSignal;
use crate::bus::BioBus;
use tokio::sync::mpsc::Sender;

pub struct CellContext {
    pub bus: Sender<BioSignal>,
}

#[async_trait]
pub trait Cell: Send + Sync {
    fn name(&self) -> &str;
    async fn on_signal(&self, ctx: &CellContext, sig: BioSignal);
}
