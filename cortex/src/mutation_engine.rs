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
        // Policy
        if !allow_mutation(signal) {
            return serde_json::json!({ "status": "blocked" });
        }

        // ───────────────────────────────────────────────
        // 1) HYPERCORTEX: Mutazione semantica AST Z‑Lang
        // ───────────────────────────────────────────────
        if let Some(src) = signal.get("zlang").and_then(|v| v.as_str()) {
            let mut parser = Parser::new(src);

            let mut program: Program = match parser.parse() {
                Ok(p) => p,
                Err(e) => {
                    return serde_json::json!({
                        "status": "error",
                        "error": format!("parse error: {e}")
                    });
                }
            };

            // Mutazione semantica AST
            mutate_ast(&mut program);

            // Esegui comunque il codice originale (per ora)
            let exec = run_zlang_vm(src);

            return serde_json::json!({
                "status": "hyper-mutated",
                "ast_mutated": true,
                "exec": exec
            });
        }

        // ───────────────────────────────────────────────
        // 2) MUTAZIONE BYTECODE
        // ───────────────────────────────────────────────
        if let Some(bytecode) = signal.get("bytecode") {
            let mut program: zdos_zvm::bytecode::BytecodeProgram =
                match serde_json::from_value(bytecode.clone()) {
                    Ok(p) => p,
                    Err(_) => zdos_zvm::bytecode::BytecodeProgram { code: vec![] },
                };

            mutate_bytecode(&mut program);

            return serde_json::json!({
                "status": "mutated",
                "program": program
            });
        }

        // ───────────────────────────────────────────────
        // 3) Nessuna mutazione applicabile
        // ───────────────────────────────────────────────
        serde_json::json!({ "status": "noop" })
    }
}
