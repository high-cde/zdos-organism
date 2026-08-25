use crate::opcode::Opcode;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BytecodeProgram {
    pub code: Vec<Opcode>,
}
