#!/bin/bash
set -e

echo "[ZDOS v10] 🚀 AUTOBUILD organism completo"

mkdir -p core/src cortex/src cortex/src/backend zlang/src zvm/src organism-bin/src

echo "[v10] Patch Cargo.toml…"

cat > core/Cargo.toml << 'EOF'
[package]
name = "zdos-core"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"
zdos-zlang = { path = "../zlang" }
zdos-zvm = { path = "../zvm" }
EOF

cat > cortex/Cargo.toml << 'EOF'
[package]
name = "zdos-cortex"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"
tokio = { version = "1", features = ["full"] }
zdos-zlang = { path = "../zlang" }
zdos-zvm = { path = "../zvm" }
EOF

cat > zlang/Cargo.toml << 'EOF'
[package]
name = "zdos-zlang"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"
thiserror = "1"
zdos-zvm = { path = "../zvm" }
EOF

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

cat > organism-bin/Cargo.toml << 'EOF'
[package]
name = "organism-bin"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["full"] }
serde_json = "1"
zdos-core = { path = "../core" }
zdos-cortex = { path = "../cortex" }
zdos-zlang = { path = "../zlang" }
zdos-zvm = { path = "../zvm" }
EOF

echo "[v10] ZVM…"

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

echo "[v10] ZLANG…"

