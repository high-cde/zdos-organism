#!/bin/bash
set -e

cd ~/zdos-organism

echo "🧠 ZDOS v20+MAGIA — FULL BOOT"

echo "[1/3] BUILD COMPLETO…"
cargo build

echo "[2/3] STATUS…"
./zdos-status.sh --deep || true

echo "[3/3] AVVIO ORGANISMO…"
cargo run -p organism-bin

echo "✅ ZDOS v20+MAGIA ONLINE — per ora completo al 100%."
