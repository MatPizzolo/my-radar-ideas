#!/usr/bin/env bash
# `make doctor`: checks that this machine can work on the project. One line per
# item, "OK" or "FALLA", exit 1 if anything failed. Nothing is started or
# modified. Items:
#   3. Plugin my-flow installed (only if the `claude` CLI exists).
#   4. .playbook/ exists (make ci writes ci-ok there).
#   5. No absolute paths (home folders) in docs, CLAUDE.md, AGENTS.md or .claude/.
#   6. Scripts executable and python3 available (scripts/estado.py).
#   8. uv, and the system tools declared in .claude/rules/jobs.md (warning only).
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

failures=0
ok()   { printf 'OK     %s\n' "$1"; }
fail() { printf 'FALLA  %s\n' "$1"; failures=$((failures + 1)); }
warn() { printf 'AVISO  %s\n' "$1"; }
skip() { printf 'omito  %s\n' "$1"; }

# 3. Plugin my-flow ----------------------------------------------------
if command -v claude >/dev/null 2>&1; then
  if claude plugin list 2>/dev/null | grep -q "my-flow"; then
    ok "plugin my-flow instalado"
  else
    fail "falta el plugin: claude plugin marketplace add github:MatPizzolo/my-playbook && claude plugin install my-flow@my-playbook"
  fi
else
  skip "no encuentro el comando claude en el PATH"
fi

# 4. .playbook/ ----------------------------------------------------------------
if [[ -d .playbook ]]; then
  ok ".playbook/ existe"
else
  fail "falta .playbook/ (corré make bootstrap)"
fi

# 5. Absolute paths in docs ---------------------------------------------------
# The brackets keep this script itself free of the literal patterns.
pattern='/[U]sers/[a-z0-9_-]+/|/[h]ome/[a-z0-9_-]+/'
hits="$(grep -rIlE "${pattern}" --include='*.md' --include='*.json' --include='*.yml' --include='*.yaml' \
  CLAUDE.md AGENTS.md README.md docs .claude 2>/dev/null | grep -v '^.claude/worktrees/' || true)"
if [[ -z "${hits}" ]]; then
  ok "sin rutas absolutas de otra máquina en docs y .claude/"
else
  fail "rutas absolutas en: $(echo "${hits}" | tr '\n' ' ')"
fi

# 6. Tooling ------------------------------------------------------------------
if command -v python3 >/dev/null 2>&1; then
  ok "python3 disponible (scripts/estado.py)"
else
  fail "falta python3 (lo usan scripts/estado.py y los hooks del plugin)"
fi
not_exec="$(find scripts -maxdepth 1 -name '*.sh' ! -perm -u+x 2>/dev/null || true)"
if [[ -z "${not_exec}" ]]; then
  ok "scripts/*.sh ejecutables"
else
  fail "sin permiso de ejecución: $(echo "${not_exec}" | tr '\n' ' ') (chmod +x)"
fi

# Jobs (jobs/, sin Docker) ------------------------------------------------------
if command -v uv >/dev/null 2>&1; then
  ok "uv disponible (jobs/)"
else
  fail "falta uv: https://docs.astral.sh/uv/ (brew install uv)"
fi
# The tools live in one line of .claude/rules/jobs.md: <!-- herramientas: ffmpeg yt-dlp -->
tools="$(sed -n 's/^<!-- herramientas:\(.*\)-->$/\1/p' .claude/rules/jobs.md 2>/dev/null | head -1)"
for tool in ${tools}; do
  if command -v "${tool}" >/dev/null 2>&1; then
    ok "${tool} disponible (lo usa jobs/)"
  else
    warn "falta ${tool}: lo declara .claude/rules/jobs.md (instalalo antes de correr los jobs)"
  fi
done

# Conectores (decisión 0006): OAuth por /mcp, nunca una clave escrita en .mcp.json.
if [[ -f .mcp.json ]]; then
  if grep -Eiq '"(authorization|x-api-key)"[[:space:]]*:[[:space:]]*"[^"$]*[A-Za-z0-9]{12}|[?&/](api_?key|token|key)=?[A-Za-z0-9_-]{16,}|fc-[A-Za-z0-9]{16,}|pplx-[A-Za-z0-9]{16,}' .mcp.json; then
    fail ".mcp.json tiene una clave escrita: sacala, usá OAuth (/mcp) o \${VARIABLE} del entorno"
  else
    ok ".mcp.json sin claves escritas"
  fi
fi

echo
if [[ ${failures} -gt 0 ]]; then
  echo "${failures} chequeo(s) fallaron."
  exit 1
fi
echo "Todo OK."
