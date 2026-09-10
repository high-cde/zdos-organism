use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Opcode {
    Push(f64),
    Load(String),
    Store(String),
    Add,
    Sub,
    Mul,
    Div,
    Greater,
    Less,
    GreaterEqual,
    LessEqual,
    Jump(usize),
    JumpIfFalse(usize),
    Halt,
}
