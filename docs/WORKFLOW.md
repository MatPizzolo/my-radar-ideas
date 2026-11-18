# Cómo trabajamos en my-radar-ideas

Metodología del playbook: `plan → test → implementar → revisar → verificar → recordar`, con tres niveles de sesiones (orquestador, leads, workers) y **dos aprobaciones humanas por etapa**. Este documento es la referencia; `CLAUDE.md` tiene el resumen y `make help` los comandos.

## Glosario (una palabra por concepto)

| Término | Qué es |
|---|---|
| **Owner** | Vos. Aprobás los gates, leés y enviás lo que la herramienta deja como PR o reporte, mergeás a `main`. |
| **Etapa de construcción (M#)** | Milestone M0–M5 del brief. Se abre con `/etapa M#` y se cierra con `/cerrar-etapa`. |
| **GATE 1 / GATE 2** | Las dos aprobaciones: el plan (y el modo de ejecución) y el commit a `main`. |
| **Orquestador** | La sesión que corre `/etapa` en el checkout principal (`main`). Planifica, lanza leads, integra, revisa, cierra. **No escribe código de features.** |
| **Lead** | Responsable de un área (jobs, infra) en la rama `m#/<area>` y su worktree `.claude/worktrees/lead-<area>`. Divide en tareas, lanza workers, integra. |
| **Worker** | Subagente que hace una tarea del plan en su propio worktree con TDD y commits locales. |
| **Revisor** | Subagente de solo lectura con veredicto fijo: archivo:línea, severidad, APROBADO / NO APROBADO. |
| **Card** | Prompt versionado de una sesión (lead o worker), generado desde el plan. |
| **Contrato** | La sección `## Contrato` de `M#-plan.md`: dueño por archivo, endpoints, esquema, variables. `scope_guard` lo hace cumplir. |
| **Plan / Cierre** | `docs/etapas/M#-plan.md` (aprobado en GATE 1) y `docs/etapas/M#-cierre.md` (qué se hizo, evidencia, desvíos, deuda). |
| **ESTADO.md** | `docs/etapas/ESTADO.md`: etapa, decisiones, backlog, historial y el bloque vivo que genera `scripts/estado.py`. |
| **Decisión (ADR)** | `docs/adr/NNNN-slug.md`, numerada e inmutable: si cambia, se escribe una nueva que la reemplaza. |
| **Única puerta** | `make ci`. Escribe `.playbook/ci-ok` con el hash del árbol; el hook de Stop lo compara. |
| **Guarda** | Hook, regla deny, target de make o test que hace cumplir una regla. Una regla que vive solo en CLAUDE.md no es una guarda. |

## Flujo de cada etapa

```
/etapa M#
  0. Contexto      brief, ESTADO.md, cierre de la etapa anterior, ADRs relevantes
  1. Investigar    reusar antes de escribir: docs oficiales, librerías probadas
  2. Planificar    ecc:planner (+ ecc:architect si hay decisiones estructurales)
                   → docs/etapas/M#-plan.md: tareas en rebanadas verticales por área,
                     ## Contrato (dueño por archivo), dependencias nuevas, riesgos,
                     revisores y criterios de "listo". Se commitea ANTES de generar cards.
  ── GATE 1 ──     mostrar el plan y PREGUNTAR: aprobar / ajustar / cancelar + modo A o B
  3. Leads         un lead por área con trabajo, en su rama m#/<area> y su worktree
  4. Tests+impl    cada worker: TDD (rojo → verde → refactor) en su worktree, commits locales
  5. Integrar      lead → m#/<area>; orquestador → m#/integracion
  6. Revisar       revisores con contexto limpio (tabla más abajo); corregir CRITICAL y HIGH
  7. Verificar     make ci verde (única puerta) + make eval desde la etapa del asistente
/cerrar-etapa
  ── GATE 2 ──     resumen, evidencia y PREGUNTAR antes de mergear a main
  8. Commit        conventional commits en inglés, uno por bloque lógico
  9. Recordar      M#-cierre.md, ESTADO.md regenerado, ADRs nuevos, lecciones al playbook
```

## Modos de ejecución (se eligen en el GATE 1)

| Modo | Cómo funciona | Conviene cuando |
|---|---|---|
| **A — Sub-agentes** (default) | El orquestador lanza los leads con `Agent(..., isolation: "worktree")`; vos ves los reportes, no el trabajo en vivo. El reporte del lead es el retorno del `Agent`. | Etapas chicas o con áreas muy acopladas |
| **B — Sesiones con cards** | El orquestador escribe una card por área y vos abrís una sesión por lead (`claude --worktree lead-<area>` y pegás `docs/etapas/M#-leads/<area>.md`). Leads y orquestador hablan por `SendMessage`. | Etapas grandes, o cuando querés ver y corregir cada área en vivo |

En los dos modos el GATE 2 y los commits a `main` son del orquestador con tu confirmación. Workers nunca hablan con vos: reportan al lead.

## Cómo se coordinan (sin pisarse)

1. **El contrato es el plan.** `M#-plan.md` fija tareas por área y dueño de cada archivo. `scope_guard` lo lee: un worker que toca un archivo de otra área es bloqueado y el mensaje le dice a quién pedírselo.
2. **Estado en un solo lugar, generado.** `docs/etapas/ESTADO.md` se regenera con `make estado`; nadie edita el bloque a mano. Un orquestador nuevo arranca leyendo eso, no la memoria de la sesión anterior.
3. **Recursos compartidos.** Un solo `make ci` / `make up` a la vez por máquina. Cada worktree tiene su propio proyecto de compose (`make project`); nadie corre `docker compose` a mano; cada lead o worker baja **solo sus propios** worktrees (`make down` en su carpeta); nadie corre `down -v` ni `reset-db` fuera de su proyecto.
4. **Base de los workers:** los worktrees salen de `main`. Si una tarea depende de otra de la misma etapa, el lead las encadena o las reparte para que no dependan entre sí.
5. **Choques:** si un worker necesita tocar algo de otra área, avisa al lead y el lead al orquestador. No se edita por fuera.

## Regla de push

- Los commits en ramas de trabajo son locales y están permitidos.
- **Toda rama `m#/*` se pushea al cerrar el día** con `make push` (hace `pull --rebase --autostash`, `push -u` y verifica que el SHA remoto sea el local). Nunca `--force`: el hook lo bloquea.
- **A `main` solo llega algo con GATE 2.** `make push` en `main` pide confirmación explícita.
- `/cerrar-etapa` corre `make handoff` y **bloquea** si hay ramas sin upstream o worktrees sucios. Al cerrar la etapa se borran las ramas y worktrees de trabajo (las borra el owner, el hook bloquea `branch -D`).
- Al cambiar de máquina: `/mudanza` deja todo en el repo y en GitHub; en la máquina nueva, `git pull`, `make bootstrap`, `make doctor`, `/estado`.

## Card (7 puntos fijos)

`docs/etapas/M#-leads/<area>.md` (lead) y `docs/etapas/M#-workers/<area>-<n>.md` (worker, opcional). Rutas relativas al repo, sin ejemplos de `docker compose`. `make lint-prompts` las rechaza si tienen patrones prohibidos o la frase "no está commiteado".

1. **Rol y rama:** `m#/<area>`, worktree `.claude/worktrees/lead-<area>`.
2. **Lectura obligatoria:** `CLAUDE.md`, `docs/WORKFLOW.md`, `docs/etapas/M#-plan.md` (su sección y el Contrato).
3. **Tareas**, cada una con "Listo cuando" verificable, dueño de archivo y lo que no puede tocar.
4. **Cómo trabajar:** un worker por tarea con `isolation: worktree`, TDD, commits locales, push de la rama al cerrar el día, nunca `main`.
5. **Reglas no negociables** (copiadas de `CLAUDE.md`) y skills del área.
6. **Cuándo frenar:** dependencia nueva, cambio de contrato o esquema, tocar archivos ajenos, borrar datos.
7. **Reporte final (5 líneas):** rama, commits, tests, desvíos, pendientes. `cost cap` en USD y tope de checkpoints.

## Revisores por etapa

| Etapa | Revisores |
|---|---|
| M0 Esqueleto | `ecc:code-reviewer`, `ecc:security-reviewer` (secretos), `docs-auditor` |
| M1–M4 | `ecc:code-reviewer`, `ecc:python-reviewer`, `pr-reviewer` |
| M5 | `docs-auditor`, `pr-reviewer`, control de `docs/cumplimiento.md` sobre una muestra de piezas |

Los revisores corren en paralelo sobre `m#/integracion`, con contexto limpio y `tools: Read, Grep, Glob`. Opus para aislamiento y seguridad; Sonnet para el resto.

## Modelos y costo

Opus para planificar, integrar y auditar; Sonnet para leads de etapas mecánicas, workers y revisores de tono/docs; Haiku para tareas mecánicas (renombres, fixtures). Con Sonnet como principal, `/advisor opus` en planes y cierres. Cada card trae `cost cap`; el orquestador avisa antes de un fan-out de más de 10 agentes. **Nunca APIs pagas en tests.**

## Cuándo preguntar

- **Siempre:** GATE 1 y GATE 2.
- **También:** dependencia nueva, cambio de alcance, cambio de contrato o esquema, borrar datos, cualquier decisión irreversible.
- **No preguntar:** detalles de implementación dentro del plan aprobado.

## Artefactos

- `docs/etapas/ESTADO.md` — etapa actual, decisiones, backlog, historial, bloque vivo.
- `docs/etapas/M#-plan.md` — plan aprobado (GATE 1), con `## Contrato`.
- `docs/etapas/M#-leads/`, `M#-workers/` — cards.
- `docs/etapas/M#-cierre.md` — qué se hizo, evidencia, revisiones, desvíos, incidentes, deuda.
- `docs/adr/` — decisiones.
