use crate::bytecode::BytecodeProgram;
use crate::opcode::Opcode;
use crate::stack::{Stack, StackError};
use std::collections::HashMap;
use thiserror::Error;

#[derive(Debug, Error, PartialEq)]
pub enum VmError {
    #[error(transparent)]
    Stack(#[from] StackError),
    #[error("division by zero")]
    DivisionByZero,
    #[error("instruction limit exceeded: {0}")]
    InstructionLimitExceeded(usize),
    #[error("program did not produce a value")]
    EmptyResult,
}

pub struct ZVM {
    pub ip: usize,
    pub stack: Stack,
    pub vars: HashMap<String, f64>,
    pub max_instructions: usize,
}

impl Default for ZVM {
    fn default() -> Self {
        Self::new()
    }
}

impl ZVM {
    pub fn new() -> Self {
        Self {
            ip: 0,
            stack: Stack::new(),
            vars: HashMap::new(),
            max_instructions: 100_000,
        }
    }

    pub fn with_instruction_limit(max_instructions: usize) -> Self {
        Self {
            max_instructions,
            ..Self::new()
        }
    }

    pub fn run(&mut self, program: &BytecodeProgram) -> Result<f64, VmError> {
        self.ip = 0;
        self.stack = Stack::new();
        let mut executed = 0usize;
        while self.ip < program.code.len() {
            if executed >= self.max_instructions {
                return Err(VmError::InstructionLimitExceeded(self.max_instructions));
            }
            executed += 1;
            match &program.code[self.ip] {
                Opcode::Push(v) => self.stack.push(*v),
                Opcode::Load(name) => self.stack.push(*self.vars.get(name).unwrap_or(&0.0)),
                Opcode::Store(name) => {
                    let value = self.stack.pop()?;
                    self.vars.insert(name.clone(), value);
                }
                Opcode::Add => {
                    let (a, b) = self.stack.pop_pair()?;
                    self.stack.push(a + b);
                }
                Opcode::Sub => {
                    let (a, b) = self.stack.pop_pair()?;
                    self.stack.push(a - b);
                }
                Opcode::Mul => {
                    let (a, b) = self.stack.pop_pair()?;
                    self.stack.push(a * b);
                }
                Opcode::Div => {
                    let (a, b) = self.stack.pop_pair()?;
                    if b == 0.0 {
                        return Err(VmError::DivisionByZero);
                    }
                    self.stack.push(a / b);
                }
                Opcode::Halt => break,
            }
            self.ip += 1;
        }
        self.stack.pop().map_err(|_| VmError::EmptyResult)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::{bytecode::BytecodeProgram, opcode::Opcode};
    #[test]
    fn evaluates_arithmetic() {
        let mut vm = ZVM::new();
        let program = BytecodeProgram {
            code: vec![
                Opcode::Push(2.0),
                Opcode::Push(3.0),
                Opcode::Add,
                Opcode::Halt,
            ],
        };
        assert_eq!(vm.run(&program).unwrap(), 5.0);
    }
    #[test]
    fn rejects_division_by_zero() {
        let mut vm = ZVM::new();
        let program = BytecodeProgram {
            code: vec![
                Opcode::Push(1.0),
                Opcode::Push(0.0),
                Opcode::Div,
                Opcode::Halt,
            ],
        };
        assert_eq!(vm.run(&program), Err(VmError::DivisionByZero));
    }
}
