use tokio::sync::mpsc::{Sender, Receiver, channel};
use crate::bio::signal::BioSignal;

pub struct BioBus {
    pub tx: Sender<BioSignal>,
    pub rx: Receiver<BioSignal>,
}

impl BioBus {
    pub fn new(buffer: usize) -> Self {
        let (tx, rx) = channel(buffer);
        Self { tx, rx }
    }

    pub fn sender(&self) -> Sender<BioSignal> {
        self.tx.clone()
    }
}
