#!/usr/bin/env bash
# Creates .env from .env.example, filling every empty value with a random secret.
#
# Usage: scripts/init-env.sh [target-path]   (default: <repo>/.env)
#
# - Keys that end in _API_KEY or _TOKEN are provider credentials: they are NEVER
#   filled with random bytes (a random value looks valid and fails late). They
#   are written empty and listed in a warning so the owner pastes the real one.
# - If the target already exists, appends only the keys declared in
#   .env.example that are missing from it (empty example value -> random
#   secret, otherwise the example default). Existing lines are never modified,
#   reordered or removed. Commented keys in .env.example are ignored.
# - In a linked git worktree it also writes COMPOSE_PROJECT_NAME (same name as
#   `make project`, from scripts/project-name.sh), so a bare compose call there
#   never targets the main checkout's stack. Never in the main checkout.
# - Never prints values (only key names).
# - Writes atomically (temp file + mv); the resulting file has mode 600.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-${REPO_ROOT}/.env}"
TARGET_DIR="$(dirname "${TARGET}")"

# Prefer a .env.example next to the target; fall back to the repo's.
EXAMPLE="${TARGET_DIR}/.env.example"
[[ -f "${EXAMPLE}" ]] || EXAMPLE="${REPO_ROOT}/.env.example"

# Empty in the main checkout or outside git.
WORKTREE_PROJECT="$("${REPO_ROOT}/scripts/project-name.sh" "${TARGET_DIR}" 2>/dev/null || true)"
PROJECT_KEY="COMPOSE_PROJECT_NAME"
PROJECT_COMMENT="# Compose project of this git worktree (make env); keeps a bare compose call off the main stack."

if [[ ! -f "${EXAMPLE}" ]]; then
  echo "No encontré .env.example (${EXAMPLE})." >&2
  exit 1
fi

# 32 random bytes as 64 lowercase hex chars.
random_hex() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 32
  else
    od -An -N32 -tx1 /dev/urandom | tr -d ' \n'
    echo
  fi
}

# Provider credentials are never invented.
is_credential() {
  [[ "$1" == *_API_KEY || "$1" == *_TOKEN ]]
}

secret_for() {
  local key="$1" hex
  hex="$(random_hex)"
  case "${key}" in
    LANGFUSE_PUBLIC_KEY) printf 'pk-lf-%s' "${hex}" ;;
    LANGFUSE_SECRET_KEY) printf 'sk-lf-%s' "${hex}" ;;
    *) printf '%s' "${hex}" ;;
  esac
}

credentials_left_empty=()

# Prints "KEY=value" for a key declared in .env.example: empty -> new secret,
# except credentials, which stay empty and are reported.
example_line() {
  local key="$1" value="$2"
  if [[ -z "${value}" ]]; then
    if is_credential "${key}"; then
      credentials_left_empty+=("${key}")
      printf '%s=\n' "${key}"
    else
      printf '%s=%s\n' "${key}" "$(secret_for "${key}")"
    fi
  else
    printf '%s=%s\n' "${key}" "${value}"
  fi
}

warn_credentials() {
  [[ ${#credentials_left_empty[@]} -gt 0 ]] || return 0
  echo "Ojo: estas claves de proveedores quedaron vacías porque no se inventan: ${credentials_left_empty[*]}." >&2
  echo "     Pegá el valor real en ${TARGET} (o dejalas vacías si el proyecto corre con fakes)." >&2
}

umask 077
TMP_FILE="$(mktemp "${TARGET_DIR}/.env.tmp.XXXXXX")"
trap 'rm -f "${TMP_FILE}"' EXIT

# Moves the temp file over the target with mode 600.
commit_tmp() {
  chmod 600 "${TMP_FILE}"
  mv "${TMP_FILE}" "${TARGET}"
  trap - EXIT
}

key_pattern='^([A-Z][A-Z0-9_]*)=(.*)$'

# Warns (key name only) when an existing project name differs from this worktree's.
warn_project_mismatch() {
  echo "Ojo: ${PROJECT_KEY} en ${TARGET} no coincide con el proyecto de este worktree (make project). Lo dejo como está." >&2
}

if [[ -e "${TARGET}" ]]; then
  added=()
  cat "${TARGET}" >"${TMP_FILE}"

  # Before the first appended key: separator and header.
  start_appending() {
    [[ ${#added[@]} -eq 0 ]] || return 0
    # Keep the last existing line intact if it has no trailing newline.
    if [[ -s "${TARGET}" && -n "$(tail -c1 "${TARGET}")" ]]; then
      printf '\n' >>"${TMP_FILE}"
    fi
    printf '# Added by make env (scripts/init-env.sh)\n' >>"${TMP_FILE}"
  }

  while IFS= read -r line || [[ -n "${line}" ]]; do
    [[ "${line}" =~ ${key_pattern} ]] || continue
    key="${BASH_REMATCH[1]}"
    value="${BASH_REMATCH[2]}"
    grep -qE "^${key}=" "${TARGET}" && continue
    start_appending
    example_line "${key}" "${value}" >>"${TMP_FILE}"
    added+=("${key}")
  done <"${EXAMPLE}"

  if [[ -n "${WORKTREE_PROJECT}" ]]; then
    current="$(grep -E "^${PROJECT_KEY}=" "${TARGET}" | head -n1 || true)"
    if [[ -z "${current}" ]]; then
      start_appending
      printf '%s=%s\n' "${PROJECT_KEY}" "${WORKTREE_PROJECT}" >>"${TMP_FILE}"
      added+=("${PROJECT_KEY}")
    elif [[ "${current#*=}" != "${WORKTREE_PROJECT}" ]]; then
      warn_project_mismatch
    fi
  fi

  if [[ ${#added[@]} -eq 0 ]]; then
    rm -f "${TMP_FILE}"
    trap - EXIT
    echo "Ya existe ${TARGET} y tiene todas las claves: no lo toco."
    exit 0
  fi

  commit_tmp
  echo "Agregué a ${TARGET} las claves que faltaban (los valores no se muestran): ${added[*]}"
  echo "Las claves que ya estaban quedaron igual."
  warn_credentials
  exit 0
fi

while IFS= read -r line || [[ -n "${line}" ]]; do
  if [[ "${line}" =~ ^([A-Z][A-Z0-9_]*)=$ ]]; then
    example_line "${BASH_REMATCH[1]}" "" >>"${TMP_FILE}"
  else
    printf '%s\n' "${line}" >>"${TMP_FILE}"
  fi
done <"${EXAMPLE}"

if [[ -n "${WORKTREE_PROJECT}" ]]; then
  printf '\n%s\n%s=%s\n' "${PROJECT_COMMENT}" "${PROJECT_KEY}" "${WORKTREE_PROJECT}" >>"${TMP_FILE}"
fi

commit_tmp

echo "Listo: creé ${TARGET} con claves nuevas (no se muestran)."
warn_credentials
