#!/bin/bash
set -e

echo "[AUTOBUILD FIX v2] 🔧 Patch totale dei Cargo.toml e moduli ZDOS"

# ---------------------------------------------------------
# 1) PATCH CARGO.TOML — LINKA TUTTI I CRATE
# ---------------------------------------------------------

echo "[PATCH] zdos-core Cargo.toml"
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

echo "[PATCH] zdos-cortex Cargo.toml"
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

echo "[PATCH] zdos-zlang Cargo.toml"
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

echo "[PATCH] zdos-zvm Cargo.toml"
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

echo "[PATCH] organism-bin Cargo.toml"
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
# 2) PATCH LIB.RS — ESPORTA I MODULI
# ---------------------------------------------------------

echo "[PATCH] zdos-core lib.rs"
cat > core/src/lib.rs << 'EOF'
pub mod zvm_executor;

pub fn core_init() {
    println!("[CORE] init");
}
EOF

echo "[PATCH] zdos-cortex lib.rs"
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

echo "[PATCH] zdos-zlang lib.rs"
cat > zlang/src/lib.rs << 'EOF'
pub mod ast;
pub mod parser;
pub mod runtime;
pub mod compiler;

pub fn zlang_init() {
    println!("[ZLANG] init");
}
EOF

echo "[PATCH] zdos-zvm lib.rs"
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
# 3) BUILD COMPLETO
# ---------------------------------------------------------

echo "[BUILD] 🔨 Ricompilazione totale workspace…"
cargo build

echo "[AUTOBUILD FIX v2] ✅ COMPLETATO — Tutti i crate ora sono linkati correttamente."
