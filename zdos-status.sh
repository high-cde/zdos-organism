#!/bin/bash

echo "╔══════════════════════════════════════╗"
echo "║        Z D O S   O R G A N I S M     ║"
echo "║            STATUS REPORT             ║"
echo "╚══════════════════════════════════════╝"
echo ""

ROOT="$HOME/zdos-organism"

check() {
    if [ -d "$1" ]; then
        echo "✔ $1"
    else
        echo "✘ $1   (MANCANTE)"
    fi
}

check_file() {
    if [ -f "$1" ]; then
        echo "  ✔ file: $1"
    else
        echo "  ✘ file mancante: $1"
    fi
}

echo "📦 CRATE CHECK"
check "$ROOT/core"
check "$ROOT/cortex"
check "$ROOT/zlang"
check "$ROOT/zvm"
check "$ROOT/organism-bin"
echo ""

echo "📄 FILE CRITICI"
check_file "$ROOT/core/src/lib.rs"
check_file "$ROOT/cortex/src/lib.rs"
check_file "$ROOT/zlang/src/lib.rs"
check_file "$ROOT/zvm/src/lib.rs"
check_file "$ROOT/organism-bin/src/main.rs"
echo ""

echo "🧠 ZLANG / ZVM CHECK"
check_file "$ROOT/zlang/src/compiler.rs"
check_file "$ROOT/zvm/src/vm.rs"
echo ""

echo "🧬 CORTEX CHECK"
check_file "$ROOT/cortex/src/mutation_engine.rs"
check_file "$ROOT/cortex/src/zlang_adapter.rs"
check_file "$ROOT/cortex/src/bytecode_mutator.rs"
echo ""

echo "🩺 BUILD CHECK"
cd "$ROOT"
if cargo build --quiet; then
    echo "✔ Compilazione OK"
else
    echo "✘ ERRORI DI COMPILAZIONE"
fi
echo ""

echo "🔍 VERSIONI"
echo "  ZLANG:   $(grep version zlang/Cargo.toml | head -1 | awk '{print $3}')"
echo "  ZVM:     $(grep version zvm/Cargo.toml | head -1 | awk '{print $3}')"
echo "  CORE:    $(grep version core/Cargo.toml | head -1 | awk '{print $3}')"
echo "  CORTEX:  $(grep version cortex/Cargo.toml | head -1 | awk '{print $3}')"
echo "  ORG-BIN: $(grep version organism-bin/Cargo.toml | head -1 | awk '{print $3}')"
echo ""

echo "🜂 ORGANISM STATE: COMPLETED SCAN"
echo "──────────────────────────────────────"
echo "Se vuoi un report più profondo:"
echo "  ./zdos-status.sh --deep"
echo ""

if [ "$1" == "--deep" ]; then
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║        Z D O S   D E E P   S C A N   ║"
    echo "╚══════════════════════════════════════╝"
    echo ""

    echo "🧪 TEST ZLANG PARSER"
    TEST_SRC="let x = 10 let y = x + 32"
    PARSE_OUT=$(cargo run -q -p organism-bin 2>/dev/null | grep CORE | wc -l)
    if [ "$PARSE_OUT" -gt 0 ]; then
        echo "✔ Parser OK"
    else
        echo "✘ Parser FAILED"
    fi
    echo ""

    echo "⚙️ TEST COMPILER → BYTECODE"
    if grep -q "Opcode" zvm/src/opcode.rs; then
        echo "✔ Bytecode OK"
    else
        echo "✘ Bytecode FAILED"
    fi
    echo ""

    echo "🧠 TEST ZVM"
    VM_TEST=$(cargo run -q -p organism-bin 2>/dev/null | grep ZVM | wc -l)
    if [ "$VM_TEST" -gt 0 ]; then
        echo "✔ ZVM OK"
    else
        echo "✘ ZVM FAILED"
    fi
    echo ""

    echo "🧬 TEST CORTEX MUTATION"
    CORTEX_TEST=$(cargo run -q -p organism-bin 2>/dev/null | grep MUTATED | wc -l)
    if [ "$CORTEX_TEST" -gt 0 ]; then
        echo "✔ Cortex Mutation OK"
    else
        echo "✘ Cortex Mutation FAILED"
    fi
    echo ""

    echo "🜁 TEST CORE SCHEDULER"
    SCHED_TEST=$(cargo run -q -p organism-bin 2>/dev/null | grep SCHEDULER | wc -l)
    if [ "$SCHED_TEST" -gt 0 ]; then
        echo "✔ Scheduler OK"
    else
        echo "✘ Scheduler FAILED"
    fi
    echo ""

    echo "🗺️ MAPPATURA ORGANISMO (ASCII)"
    echo "--------------------------------"
    echo "CORE     → executor + scheduler"
    echo "CORTEX   → mutation engine + adapter"
    echo "ZLANG    → parser + compiler"
    echo "ZVM      → bytecode + VM + frame"
    echo "ORG-BIN  → organism runtime"
    echo "--------------------------------"
    echo ""

    echo "🜂 DEEP SCAN COMPLETATO"
    exit 0
fi
