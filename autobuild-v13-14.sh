#!/bin/bash
set -e

echo "🧬 Z D O S   A U T O B U I L D   v13+v14"
echo "────────────────────────────────────────"

ROOT="$HOME/zdos-organism"

ensure() {
    local path="$1"
    mkdir -p "$(dirname "$path")"
    cat > "$path"
}

echo "[1/5] BioSignal Bus (CORE)…"

ensure "$ROOT/core/src/biosignal_bus.rs" << 'EOF'
use serde_json::Value;

#[derive(Debug, Clone)]
pub struct BioSignal {
    pub kind: String,
    pub source: String,
    pub payload: Value,
}

pub fn send_biosignal(signal: &BioSignal) {
    println!("[BUS][SEND] kind={} source={} payload={}",
        signal.kind, signal.source, signal.payload);
}
EOF

echo "[2/5] BioSignal Router (CORTEX)…"

ensure "$ROOT/cortex/src/biosignal_router.rs" << 'EOF'
use serde_json::Value;
use crate::mutation_engine::MutationEngine;
use crate::policy::allow_mutation;

pub struct BioSignalRouter {
    engine: MutationEngine,
}

impl BioSignalRouter {
    pub fn new() -> Self {
        Self { engine: MutationEngine::new() }
    }

    pub async fn route(&self, signal: &Value) -> Value {
        if !allow_mutation(signal) {
            return serde_json::json!({ "status": "blocked" });
        }

        // Se è un pensiero Z-Lang
        if signal.get("kind").and_then(|k| k.as_str()) == Some("thought") {
            if let Some(src) = signal.get("zlang").and_then(|v| v.as_str()) {
                return self.engine.mutate(&serde_json::json!({ "zlang": src })).await;
            }
        }

        // Se è mutazione bytecode
        if signal.get("kind").and_then(|k| k.as_str()) == Some("mutation-bytecode") {
            if let Some(bytecode) = signal.get("bytecode") {
                return self.engine.mutate(&serde_json::json!({ "bytecode": bytecode })).await;
            }
        }

        serde_json::json!({ "status": "routed-noop" })
    }
}
EOF

echo "[3/5] HyperCortex AST Mutator (ZLANG)…"

ensure "$ROOT/zlang/src/ast_mutator.rs" << 'EOF'
use crate::ast::{Program, Statement, Expr};

pub fn mutate_ast(program: &mut Program) {
    for stmt in &mut program.statements {
        if let Statement::Let { value, .. } = stmt {
            if let Expr::Number(n) = value {
                *n += 1.0;
            }
        }
    }
}
EOF

echo "[4/5] Patch CORTEX lib + MutationEngine…"

ensure "$ROOT/cortex/src/lib.rs" << 'EOF'
pub mod backend;
pub mod mutation_engine;
pub mod policy;
pub mod zlang_adapter;
pub mod bytecode_mutator;
pub mod biosignal_router;

pub fn cortex_init() {
    println!("[CORTEX v2+Hyper] init");
}
EOF

ensure "$ROOT/cortex/src/mutation_engine.rs" << 'EOF'
use serde_json::Value;
use crate::zlang_adapter::run_zlang_vm;
use crate::bytecode_mutator::mutate_bytecode;
use crate::policy::allow_mutation;
use zdos_zlang::{parser::Parser, ast::Program};
use zdos_zlang::ast_mutator::mutate_ast;

pub struct MutationEngine;

impl MutationEngine {
    pub fn new() -> Self { Self }

    pub async fn mutate(&self, signal: &Value) -> Value {
        if !allow_mutation(signal) {
            return serde_json::json!({ "status": "blocked" });
        }

        // Z-Lang con mutazione semantica (HyperCortex)
        if let Some(src) = signal.get("zlang").and_then(|v| v.as_str()) {
            let mut parser = Parser::new(src);
            let mut program: Program = match parser.parse() {
                Ok(p) => p,
                Err(e) => return serde_json::json!({ "error": format!("parse error: {e}") }),
            };

            mutate_ast(&mut program);
            let mutated_src_result = run_zlang_vm(src);
            return serde_json::json!({
                "status": "hyper-mutated",
                "result": mutated_src_result
            });
        }

        // Bytecode
        if let Some(bytecode) = signal.get("bytecode") {
            let mut program: zdos_zvm::bytecode::BytecodeProgram =
                serde_json::from_value(bytecode.clone()).unwrap_or_default();

            mutate_bytecode(&mut program);

            return serde_json::json!({ "status": "mutated", "program": program });
        }

        serde_json::json!({ "status": "noop" })
    }
}
EOF

echo "[5/5] Patch organism-bin main (usa BioSignal Network)…"

ensure "$ROOT/organism-bin/src/main.rs" << 'EOF'
use serde_json::json;
use zdos_core::{core_init, zvm_executor::exec_zlang_in_core, scheduler::schedule_biosignal};
use zdos_core::biosignal_bus::{BioSignal, send_biosignal};
use zdos_cortex::{cortex_init, mutation_engine::MutationEngine, biosignal_router::BioSignalRouter};
use zdos_zlang::{parser::Parser, compiler::compile};
use zdos_zvm::{vm::ZVM, bytecode::BytecodeProgram};

#[tokio::main]
async fn main() {
    println!("[ZDOS v13+v14] organism boot");

    core_init();
    cortex_init();

    let engine = MutationEngine::new();
    let router = BioSignalRouter::new();

    let src = "let x = 10 let y = x + 32";

    let core_exec = exec_zlang_in_core(src);
    println!("[CORE][EXEC] {core_exec}");

    // Pensiero Z-Lang
    let thought = json!({
        "kind": "thought",
        "source": "organism",
        "zlang": src
    });

    let routed = router.route(&thought).await;
    println!("[CORTEX][ROUTED] {routed}");

    // Bytecode mutato
    let mut parser = Parser::new(src);
    let program = match parser.parse() {
        Ok(p) => p,
        Err(e) => {
            println!("[ORG][ERROR] parse error: {e}");
            return;
        }
    };

    let mut bytecode: BytecodeProgram = compile(&program);
    let mutation_signal = json!({
        "kind": "mutation-bytecode",
        "source": "organism",
        "bytecode": bytecode
    });

    let mutated = router.route(&mutation_signal).await;
    println!("[CORTEX][MUTATED BYTECODE] {mutated}");

    let biosignal = BioSignal {
        kind: "boot".to_string(),
        source: "organism".to_string(),
        payload: json!({ "status": "online" }),
    };
    send_biosignal(&biosignal);
    schedule_biosignal(&json!({ "kind": "boot" }));
}
EOF

echo "[BUILD] Compilo tutto…"
cd "$ROOT"
cargo build

echo "✅ ZDOS v13+v14 — BioSignal Network + HyperCortex attivi."
EOF
