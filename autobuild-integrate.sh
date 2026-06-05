#!/bin/bash
set -e

echo "[AUTOBUILD] 🔥 Integrazione ZLANG ↔ CORTEX ↔ CORE"

# ---------------------------------------------------------
# 1) Assicura struttura cartelle
# ---------------------------------------------------------
mkdir -p zlang/src
mkdir -p cortex/src
mkdir -p cortex/src/backend

# ---------------------------------------------------------
# 2) Cargo.toml aggiornati
# ---------------------------------------------------------
echo "[AUTOBUILD] Aggiorno Cargo.toml del cortex…"

cat > cortex/Cargo.toml << 'EOF'
[package]
name = "zdos-cortex"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"
async-trait = "0.1"
tokio = { version = "1", features = ["full"] }
uuid = { version = "1", features = ["v4"] }
zdos-zlang = { path = "../zlang" }
EOF

echo "[AUTOBUILD] Aggiorno Cargo.toml organism-bin…"

cat > organism-bin/Cargo.toml << 'EOF'
[package]
name = "organism-bin"
version = "0.1.0"
edition = "2021"

[dependencies]
zdos-core = { path = "../core" }
zdos-cortex = { path = "../cortex" }
zdos-zlang = { path = "../zlang" }
tokio = { version = "1", features = ["full"] }
serde_json = "1"
EOF

# ---------------------------------------------------------
# 3) ZLANG: AST + Parser + Runtime
# ---------------------------------------------------------
echo "[AUTOBUILD] Installo ZLANG (AST + Parser + Runtime)…"

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

cat > zlang/src/lib.rs << 'EOF'
pub mod ast;
pub mod parser;
pub mod runtime;

pub fn zlang_init() {
    println!("[ZLANG] init");
}
EOF

# ---------------------------------------------------------
# 4) CORTEX: Adapter ZLANG
# ---------------------------------------------------------
echo "[AUTOBUILD] Installo adapter ZLANG nel cortex…"

cat > cortex/src/zlang_adapter.rs << 'EOF'
use serde_json::Value;
use zdos_zlang::{ast::Program, parser::Parser, runtime::Runtime};

pub fn run_zlang_source(src: &str) -> Value {
    let mut parser = Parser::new(src);
    let program: Program = match parser.parse() {
        Ok(p) => p,
        Err(e) => {
            return serde_json::json!({
                "error": format!("parse error: {e}")
            });
        }
    };

    let mut rt = Runtime::new();
    rt.eval_program(&program)
}
EOF

# ---------------------------------------------------------
# 5) Aggiorna mutation_engine per usare ZLANG
# ---------------------------------------------------------
echo "[AUTOBUILD] Patch mutation_engine…"

cat > cortex/src/mutation_engine.rs << 'EOF'
use serde_json::Value;
use crate::backend::{gguf_backend::GgufBackend, prompt_builder::build_prompt_from_signal};
use crate::zlang_adapter::run_zlang_source;

pub struct MutationEngine {
    pub backend: GgufBackend,
}

impl MutationEngine {
    pub fn new(model_path: &str) -> Self {
        Self {
            backend: GgufBackend::new(model_path),
        }
    }

    pub async fn mutate(&self, signal: &Value) -> Value {
        let prompt = build_prompt_from_signal(signal);
        self.backend.infer(&prompt).await
    }

    pub fn run_zlang(&self, src: &str) -> Value {
        run_zlang_source(src)
    }
}
EOF

# ---------------------------------------------------------
# 6) organism-bin demo
# ---------------------------------------------------------
echo "[AUTOBUILD] Installo organism-bin demo…"

cat > organism-bin/src/main.rs << 'EOF'
use zdos_cortex::{cortex_init, mutation_engine::MutationEngine};
use serde_json::json;

#[tokio::main]
async fn main() {
    println!("[ZDOS] organism boot");
    cortex_init();

    let engine = MutationEngine::new("models/gguf-stub.gguf");

    let src = "let x = 10 let y = 32 + x";
    let result = engine.run_zlang(src);
    println!("[ZLANG][RESULT] {result}");

    let sig = json!({ "kind": "test", "payload": { "foo": 1 } });
    let mutated = engine.mutate(&sig).await;
    println!("[CORTEX][MUTATED] {mutated}");
}
EOF

# ---------------------------------------------------------
# 7) Build finale
# ---------------------------------------------------------
echo "[AUTOBUILD] Compilo tutto…"
cargo build

echo "[AUTOBUILD] ✅ COMPLETATO"
