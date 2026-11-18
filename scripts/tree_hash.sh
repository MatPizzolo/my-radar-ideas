#!/usr/bin/env bash
# Imprime un hash del árbol de trabajo: archivos trackeados y no trackeados (no ignorados) tal
# como están ahora. Usa un índice de descarte, así el índice real (lo que el dueño tiene en
# stage) nunca se toca. `make ci` lo guarda en `.playbook/ci-ok` al terminar verde y el hook
# `stop_check.py` lo compara con el árbol actual (contratos.md §3). Adaptado de clipforge.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
cp "$(git rev-parse --git-path index)" "$tmp" 2>/dev/null || true
GIT_INDEX_FILE="$tmp" git add -A
GIT_INDEX_FILE="$tmp" git write-tree
