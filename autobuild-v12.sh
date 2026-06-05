#!/bin/bash
set -e

echo "🧠 Z D O S   A U T O B U I L D   v12"
echo "────────────────────────────────────"

ROOT="$HOME/zdos-organism"

# Funzione magica: crea file se mancante
ensure() {
    local path="$1"
    local content="$2"
    if [ ! -f "$path" ]; then
        echo "[MAGIA] Creo $path"
        mkdir -p "$(dirname "$path")"
        echo "$content" > "$path"
    fi
}

echo "[1/6] Patch ZLANG…"

ensure $ROOT/zlang/src/ast.rs "
$(sed 's/^/    /' << 'EOF'
<--- QUI INCOLLA IL CONTENUTO COMPLETO DI ast.rs CHE TI HO DATO --->
EOF
)
"

ensure $ROOT/zlang/src/parser.rs "
$(sed 's/^/    /' << 'EOF'
<--- QUI INCOLLA IL CONTENUTO COMPLETO DI parser.rs CHE TI HO DATO --->
EOF
)
"

ensure $ROOT/zlang/src/compiler.rs "
$(sed 's/^/    /' << 'EOF'
<--- QUI INCOLLA IL CONTENUTO COMPLETO DI compiler.rs CHE TI HO DATO --->
EOF
)
"

ensure $ROOT/zlang/src/runtime.rs "
$(sed 's/^/    /' << 'EOF'
<--- QUI INCOLLA IL CONTENUTO COMPLETO DI runtime.rs CHE TI HO DATO --->
EOF
)
"

ensure $ROOT/zlang/src/lib.rs "
$(sed 's/^/    /' << 'EOF'
<--- QUI INCOLLA IL CONTENUTO COMPLETO DI lib.rs DI ZLANG --->
EOF
)
"

echo "[2/6] Patch ZVM…"

ensure $ROOT/zvm/src/opcode.rs "
$(sed 's/^/    /' << 'EOF'
<--- opcode.rs completo --->
EOF
)
"

ensure $ROOT/zvm/src/frame.rs "
$(sed 's/^/    /' << 'EOF'
<--- frame.rs completo --->
EOF
)
"

ensure $ROOT/zvm/src/stack.rs "
$(sed 's/^/    /' << 'EOF'
<--- stack.rs completo --->
EOF
)
"

ensure $ROOT/zvm/src/bytecode.rs "
$(sed 's/^/    /' << 'EOF'
<--- bytecode.rs completo --->
EOF
)
"

ensure $ROOT/zvm/src/vm.rs "
$(sed 's/^/    /' << 'EOF'
<--- vm.rs completo --->
EOF
)
"

ensure $ROOT/zvm/src/lib.rs "
$(sed 's/^/    /' << 'EOF'
<--- lib.rs completo di ZVM --->
EOF
)
"

echo "[3/6] Patch CORE…"

ensure $ROOT/core/src/zvm_executor.rs "
$(sed 's/^/    /' << 'EOF'
<--- zvm_executor.rs completo --->
EOF
)
"

ensure $ROOT/core/src/scheduler.rs "
$(sed 's/^/    /' << 'EOF'
<--- scheduler.rs completo --->
EOF
)
"

ensure $ROOT/core/src/lib.rs "
$(sed 's/^/    /' << 'EOF'
<--- lib.rs completo di CORE --->
EOF
)
"

echo "[4/6] Patch CORTEX…"

ensure $ROOT/cortex/src/policy.rs "
$(sed 's/^/    /' << 'EOF'
<--- policy.rs completo --->
EOF
)
"

ensure $ROOT/cortex/src/zlang_adapter.rs "
$(sed 's/^/    /' << 'EOF'
<--- zlang_adapter.rs completo --->
EOF
)
"

ensure $ROOT/cortex/src/bytecode_mutator.rs "
$(sed 's/^/    /' << 'EOF'
<--- bytecode_mutator.rs completo --->
EOF
)
"

ensure $ROOT/cortex/src/mutation_engine.rs "
$(sed 's/^/    /' << 'EOF'
<--- mutation_engine.rs completo --->
EOF
)
"

ensure $ROOT/cortex/src/lib.rs "
$(sed 's/^/    /' << 'EOF'
<--- lib.rs completo di CORTEX --->
EOF
)
"

echo "[5/6] Patch ORGANISM-BIN…"

ensure $ROOT/organism-bin/src/main.rs "
$(sed 's/^/    /' << 'EOF'
<--- main.rs completo --->
EOF
)
"

echo "[6/6] BUILD…"
cd $ROOT
cargo build

echo ""
echo "🧠 ZDOS v12 — CERVELLO COMPLETO COMPILATO"
echo "──────────────────────────────────────────"
echo "Per avviare il cervello:"
echo "  cargo run -p organism-bin"
echo ""
