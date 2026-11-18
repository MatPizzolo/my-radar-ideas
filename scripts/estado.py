#!/usr/bin/env python3
"""Regenerates the live block of docs/etapas/ESTADO.md (`make estado`).

Contract: docs/playbook/contratos.md §1 of the playbook. The block between the
markers `generado:inicio` / `generado:fin` is the only thing this script
touches; the part above it belongs to the orchestrator (`/cerrar-etapa`).
Nobody edits the block by hand: `scope_guard` blocks it and this script
overwrites it.

Standard library only. Takes a lock (`.playbook/estado.lock`, stale after 30 s)
so two sessions never write at the same time, and writes atomically (temp file
+ os.replace) so a reader never sees a half-written file. Paths in the output
are relative to the repo root: never a home folder.

Usage: scripts/estado.py [--dry-run] [--quiet]
"""
from __future__ import annotations

import os
import re
import subprocess
import sys
import tempfile
import time
from datetime import datetime
from pathlib import Path

MARK_START = "<!-- generado:inicio (scripts/estado.py, no editar a mano) -->"
MARK_END = "<!-- generado:fin -->"
ESTADO_REL = Path("docs/etapas/ESTADO.md")
CI_OK_REL = Path(".playbook/ci-ok")
LOCK_REL = Path(".playbook/estado.lock")
LOCK_WAIT_S = 10.0
LOCK_STALE_S = 30.0
WORK_BRANCH = re.compile(r"^(m\d+/|wip/|worktree-agent-)")
STAGE_LINE = re.compile(r"\*\*Etapa actual:\*\*\s*(M\d+)")
MINIMAL_ESTADO = (
    "# Estado del proyecto\n\n"
    "- **Etapa actual:** ninguna (M0 pendiente).\n"
    "- **Próxima etapa:** M0 Esqueleto.\n\n"
    "## Decisiones\n\n**Resueltas**\n\n**Diferidas**\n\n"
    "## Backlog\n\n## Historial\n\n| Etapa | Estado | Fecha | Notas |\n|---|---|---|---|\n"
)


