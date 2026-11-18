# 0003 — El arranque corre en GitHub Actions

- Fecha: 2026-11-18
- Estado: Aceptada
- Reemplaza a: la parte "cómo corre el arranque" del ADR 0002. Sigue vigente que cada idea tiene su repo.

## Contexto
P1 (`docs/investigacion/validacion.md`) confirmó que una sesión o rutina en la nube no puede crear un repo (`POST user/repos` da 403) ni pushear a un repo que no esté conectado. La documentación tampoco ofrece forma de conectar, en el momento de disparar, un repo elegido entonces (`/fire` acepta solo `text` y la lista de repos de una rutina se edita a mano). El owner quiere que el arranque sea automático. Por eso la parte de GitHub tiene que correr fuera de la nube de Claude.

## Decisión
Cuando el owner mergea un PR con la etiqueta `radar` en `my-radar-ideas`, un workflow de GitHub Actions hace el arranque:
1. Con un token de una GitHub App propia (`radar-bot`), crea el repo público de la idea, con solo un README en `main`.
2. Genera el proyecto con `copier copy` desde un checkout de `my-playbook`.
3. Corre la etapa 1 con `anthropics/claude-code-action` en una rama, autenticado con `CLAUDE_CODE_OAUTH_TOKEN` (la suscripción del owner, no la API paga).
4. Abre el PR con un paso fijo de `gh pr create`.

Nada entra a `main` sin que lo mergee el owner.

## Consecuencias
- **Choque con la decisión 0006 del playbook (OAuth, ninguna clave escrita):** hay dos secretos en GitHub Actions, la clave privada de la App (sus tokens duran alrededor de una hora) y el token OAuth de `claude setup-token` (dura un año). Ninguno queda escrito en archivos. El owner lo aceptó. Hay que renovar el token de Claude cada año y revocarlo si se filtra.
- La App se instala con "All repositories", para que cubra los repos que ella misma crea (con "selected" no está documentado). Permisos mínimos: Administration (para crear repos) y Contents y Pull requests en escritura.
- El texto de la idea le llega a Claude por un archivo o una variable de entorno, nunca interpolado con `${{ }}` en `run:` ni en `prompt`. El workflow pasa por la skill `agentic-actions-auditor` antes de prenderse.
- Es gratis mientras `my-radar-ideas` sea público (runners estándar). La investigación consume del plan del owner.
- Que `claude-code-action` funcione sobre un repo distinto del que lo dispara **no está documentado**. Lo confirma la prueba P3b.
- Trip-wire: si P3b falla en ese paso, se pasa a la variante B de `validacion.md` (Actions crea el repo y genera, y un link de un toque abre la sesión de investigación).

## Alternativas
- **B. Actions + un toque:** un solo secreto y nada de Claude en CI, pero no es automático. Queda como plan de respaldo.
- **Arranque local** (lo que decía el ADR 0002 si P1 fallaba): cero secretos, pero el owner lo quiere automático.
- **Conector de GitHub con escritura en la rutina:** escritura sin supervisión sobre todos los repos (choca con 0005 y 0006) y tiene bugs abiertos.
- **Projects (beta):** no se sabe si una tarea de proyecto se puede disparar sola.
