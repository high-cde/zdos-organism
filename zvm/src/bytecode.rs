use serde::{Serialize, Deserialize};
use crate::opcode::Opcode;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BytecodeProgram {
    pub code: Vec<Opcode>,
}
