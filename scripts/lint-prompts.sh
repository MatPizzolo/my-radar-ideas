#!/usr/bin/env bash
# `make lint-prompts`: rejects plans, cards and prompts that contain forbidden
# patterns (bare `docker compose`, absolute paths of a machine) or the phrase
# "no está commiteado". The canonical linter and the pattern list live in the
# my-playbook (plugin my-flow, hooks/patrones-prohibidos.txt). This wrapper:
#   1. runs the plugin's lint-prompts.sh if the plugin is installed;
#   2. otherwise applies the plugin's pattern file with python3, if found;
#   3. otherwise warns and exits 0 (the real check happens in my-playbook's CI).
# Override the location with PLAYBOOK_FLOW_ROOT=<path to the plugin folder>.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

TARGET_DIRS=(docs/etapas docs/prompts prompts)

find_plugin_root() {
  if [[ -n "${PLAYBOOK_FLOW_ROOT:-}" && -d "${PLAYBOOK_FLOW_ROOT}" ]]; then
    printf '%s\n' "${PLAYBOOK_FLOW_ROOT}"
    return 0
  fi
  local base="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}/plugins"
  [[ -d "${base}" ]] || return 1
  find "${base}" -type f -path '*my-flow*/hooks/patrones-prohibidos.txt' 2>/dev/null \
    | head -n1 | xargs -I{} dirname {} | xargs -I{} dirname {}
}

PLUGIN_ROOT="$(find_plugin_root || true)"

if [[ -n "${PLUGIN_ROOT}" ]]; then
  for candidate in "${PLUGIN_ROOT}/scripts/lint-prompts.sh" "${PLUGIN_ROOT}/hooks/lint-prompts.sh"; do
    if [[ -x "${candidate}" ]]; then
      exec "${candidate}" "${TARGET_DIRS[@]}"
    fi
  done
  PATTERNS="${PLUGIN_ROOT}/hooks/patrones-prohibidos.txt"
  if [[ -f "${PATTERNS}" ]]; then
    exec python3 - "${PATTERNS}" "${TARGET_DIRS[@]}" <<'PY'
import pathlib, re, sys

patterns_file, *dirs = sys.argv[1:]
rules = []
for raw in pathlib.Path(patterns_file).read_text(encoding="utf-8").splitlines():
    if not raw.strip() or raw.startswith("#"):
        continue
    category, rest = raw.split("|", 1)          # la regex puede contener "|": categoría = hasta el 1er "|",
    regex, message = rest.rsplit("|", 1)        # mensaje = desde el último "|"
    if category in ("docker", "rutas"):
        rules.append((category, re.compile(regex), message))
rules.append(("commit", re.compile(r"no está commiteado"), "Un plan o card nunca referencia algo sin commitear: commiteá primero."))

problems = 0
for d in dirs:
    for path in sorted(pathlib.Path(d).rglob("*.md")) if pathlib.Path(d).is_dir() else []:
        for n, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
            for category, rx, message in rules:
                if rx.search(line):
                    problems += 1
                    print(f"{path}:{n}: [{category}] {message}")
if problems:
    print(f"\n{problems} problema(s) en prompts, planes o cards.", file=sys.stderr)
    sys.exit(1)
print("lint-prompts: sin patrones prohibidos.")
PY
  fi
fi

echo "lint-prompts: no encuentro el plugin my-flow instalado; omito el chequeo local (el playbook lo corre en su CI)." >&2
echo "             Instalalo con: claude plugin install my-flow@my-playbook" >&2
exit 0
