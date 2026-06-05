#!/bin/bash
set -e

echo "[AUTOBUILD FIX] 🔧 Patch esportazioni moduli ZDOS"

# ---------------------------------------------------------
# 1) FIX: zdos-core deve esportare zvm_executor
# ---------------------------------------------------------
echo "[CORE] Patch lib.rs…"

cat > core/src/lib.rs << 'EOF'
pub mod zvm_executor;

pub fn core_init() {
    println!("[CORE] init");
}
EOF

# ---------------------------------------------------------
# 2) FIX: zdos-cortex deve esportare bytecode_mutator
# ---------------------------------------------------------
echo "[CORTEX] Patch lib.rs…"

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

# ---------------------------------------------------------
# 3) FIX: zdos-zvm deve essere un crate valido
# ---------------------------------------------------------
echo "[ZVM] Patch lib.rs…"

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
# 4) FIX: zdos-zlang deve esportare compiler
# ---------------------------------------------------------
echo "[ZLANG] Patch lib.rs…"

cat > zlang/src/lib.rs << 'EOF'
pub mod ast;
pub mod parser;
pub mod runtime;
pub mod compiler;

pub fn zlang_init() {
    println!("[ZLANG] init");
}
EOF

# ---------------------------------------------------------
# 5) Ricompilazione totale
# ---------------------------------------------------------
echo "[BUILD] Ricompilo tutto…"
cargo build

echo "[AUTOBUILD FIX] ✅ COMPLETATO"