def git(*args: str, cwd: Path, check: bool = False) -> str:
    """Runs git and returns stdout stripped; empty string on error."""
    try:
        result = subprocess.run(
            ["git", *args], cwd=cwd, capture_output=True, text=True, timeout=20, check=check
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return result.stdout.strip() if result.returncode == 0 else ""


def repo_root() -> Path:
    here = Path(__file__).resolve().parent.parent
    top = git("rev-parse", "--show-toplevel", cwd=here)
    return Path(top) if top else here


def relative(path: Path, root: Path) -> str:
    try:
        return str(path.resolve().relative_to(root.resolve()))
    except ValueError:
        return path.name


# --- data ------------------------------------------------------------------


def branches(root: Path) -> list[str]:
    raw = git(
        "for-each-ref",
        "--format=%(refname:short)|%(upstream:short)|%(upstream:track)",
        "refs/heads/",
        cwd=root,
    )
    items: list[str] = []
    for line in raw.splitlines():
        name, upstream, track = (line.split("|") + ["", ""])[:3]
        if not WORK_BRANCH.match(name):
            continue
        if not upstream:
            status = "**sin upstream**"
        elif not track:
            status = "upstream ok"
        else:
            status = describe_track(track)
        items.append(f"`{name}` ({status})")
    return items


def describe_track(track: str) -> str:
    """'[ahead 3, behind 1]' -> '3 commits adelante y 1 atrás de origin'."""
    ahead = re.search(r"ahead (\d+)", track)
    behind = re.search(r"behind (\d+)", track)
    parts = []
    if ahead:
        n = int(ahead.group(1))
        parts.append(f"{n} commit{'s' if n != 1 else ''} adelante")
    if behind:
        n = int(behind.group(1))
        parts.append(f"{n} commit{'s' if n != 1 else ''} atrás")
    if "gone" in track:
        return "**upstream borrado**"
    return (" y ".join(parts) + " de origin") if parts else "upstream ok"


def worktrees(root: Path) -> list[str]:
    raw = git("worktree", "list", "--porcelain", cwd=root)
    paths = [Path(line[len("worktree "):]) for line in raw.splitlines() if line.startswith("worktree ")]
    items: list[str] = []
    for path in paths[1:]:  # the first entry is the main checkout
        if not path.is_dir():
            items.append(f"`{relative(path, root)}` (**carpeta ausente**)")
            continue
        dirty = [l for l in git("status", "--porcelain", cwd=path).splitlines() if l.strip()]
        if dirty:
            n = len(dirty)
            status = f"**{n} archivo{'s' if n != 1 else ''} sin commitear**"
        else:
            status = "limpio"
        items.append(f"`{relative(path, root)}` ({status})")
    return items


def last_green(root: Path) -> str:
    ci_ok = root / CI_OK_REL
    if not ci_ok.is_file():
        return "ninguno registrado (corré `make ci`)"
    recorded = ci_ok.read_text(encoding="utf-8", errors="replace").strip()
    when = datetime.fromtimestamp(ci_ok.stat().st_mtime).strftime("%Y-%m-%d %H:%M")
    current = tree_hash(root)
    if not current:
        state = "árbol actual: no pude calcularlo"
    elif current == recorded:
        state = "árbol actual: igual"
    else:
        state = "**árbol actual: cambió**"
    return f"{when} sobre {recorded[:7]} ({state})"


def tree_hash(root: Path) -> str:
    script = root / "scripts" / "tree_hash.sh"
    if not script.is_file():
        return ""
    try:
        result = subprocess.run(
            ["bash", str(script)], cwd=root, capture_output=True, text=True, timeout=60
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return result.stdout.strip() if result.returncode == 0 else ""


def active_cards(root: Path, estado_text: str) -> list[str]:
    match = STAGE_LINE.search(estado_text)
    if not match:
        return []
    stage = match.group(1)
    cards = []
    for folder in (f"{stage}-leads", f"{stage}-workers"):
        directory = root / "docs" / "etapas" / folder
        if directory.is_dir():
            cards.extend(f"`{relative(p, root)}`" for p in sorted(directory.glob("*.md")))
    return cards


def render_block(root: Path, estado_text: str) -> str:
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    branch = git("rev-parse", "--abbrev-ref", "HEAD", cwd=root) or "sin git"
    sha = git("rev-parse", "--short", "HEAD", cwd=root) or "sin commits"
    joined = lambda items: " · ".join(items) if items else "ninguna"  # noqa: E731
    lines = [
        MARK_START,
        f"## Dónde estamos (generado {now}, rama {branch} @ {sha})",
        f"- Ramas de trabajo: {joined(branches(root))}",
        f"- Worktrees: {' · '.join(worktrees(root)) or 'ninguno'}",
        f"- Último `make ci` verde: {last_green(root)}",
        f"- Cards activas: {joined(active_cards(root, estado_text))}",
        MARK_END,
    ]
    return "\n".join(lines) + "\n"


# --- file ------------------------------------------------------------------


def merge(existing: str, block: str) -> str:
    start = existing.find(MARK_START)
    end = existing.find(MARK_END)
    if start != -1 and end != -1 and end > start:
        tail = existing[end + len(MARK_END):].lstrip("\n")
        return existing[:start] + block + ("\n" + tail if tail else "")
    body = existing.rstrip("\n")
    return (body + "\n\n" if body else "") + block


def write_atomic(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix=".ESTADO.", suffix=".tmp", dir=path.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(text)
        os.replace(tmp, path)
    except BaseException:
        try:
            os.unlink(tmp)
        except OSError:
            pass
        raise


class Lock:
    """Exclusive lock via O_EXCL; a lock older than LOCK_STALE_S is considered abandoned."""

    def __init__(self, path: Path) -> None:
        self.path = path

    def __enter__(self) -> "Lock":
        self.path.parent.mkdir(parents=True, exist_ok=True)
        deadline = time.monotonic() + LOCK_WAIT_S
        while True:
            try:
                fd = os.open(self.path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
                os.write(fd, str(os.getpid()).encode())
                os.close(fd)
                return self
            except FileExistsError:
                try:
                    if time.time() - self.path.stat().st_mtime > LOCK_STALE_S:
                        self.path.unlink(missing_ok=True)
                        continue
                except OSError:
                    continue
                if time.monotonic() > deadline:
                    raise SystemExit(
                        f"ESTADO.md está ocupado por otra sesión ({self.path.name}). Probá de nuevo."
                    )
                time.sleep(0.05)

    def __exit__(self, *_exc: object) -> None:
        self.path.unlink(missing_ok=True)


def main(argv: list[str]) -> int:
    dry_run = "--dry-run" in argv
    quiet = "--quiet" in argv
    root = repo_root()
    estado = root / ESTADO_REL

    with Lock(root / LOCK_REL):
        existing = estado.read_text(encoding="utf-8") if estado.is_file() else MINIMAL_ESTADO
        block = render_block(root, existing)
        if not dry_run:
            write_atomic(estado, merge(existing, block))
    if not quiet:
        sys.stdout.write(block)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
