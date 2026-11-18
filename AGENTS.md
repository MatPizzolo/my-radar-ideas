# AGENTS.md

Guía canónica para cualquier agente de código que trabaje en **my-radar-ideas** (Claude Code la importa desde `CLAUDE.md`; otras herramientas la leen directo). Si un framework genera su propio bloque acá, se respeta intacto y las notas van afuera del bloque.

## Mapa del repo

| Ruta | Qué hay | Área dueña |
|---|---|---|
| `jobs/` | Jobs y pipeline en Python (`uv`, `pytest`, sin Docker) | jobs |
| `Makefile`, `scripts/`, `.github/` | Entorno, única puerta (`make ci`), CI | infra |
| `docs/etapas/` | Planes, cierres, cards y `ESTADO.md` | orquestador |
| `docs/adr/` | Decisiones numeradas e inmutables | orquestador |
| `docs/investigacion/` | Etapa 1 del playbook | owner |
| `docs/cumplimiento.md` | Control antes de publicar y reglas propias | owner |
| `.claude/` | Reglas por área, skills alias y permisos | orquestador |

## Comandos

Todo pasa por el Makefile; `make help` lista los targets con una línea cada uno. Los que más se usan:

```bash
make env           # crea .env (no muestra valores); las claves *_API_KEY y *_TOKEN quedan vacías
make lint          # estilo y tipos de todas las áreas
make test          # tests unitarios (sin red, sin claves)
make ci            # la única puerta: lint, tests y secretos
make estado        # regenera el bloque vivo de docs/etapas/ESTADO.md
make doctor        # chequea la máquina (plugin, worktrees, rutas absolutas)
```

## Convenciones

- **Idiomas:** código, identificadores, nombres de archivos de código y commits en inglés. UI, docs, skills, prompts y copy en español rioplatense (voseo, sin jerga técnica para el cliente).
- **Commits:** Conventional Commits con scope (`feat(api): …`, `fix(web): …`, `docs(etapas): …`). Uno por bloque lógico. Nunca `--force`.
- **Ramas:** `m#/<area>` por lead, `m#/integracion` para integrar, `worktree-agent-<id>` para workers (las crea el harness). Toda rama `m#/*` se pushea al cerrar el día con `make push`; a `main` solo con GATE 2.
- **Tests primero:** TDD (rojo → verde → refactor). Cada comportamiento con su test; cada regla con su guarda (hook, deny, target o test).
- **Errores:** códigos de dominio estables, mensajes para quien lo usa en rioplatense, nunca trazas internas a la vista.
- **Tipos:** `mypy` estricto en Python.
- **Rutas en docs y prompts:** relativas al repo. Nunca una ruta absoluta que empiece en el home de una máquina (`make doctor` y `make lint-prompts` las rechazan).

## Qué no hacer

- No leer, imprimir ni copiar `.env`, `.env.local` ni ningún secreto. Variables de entorno, siempre.
- No publicar nada que no haya pasado `docs/cumplimiento.md` y el OK del owner.
- No correr `git push --force`, `git reset --hard` ni `rm -rf` sobre raíces: los hooks los bloquean y el mensaje dice el remedio.
- No editar archivos de otra área sin pedirlo al lead (el Contrato de `docs/etapas/M#-plan.md` manda).
- No editar a mano el bloque generado de `docs/etapas/ESTADO.md` ni ADRs ya aceptados (se escribe uno nuevo).
- No agregar dependencias sin aprobación en el GATE 1 o una pregunta explícita.

## Regla de costo

**Nunca APIs pagas en tests.** Unit, integración, e2e y `make ci` corren con fakes deterministas y fixtures grabadas (`tests/fixtures/`), sin claves. Las llamadas reales a proveedores (LLM, embeddings, rerank, voz, video) solo en corridas reales y con el owner al tanto del costo. Cada card de lead o worker trae un `cost cap` en USD.

## Fuentes de verdad

`docs/PROJECT_BRIEF.md` (alcance) · `docs/WORKFLOW.md` (cómo trabajamos) · `docs/etapas/ESTADO.md` (dónde estamos) · `docs/adr/` (por qué).
