#[derive(Debug, Clone)]
pub struct BioPacket {
    pub source: String,
    pub signal: String,
    pub level: f64,
    pub priority: u8,
    pub hint: String,
}

pub struct BioComm;

impl BioComm {
    pub fn send(packet: BioPacket) {
        println!(
            "[BIOCOMM] {} | {} | lvl {:.2} | prio {} | hint: {}",
            packet.source, packet.signal, packet.level, packet.priority, packet.hint
        );
    }
}
