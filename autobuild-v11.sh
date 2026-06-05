#!/bin/bash
set -e

echo "[ZDOS v11] 🜂 AUTOBUILD — organismo vivente in evoluzione"

# ---------------------------------------------------------
# 0) FUNZIONE MAGICA: autocrea file se mancanti
# ---------------------------------------------------------
ensure() {
    local path="$1"
    local content="$2"

    if [ ! -f "$path" ]; then
        echo "[MAGIA] Creo $path"
        mkdir -p "$(dirname "$path")"
        echo "$content" > "$path"
    fi
}

# ---------------------------------------------------------
# 1) CARGO.TOML — workspace coerente
# ---------------------------------------------------------
echo "[v11] Patch Cargo.toml…"

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

# ---------------------------------------------------------
# 2) ZVM v2 — call stack + frame
# ---------------------------------------------------------
echo "[v11] ZVM v2…"

ensure zvm/src/opcode.rs "
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
    Call(String),
    Ret,
    Halt,
}
"

ensure zvm/src/frame.rs "
#[derive(Debug, Clone)]
pub struct Frame {
    pub return_ip: usize,
}
"

ensure zvm/src/stack.rs "
#[derive(Debug)]
pub struct Stack {
    inner: Vec<f64>,
}

impl Stack {
    pub fn new() -> Self { Self { inner: Vec::new() } }
    pub fn push(&mut self, v: f64) { self.inner.push(v); }
    pub fn pop(&mut self) -> f64 { self.inner.pop().unwrap_or(0.0) }
}
"

ensure zvm/src/vm.rs "
use std::collections::HashMap;
use crate::opcode::Opcode;
use crate::bytecode::BytecodeProgram;
use crate::stack::Stack;
use crate::frame::Frame;

pub struct ZVM {
    pub ip: usize,
    pub stack: Stack,
    pub vars: HashMap<String, f64>,
    pub callstack: Vec<Frame>,
}

impl ZVM {
    pub fn new() -> Self {
        Self {
            ip: 0,
            stack: Stack::new(),
            vars: HashMap::new(),
            callstack: Vec::new(),
        }
    }

    pub fn run(&mut self, program: &BytecodeProgram) -> f64 {
        self.ip = 0;

        loop {
            if self.ip >= program.code.len() { break; }

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
                Opcode::Call(_func) => {
                    self.callstack.push(Frame { return_ip: self.ip + 1 });
                }
                Opcode::Ret => {
                    if let Some(frame) = self.callstack.pop() {
                        self.ip = frame.return_ip;
                        continue;
                    } else {
                        break;
                    }
                }
                Opcode::Halt => break,
            }

            self.ip += 1;
        }

        self.stack.pop()
    }
}
"

ensure zvm/src/bytecode.rs "
use serde::{Serialize, Deserialize};
use crate::opcode::Opcode;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BytecodeProgram {
    pub code: Vec<Opcode>,
}
"

ensure zvm/src/lib.rs "
pub mod opcode;
pub mod bytecode;
pub mod vm;
pub mod stack;
pub mod frame;

pub fn zvm_init() {
    println!(\"[ZVM v2] init\");
}
"

# ---------------------------------------------------------
# 3) ZLANG v2 — funzioni, parametri, return
# ---------------------------------------------------------
echo "[v11] ZLANG v2…"

ensure zlang/src/ast.rs "
use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Expr {
    Number(f64),
    Ident(String),
    Binary { op: String, left: Box<Expr>, right: Box<Expr> },
    Call { name: String, args: Vec<Expr> },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Statement {
    Let { name: String, value: Expr },
    Expr(Expr),
    Func { name: String, params: Vec<String>, body: Vec<Statement> },
    Return(Expr),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Program {
    pub statements: Vec<Statement>,
}
"

ensure zlang/src/parser.rs "
use crate::ast::*;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum ParseError {
    #[error(\"unexpected end of input\")]
    Eof,
    #[error(\"invalid token: {0}\")]
    InvalidToken(String),
}

pub struct Parser {
    tokens: Vec<String>,
    pos: usize,
}

impl Parser {
    pub fn new(input: &str) -> Self {
        let tokens = input.split_whitespace().map(|s| s.to_string()).collect();
        Self { tokens, pos: 0 }
    }

    fn next(&mut self) -> Option<String> {
        if self.pos >= self.tokens.len() { None }
        else {
            let t = self.tokens[self.pos].clone();
            self.pos += 1;
            Some(t)
        }
    }

    pub fn parse(&mut self) -> Result<Program, ParseError> {
        let mut statements = Vec::new();

        while let Some(tok) = self.next() {
            if tok == \"let\" {
                let name = self.next().ok_or(ParseError::Eof)?;
                let _eq = self.next().ok_or(ParseError::Eof)?;
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

        if tok == \"+\" || tok == \"-\" || tok == \"*\" || tok == \"/\" {
            let left = self.parse_expr()?;
            let right = self.parse_expr()?;
            return Ok(Expr::Binary { op: tok, left: Box::new(left), right: Box::new(right) });
        }

        Ok(Expr::Ident(tok))
    }
}
"

ensure zlang/src/compiler.rs "
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
            Statement::Expr(expr) => compile_expr(expr, &mut code),
            _ => {}
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
                \"+\" => out.push(Opcode::Add),
                \"-\" => out.push(Opcode::Sub),
                \"*\" => out.push(Opcode::Mul),
                \"/\" => out.push(Opcode::Div),
                _ => {}
            }
        }
        Expr::Call { name, .. } => {
            out.push(Opcode::Call(name.clone()));
        }
    }
}
"

