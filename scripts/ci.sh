#!/usr/bin/env bash
# Local CI: the same checks a remote pipeline would run, without containers. Entry point: `make ci` (which records .playbook/ci-ok on green).
#
# Steps: .env (only if missing) -> lint-prompts -> lint -> test -> secrets scan. It never prints secret values.
# No paid API is ever called here: tests run with fakes and recorded fixtures.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"


GITLEAKS_IMAGE="docker.io/zricethezav/gitleaks:v8.30.1"
LOG_TAIL=200


SCAN_DIR=""

step() {
  printf '\n==> %s\n' "$1"
}

on_error() {
  local exit_code=$?
  printf '\n!! Falló el paso anterior (código %s).\n' "${exit_code}" >&2
  exit "${exit_code}"
}

cleanup() {
  if [[ -n "${SCAN_DIR}" && -d "${SCAN_DIR}" ]]; then
    rm -rf "${SCAN_DIR}"
  fi
}

trap on_error ERR
trap cleanup EXIT

step "Entorno: creo .env solo si no existe"
if [[ -f .env ]]; then
  echo "Uso el .env existente."
else
  make env
fi

step "Reviso planes, cards y prompts (patrones prohibidos, rutas absolutas)"
make lint-prompts

step "Reviso estilo y tipos"
make lint

step "Corro los tests (sin red, sin claves)"
make test

step "Busco secretos en el código (gitleaks)"
# Scan only what git would track (tracked + untracked, minus .gitignore), so
# .env and other ignored files are never read. Findings are redacted.
SCAN_DIR="$(mktemp -d)"
chmod 755 "${SCAN_DIR}"
# Deleted-but-not-staged paths are still listed by git; skip them so tar never
# fails on a missing file.
git ls-files -z --cached --others --exclude-standard \
  | while IFS= read -r -d '' path; do
      if [[ -e "${path}" ]]; then printf '%s\0' "${path}"; fi
    done \
  | tar --null -T - -cf - \
  | tar -xf - -C "${SCAN_DIR}"
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks dir "${SCAN_DIR}" --config "${SCAN_DIR}/.gitleaks.toml" \
    --redact --no-banner --exit-code 1
elif command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  docker run --rm \
    -v "${SCAN_DIR}":/scan:ro,z \
    "${GITLEAKS_IMAGE}" dir /scan --config /scan/.gitleaks.toml \
    --redact --no-banner --exit-code 1
else
  # Without Docker the scan needs the gitleaks binary (brew install gitleaks).
  # It is a visible warning, not a silent skip.
  echo "AVISO: no encuentro gitleaks ni Docker: el escaneo de secretos no corrió. Instalá gitleaks (brew install gitleaks)." >&2
fi

printf '\nCI local en verde.\n'
