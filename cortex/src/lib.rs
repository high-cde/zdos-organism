pub mod backend;
pub mod mutation_engine;
pub mod policy;
pub mod zlang_adapter;
pub mod bytecode_mutator;
pub mod biosignal_router;

pub fn cortex_init() {
    println!("[CORTEX v2+Hyper] init");
}
