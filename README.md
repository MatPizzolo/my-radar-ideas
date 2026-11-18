# my-radar-ideas

Radar diario que le deja al owner un PR con 5 a 10 señales de negocio y 1 idea B2B testeada a fondo; con su merge arranca un repo propio para esa idea, generado con my-playbook (ADR 0002)..

Generado con el playbook (`github:MatPizzolo/my-playbook`), tipo **herramienta-interna**. Cómo se trabaja: `CLAUDE.md` y `docs/WORKFLOW.md`. Alcance: `docs/PROJECT_BRIEF.md`. Dónde estamos: `docs/etapas/ESTADO.md`.

## Requisitos

- **Git**, **make** y **python3**, más **uv** para `jobs/`. No hace falta Docker.
- **Claude Code** con los plugins del playbook (abajo).

## Arrancar en una máquina nueva

```bash
git clone git@github.com:MatPizzolo/my-radar-ideas.git && cd my-radar-ideas
make bootstrap                 # 1. crea .env (sin mostrar valores) y .playbook/, chequea herramientas
claude plugin marketplace add github:MatPizzolo/my-playbook      # 2. una vez por máquina
claude plugin install my-flow@my-playbook
make doctor                    # 3. plugin, .playbook/, rutas absolutas
```

4. Abrí `claude` en la raíz y corré `/estado`: te dice la etapa, las ramas y el último `make ci` verde. Después, `/etapa M0` (o la que siga).

`make help` lista todos los comandos.

## Comandos del día a día

| Comando | Qué hace |
|---|---|
| `make lint` / `make test` | estilo, tipos y tests unitarios, sin red ni claves |
| `make ci` | la única puerta: lint, tests y gitleaks; deja `.playbook/ci-ok` |
| `make estado` | regenera el bloque vivo de `docs/etapas/ESTADO.md` |
| `make push` | `pull --rebase --autostash` + `push -u` + verificación del SHA remoto |
| `make handoff` | lista ramas sin upstream y worktrees sucios; falla si hay |




## Mantener el kit

`uvx copier update --trust` trae la última versión del playbook (Makefile, reglas ECC, prompts) sin pisar los documentos del proyecto. Las respuestas están en `.copier-answers.yml`.
