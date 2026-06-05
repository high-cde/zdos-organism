use std::collections::HashMap;
use crate::opcode::Opcode;
use crate::bytecode::BytecodeProgram;
use crate::stack::Stack;

pub struct ZVM {
    pub ip: usize,
    pub stack: Stack,
    pub vars: HashMap<String, f64>,
}

impl ZVM {
    pub fn new() -> Self {
        Self {
            ip: 0,
            stack: Stack::new(),
            vars: HashMap::new(),
        }
    }

    pub fn run(&mut self, program: &BytecodeProgram) -> f64 {
        self.ip = 0;

        loop {
            if self.ip >= program.code.len() {
                break;
            }

            match &program.code[self.ip] {
                Opcode::Push(v) => self.stack.push(*v),
                Opcode::Load(name) => {
                    let v = *self.vars.get(name).unwrap_or(&0.0);
                    self.stack.push(v);
                }
                Opcode::Store(name) => {
                    let v = self.stack.pop();
                    self.vars.insert(name.clone(), v);
                }
                Opcode::Add => {
                    let b = self.stack.pop();
                    let a = self.stack.pop();
                    self.stack.push(a + b);
                }
                Opcode::Sub => {
                    let b = self.stack.pop();
                    let a = self.stack.pop();
                    self.stack.push(a - b);
                }
                Opcode::Mul => {
                    let b = self.stack.pop();
                    let a = self.stack.pop();
                    self.stack.push(a * b);
                }
                Opcode::Div => {
                    let b = self.stack.pop();
                    let a = self.stack.pop();
                    self.stack.push(a / b);
                }
                Opcode::Halt => break,
            }

            self.ip += 1;
        }

        self.stack.pop()
    }
}