ensure zlang/src/lib.rs "
pub mod ast;
pub mod parser;
pub mod runtime;
pub mod compiler;

pub fn zlang_init() {
    println!(\"[ZLANG v2] init\");
}
"

# ---------------------------------------------------------
# 4) CORE v2 — scheduler + executor
# ---------------------------------------------------------
echo "[v11] CORE v2…"

ensure core/src/zvm_executor.rs "
use serde_json::Value;
use zdos_zlang::{parser::Parser, compiler::compile};
use zdos_zvm::vm::ZVM;

pub fn exec_zlang_in_core(src: &str) -> Value {
    let mut parser = Parser::new(src);
    let program = match parser.parse() {
        Ok(p) => p,
        Err(e) => return Value::String(format!(\"parse error: {e}\")),
    };

    let bytecode = compile(&program);

    let mut vm = ZVM::new();
    let result = vm.run(&bytecode);

    serde_json::json!({
        \"result\": result,
        \"vars\": vm.vars
    })
}
"

ensure core/src/scheduler.rs "
use serde_json::Value;

pub fn schedule_biosignal(signal: &Value) {
    println!(\"[CORE][SCHEDULER] received signal: {signal}\");
}
"

ensure core/src/lib.rs "
pub mod zvm_executor;
pub mod scheduler;

pub fn core_init() {
    println!(\"[CORE v2] init\");
}
"

# ---------------------------------------------------------
# 5) CORTEX v2 — neural mutation engine
# ---------------------------------------------------------
echo "[v11] CORTEX v2…"

ensure cortex/src/policy.rs "
use serde_json::Value;

pub fn allow_mutation(_signal: &Value) -> bool {
    true
}
"

ensure cortex/src/zlang_adapter.rs "
use serde_json::Value;
use zdos_zlang::{parser::Parser, compiler::compile};
use zdos_zvm::vm::ZVM;

pub fn run_zlang_vm(src: &str) -> Value {
    let mut parser = Parser::new(src);
    let program = match parser.parse() {
        Ok(p) => p,
        Err(e) => return serde_json::json!({ \"error\": format!(\"parse error: {e}\") }),
    };

    let bytecode = compile(&program);

    let mut vm = ZVM::new();
    let result = vm.run(&bytecode);

    serde_json::json!({
        \"result\": result,
        \"vars\": vm.vars
    })
}
"

ensure cortex/src/bytecode_mutator.rs "
use zdos_zvm::bytecode::BytecodeProgram;
use zdos_zvm::opcode::Opcode;

pub fn mutate_bytecode(program: &mut BytecodeProgram) {
    if let Some(last) = program.code.last_mut() {
        *last = Opcode::Add;
    }
}
"

ensure cortex/src/mutation_engine.rs "
use serde_json::Value;
use crate::zlang_adapter::run_zlang_vm;
use crate::bytecode_mutator::mutate_bytecode;
use crate::policy::allow_mutation;

pub struct MutationEngine;

impl MutationEngine {
    pub fn new() -> Self { Self }

    pub async fn mutate(&self, signal: &Value) -> Value {
        if !allow_mutation(signal) {
            return serde_json::json!({ \"status\": \"blocked\" });
        }

        if let Some(src) = signal.get(\"zlang\").and_then(|v| v.as_str()) {
            return run_zlang_vm(src);
        }

        if let Some(bytecode) = signal.get(\"bytecode\") {
            let mut program: zdos_zvm::bytecode::BytecodeProgram =
                serde_json::from_value(bytecode.clone()).unwrap_or_default();

            mutate_bytecode(&mut program);

            return serde_json::json!({ \"mutated\": program });
        }

        serde_json::json!({ \"status\": \"noop\" })
    }
}
"

ensure cortex/src/lib.rs "
pub mod backend;
pub mod mutation_engine;
pub mod policy;
pub mod zlang_adapter;
pub mod bytecode_mutator;

pub fn cortex_init() {
    println!(\"[CORTEX v2] init\");
}
"

# ---------------------------------------------------------
# 6) organism-bin v2 — self-test
# ---------------------------------------------------------
echo "[v11] organism-bin v2…"

ensure organism-bin/src/main.rs "
use serde_json::json;
use zdos_core::{core_init, zvm_executor::exec_zlang_in_core, scheduler::schedule_biosignal};
use zdos_cortex::{cortex_init, mutation_engine::MutationEngine};
use zdos_zlang::{parser::Parser, compiler::compile};
use zdos_zvm::{vm::ZVM, bytecode::BytecodeProgram};

#[tokio::main]
async fn main() {
    println!(\"[ZDOS v11] organism boot\");

    core_init();
    cortex_init();

    let engine = MutationEngine::new();

    let src = \"let x = 10 let y = x + 32\";

    let core_exec = exec_zlang_in_core(src);
    println!(\"[CORE][EXEC] {core_exec}\");

    let signal = json!({ \"zlang\": src });
    let cortex_exec = engine.mutate(&signal).await;
    println!(\"[CORTEX][EXEC] {cortex_exec}\");

    let signal2 = json!({ \"bytecode\": compile(&Parser::new(src).parse().unwrap()) });
    let mutated = engine.mutate(&signal2).await;
    println!(\"[CORTEX][MUTATED] {mutated}\");

    schedule_biosignal(&json!({ \"kind\": \"boot\" }));
}
"

# ---------------------------------------------------------
# 7) BUILD
# ---------------------------------------------------------
echo "[v11] BUILD…"
cargo build

echo "[ZDOS v11] 🜂 COMPLETATO — l’organismo è vivo."
