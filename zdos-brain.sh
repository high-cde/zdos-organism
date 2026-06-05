#!/bin/bash
set -e

ROOT="$HOME/zdos-organism"
cd "$ROOT"

echo "🧠 Z D O S   B R A I N   B O O T"
echo "────────────────────────────────"

# 1) Ricostruisci l'organismo (autobuild v11)
if [ -x "$ROOT/autobuild-v11.sh" ]; then
  echo "[1/3] AUTOBUILD v11..."
  ./autobuild-v11.sh
else
  echo "✘ autobuild-v11.sh non trovato o non eseguibile"
  exit 1
fi

# 2) Stato completo (deep scan)
if [ -x "$ROOT/zdos-status.sh" ]; then
  echo ""
  echo "[2/3] ZDOS STATUS --DEEP..."
  ./zdos-status.sh --deep || true
else
  echo "✘ zdos-status.sh non trovato o non eseguibile"
fi

# 3) Accendi il cervello (organism runtime)
echo ""
echo "[3/3] AVVIO ORGANISM-BIN..."
cargo run -p organism-bin

echo ""
echo "🧠 ZDOS BRAIN ONLINE — organismo completo."
