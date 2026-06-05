#!/bin/bash
set -e

echo "[AUTOBUILD ZDOS] 🚀 Evoluzione completa: ZVM + Compiler + CoreExec + CortexMut + Orchestratore"

# ---------------------------------------------------------
# 0) PREPARA STRUTTURE
# ---------------------------------------------------------
mkdir -p zvm/src
mkdir -p zlang/src
mkdir -p cortex/src
mkdir -p cortex/src/backend
mkdir -p core/src

# ---------------------------------------------------------
# 1) ZVM — Virtual Machine completa
# ---------------------------------------------------------
echo "[ZVM] Installazione…"

cat > zvm/Cargo.toml << 'EOF'
[package]
name = "zdos-zvm"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"
thiserror = "1"
EOF

cat > zvm/src/opcode.rs << 'EOF'
use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Opcode {
    Push(f64),
    Load(String),
    Store(String),
    Add,
    Sub,
    Mul,
    Div,
    Halt,
}
EOF

cat > zvm/src/bytecode.rs << 'EOF'
use serde::{Serialize, Deserialize};
use crate::opcode::Opcode;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BytecodeProgram {
    pub code: Vec<Opcode>,
}
EOF

cat > zvm/src/stack.rs << 'EOF'
#[derive(Debug)]
pub struct Stack {
    inner: Vec<f64>,
}

impl Stack {
    pub fn new() -> Self {
        Self { inner: Vec::new() }
    }

    pub fn push(&mut self, v: f64) {
        self.inner.push(v);
    }

    pub fn pop(&mut self) -> f64 {
        self.inner.pop().unwrap_or(0.0)
    }
}
EOF

cat > zvm/src/vm.rs << 'EOF'
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
EOF

cat > zvm/src/lib.rs << 'EOF'
pub mod opcode;
pub mod bytecode;
pub mod vm;
pub mod stack;

pub fn zvm_init() {
    println!("[ZVM] init");
}
EOF

# ---------------------------------------------------------
# 2) ZLANG COMPILER → BYTECODE
# ---------------------------------------------------------
echo "[ZLANG COMPILER] Installazione…"

cat > zlang/src/compiler.rs << 'EOF'
use crate::ast::*;
use zdos_zvm::opcode::Opcode;
use zdos_zvm::bytecode::BytecodeProgram;

pub fn compile(program: &Program) -> BytecodeProgram {
    let mut code = Vec::new();

    for stmt in &program.statements {
        match stmt {
            Statement::Let { name, value } => {
                compile_expr(value, &mut code);
                code.push(Opcode::Store(name.clone()));
            }
            Statement::Expr(expr) => {
                compile_expr(expr, &mut code);
            }
        }
    }

    code.push(Opcode::Halt);

    BytecodeProgram { code }
}

fn compile_expr(expr: &Expr, out: &mut Vec<Opcode>) {
    match expr {
        Expr::Number(n) => out.push(Opcode::Push(*n)),
        Expr::Ident(name) => out.push(Opcode::Load(name.clone())),
        Expr::Binary { op, left, right } => {
            compile_expr(left, out);
            compile_expr(right, out);
            match op.as_str() {
                "+" => out.push(Opcode::Add),
                "-" => out.push(Opcode::Sub),
                "*" => out.push(Opcode::Mul),
                "/" => out.push(Opcode::Div),
                _ => {}
            }
        }
    }
}
EOF

# ---------------------------------------------------------
# 3) CORE → ZVM EXECUTOR
# ---------------------------------------------------------
echo "[CORE EXECUTOR] Installazione…"

cat > core/src/zvm_executor.rs << 'EOF'
use serde_json::Value;
use zdos_zlang::{parser::Parser, compiler::compile};
use zdos_zvm::vm::ZVM;

pub fn exec_zlang_in_core(src: &str) -> Value {
    let mut parser = Parser::new(src);
    let program = match parser.parse() {
        Ok(p) => p,
        Err(e) => return Value::String(format!("parse error: {e}")),
    };

    let bytecode = compile(&program);

    let mut vm = ZVM::new();
    let result = vm.run(&bytecode);

    serde_json::json!({
        "result": result,
        "vars": vm.vars
    })
}
EOF

# ---------------------------------------------------------
# 4) CORTEX → MUTAZIONI BYTECODE
# ---------------------------------------------------------
echo "[CORTEX MUTAZIONI] Installazione…"

cat > cortex/src/bytecode_mutator.rs << 'EOF'
use zdos_zvm::bytecode::BytecodeProgram;
use zdos_zvm::opcode::Opcode;

pub fn mutate_bytecode(program: &mut BytecodeProgram) {
    if let Some(last) = program.code.last_mut() {
        *last = Opcode::Add;
    }
}
EOF

# ---------------------------------------------------------
# 5) ORCHESTRATORE TOTALE
# ---------------------------------------------------------
echo "[ORCHESTRATORE] Installazione…"

cat > organism-bin/src/main.rs << 'EOF'
use serde_json::json;
use zdos_core::zvm_executor::exec_zlang_in_core;
use zdos_cortex::bytecode_mutator::mutate_bytecode;
use zdos_zlang::{parser::Parser, compiler::compile};
use zdos_zvm::vm::ZVM;

#[tokio::main]
async fn main() {
    println!("[ZDOS] organism boot");

    let src = "let x = 10 let y = x + 32";

    let core_exec = exec_zlang_in_core(src);
    println!("[CORE][EXEC] {core_exec}");

    let mut parser = Parser::new(src);
    let program = parser.parse().unwrap();
    let mut bytecode = compile(&program);

    mutate_bytecode(&mut bytecode);

    let mut vm = ZVM::new();
    let mutated = vm.run(&bytecode);

    println!("[CORTEX][MUTATED BYTECODE RESULT] {mutated}");
}
EOF

# ---------------------------------------------------------
# BUILD FINALE
# ---------------------------------------------------------
echo "[BUILD] Compilazione completa…"
cargo build

echo "[AUTOBUILD ZDOS] ✅ COMPLETATO"
