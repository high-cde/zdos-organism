use serde::{Serialize, Deserialize};
use serde_json::Value;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum BioSignalKind {
    Sense,
    Act,
    Mutate,
    Alert,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EnergyProfile {
    pub cost: u8,
}

impl EnergyProfile {
    pub const Balanced: EnergyProfile = EnergyProfile { cost: 5 };
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BioSignal {
    pub id: String,
    pub from: String,
    pub to: Option<String>,
    pub kind: BioSignalKind,
    pub payload: Value,
    pub energy: EnergyProfile,
    pub priority: u16,
}
