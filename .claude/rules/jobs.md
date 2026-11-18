---
paths:
  - "jobs/**"
---

# Reglas del área jobs

<!-- herramientas: gh -->

Los jobs son Python 3.12 con `uv` y corren en el host, sin Docker. Complementa `.claude/rules/ecc/python/`. La línea `herramientas` de arriba la lee `make doctor`: si un job necesita una herramienta del sistema (ffmpeg, yt-dlp…), se agrega ahí.

- **Solo `uv`.** Dependencias con `uv add` dentro de `jobs/` (pide aprobación), nunca `pip install`. El lockfile `jobs/uv.lock` se commitea.
- **Un paso, una función pura más un borde.** La lógica no toca red ni disco; el borde (descarga, API, escritura) es una función chica que se reemplaza por un fake en los tests.
- **Idempotente.** Correr un paso dos veces con la misma entrada da el mismo resultado y no duplica nada. Cada paso deja sus artefactos en disco con un manifiesto (`entrada`, `salida`, `versión`, `fecha`).
- **Nunca APIs pagas en tests.** `make test-jobs` corre sin red ni claves, con fakes deterministas y fixtures grabadas en `jobs/tests/fixtures/`.
- **Costo con tope.** Toda llamada paga (LLM, voz, video) pasa por una función que suma el costo y frena al pasar el tope de la corrida.
- **Secretos por entorno.** Ninguna clave en el código ni en fixtures; `.env` no se lee desde los tests.
- **Nada se publica sin el control.** El paso que publica o programa una publicación llama antes al control de `docs/cumplimiento.md` y necesita el OK del owner (por pieza o por lote, según el ADR 0001).
- **Tests primero.** Un test por comportamiento; `make lint-jobs` (ruff) y `make test-jobs` (pytest) entran en `make ci`.
