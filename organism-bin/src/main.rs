use serde_json::json;

// CORE
use zdos_core::{
    core_init,
    zvm_executor::exec_zlang_in_core,
    scheduler::schedule_biosignal,
    biosignal_bus::{BioSignal, send_biosignal},
};

// CORTEX
use zdos_cortex::{
    cortex_init,
    mutation_engine::MutationEngine,
    biosignal_router::BioSignalRouter,
};

// ZLANG + ZVM
use zdos_zlang::{parser::Parser, compiler::compile};
use zdos_zvm::bytecode::BytecodeProgram;

#[tokio::main]
async fn main() {
    println!("[ZDOS v13+v14] organism boot");

    // INIT
    core_init();
    cortex_init();

    let engine = MutationEngine::new();
    let router = BioSignalRouter::new();

    // Programma di test
    let src = "let x = 10 let y = x + 32";

    // CORE EXEC
    let core_exec = exec_zlang_in_core(src);
    println!("[CORE][EXEC] {core_exec}");

    // ───────────────────────────────────────────────
    // 1) THOUGHT → routed nel Cortex (HyperCortex AST)
    // ───────────────────────────────────────────────
    let thought = json!({
        "kind": "thought",
        "source": "organism",
        "zlang": src
    });

    let routed = router.route(&thought).await;
    println!("[CORTEX][ROUTED] {routed}");

    // ───────────────────────────────────────────────
    // 2) BYTECODE MUTATION
    // ───────────────────────────────────────────────
    let mut parser = Parser::new(src);
    let program = match parser.parse() {
        Ok(p) => p,
        Err(e) => {
            println!("[ORG][ERROR] parse error: {e}");
            return;
        }
    };

    let bytecode: BytecodeProgram = compile(&program);

    let mutation_signal = json!({
        "kind": "mutation-bytecode",
        "source": "organism",
        "bytecode": bytecode
    });

    let mutated = router.route(&mutation_signal).await;
    println!("[CORTEX][MUTATED BYTECODE] {mutated}");

    // ───────────────────────────────────────────────
    // 3) BIOSIGNAL BUS
    // ───────────────────────────────────────────────
    let biosignal = BioSignal {
        kind: "boot".to_string(),
        source: "organism".to_string(),
        payload: json!({ "status": "online" }),
    };

    send_biosignal(&biosignal);
    schedule_biosignal(&json!({ "kind": "boot" }));

    println!("[ZDOS] organism online.");
}