cat > zlang/src/ast.rs << 'EOF'
use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Expr {
    Number(f64),
    Ident(String),
    Binary {
        op: String,
        left: Box<Expr>,
        right: Box<Expr>,
    },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Statement {
    Let {
        name: String,
        value: Expr,
    },
    Expr(Expr),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Program {
    pub statements: Vec<Statement>,
}
EOF

cat > zlang/src/parser.rs << 'EOF'
use crate::ast::*;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum ParseError {
    #[error("unexpected end of input")]
    Eof,
    #[error("invalid token: {0}")]
    InvalidToken(String),
}

pub struct Parser {
    tokens: Vec<String>,
    pos: usize,
}

impl Parser {
    pub fn new(input: &str) -> Self {
        let tokens = input
            .split_whitespace()
            .map(|s| s.to_string())
            .collect::<Vec<_>>();

        Self { tokens, pos: 0 }
    }

    fn next(&mut self) -> Option<String> {
        if self.pos >= self.tokens.len() {
            None
        } else {
            let t = self.tokens[self.pos].clone();
            self.pos += 1;
            Some(t)
        }
    }

    pub fn parse(&mut self) -> Result<Program, ParseError> {
        let mut statements = Vec::new();

        while let Some(tok) = self.next() {
            if tok == "let" {
                let name = self.next().ok_or(ParseError::Eof)?;
                let eq = self.next().ok_or(ParseError::Eof)?;
                if eq != "=" {
                    return Err(ParseError::InvalidToken(eq));
                }
                let value = self.parse_expr()?;
                statements.push(Statement::Let { name, value });
            } else {
                self.pos -= 1;
                let expr = self.parse_expr()?;
                statements.push(Statement::Expr(expr));
            }
        }

        Ok(Program { statements })
    }

    fn parse_expr(&mut self) -> Result<Expr, ParseError> {
        let tok = self.next().ok_or(ParseError::Eof)?;

        if let Ok(n) = tok.parse::<f64>() {
            return Ok(Expr::Number(n));
        }

        if tok == "+" || tok == "-" || tok == "*" || tok == "/" {
            let left = self.parse_expr()?;
            let right = self.parse_expr()?;
            return Ok(Expr::Binary {
                op: tok,
                left: Box::new(left),
                right: Box::new(right),
            });
        }

        Ok(Expr::Ident(tok))
    }
}
EOF

cat > zlang/src/runtime.rs << 'EOF'
use crate::ast::*;
use serde_json::json;
use std::collections::HashMap;

pub struct Runtime {
    pub vars: HashMap<String, f64>,
}

impl Runtime {
    pub fn new() -> Self {
        Self { vars: HashMap::new() }
    }

    pub fn eval_program(&mut self, program: &Program) -> serde_json::Value {
        let mut last = json!(null);

        for stmt in &program.statements {
            last = self.eval_statement(stmt);
        }

        last
    }

    fn eval_statement(&mut self, stmt: &Statement) -> serde_json::Value {
        match stmt {
            Statement::Let { name, value } => {
                let v = self.eval_expr(value);
                self.vars.insert(name.clone(), v);
                json!({ "let": name, "value": v })
            }
            Statement::Expr(expr) => {
                let v = self.eval_expr(expr);
                json!({ "expr": v })
            }
        }
    }

    fn eval_expr(&mut self, expr: &Expr) -> f64 {
        match expr {
            Expr::Number(n) => *n,
            Expr::Ident(name) => *self.vars.get(name).unwrap_or(&0.0),
            Expr::Binary { op, left, right } => {
                let l = self.eval_expr(left);
                let r = self.eval_expr(right);
                match op.as_str() {
                    "+" => l + r,
                    "-" => l - r,
                    "*" => l * r,
                    "/" => l / r,
                    _ => 0.0,
                }
            }
        }
    }
}
EOF

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

cat > zlang/src/lib.rs << 'EOF'
pub mod ast;
pub mod parser;
pub mod runtime;
pub mod compiler;

pub fn zlang_init() {
    println!("[ZLANG] init");
}
EOF

echo "[v10] CORE…"

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

cat > core/src/scheduler.rs << 'EOF'
use serde_json::Value;

pub fn schedule_biosignal(signal: &Value) {
    println!("[CORE][SCHEDULER] received signal: {signal}");
}
EOF

cat > core/src/lib.rs << 'EOF'
pub mod zvm_executor;
pub mod scheduler;

pub fn core_init() {
    println!("[CORE] init");
}
EOF

echo "[v10] CORTEX…"

cat > cortex/src/zlang_adapter.rs << 'EOF'
use serde_json::Value;
use zdos_zlang::{parser::Parser, compiler::compile};
use zdos_zvm::vm::ZVM;

pub fn run_zlang_vm(src: &str) -> Value {
    let mut parser = Parser::new(src);
    let program = match parser.parse() {
        Ok(p) => p,
        Err(e) => {
            return serde_json::json!({
                "error": format!("parse error: {e}")
            });
        }
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

cat > cortex/src/bytecode_mutator.rs << 'EOF'
use zdos_zvm::bytecode::BytecodeProgram;
use zdos_zvm::opcode::Opcode;

pub fn mutate_bytecode(program: &mut BytecodeProgram) {
    if let Some(last) = program.code.last_mut() {
        *last = Opcode::Add;
    }
}
EOF

cat > cortex/src/lib.rs << 'EOF'
pub mod backend;
pub mod mutation_engine;
pub mod policy;
pub mod zlang_adapter;
pub mod bytecode_mutator;

pub fn cortex_init() {
    println!("[CORTEX] init");
}
EOF

echo "[v10] organism-bin main…"

cat > organism-bin/src/main.rs << 'EOF'
use serde_json::json;
use zdos_core::{core_init, zvm_executor::exec_zlang_in_core, scheduler::schedule_biosignal};
use zdos_cortex::{cortex_init, zlang_adapter::run_zlang_vm, bytecode_mutator::mutate_bytecode};
use zdos_zlang::{parser::Parser, compiler::compile};
use zdos_zvm::{vm::ZVM, bytecode::BytecodeProgram};

#[tokio::main]
async fn main() {
    println!("[ZDOS] organism boot v10");

    core_init();
    cortex_init();

    let src = "let x = 10 let y = x + 32";

    let core_exec = exec_zlang_in_core(src);
    println!("[CORE][EXEC] {core_exec}");

    let vm_exec = run_zlang_vm(src);
    println!("[CORTEX][ZVM] {vm_exec}");

    let mut parser = Parser::new(src);
    let program = parser.parse().unwrap();
    let mut bytecode: BytecodeProgram = compile(&program);

    mutate_bytecode(&mut bytecode);

    let mut vm = ZVM::new();
    let mutated = vm.run(&bytecode);
    println!("[CORTEX][MUTATED BYTECODE RESULT] {mutated}");

    let signal = json!({ "kind": "biosignal", "payload": { "src": src } });
    schedule_biosignal(&signal);
}
EOF

echo "[v10] BUILD…"
cargo build

echo "[ZDOS v10] ✅ COMPLETATO"
