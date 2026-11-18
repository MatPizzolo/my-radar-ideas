# jobs

Jobs y pipeline en Python, sin Docker. `uv` crea el entorno en `jobs/.venv` la primera vez.

```bash
make test-jobs    # pytest, sin red ni claves
make lint-jobs    # ruff
make fmt-jobs     # formatea
```

Un módulo por paso en `src/`, un test por comportamiento en `tests/`. Las reglas están en `.claude/rules/jobs.md`.
