# Estado del proyecto

- **Etapa actual:** ninguna (M0 pendiente; se abre con `/etapa M0`).
- **Próxima etapa:** M0 Esqueleto.

## Etapas del playbook (herramienta-interna)

| Etapa | Estado | Notas |
|---|---|---|
| 1 Investigación | tesis aprobada (2026-11-18), con ajustes | `docs/investigacion/radar-ideas.md` validado en `docs/investigacion/validacion.md`. Pendiente: pruebas P1 y P2 en la nube antes de M0. |
| 5 Construcción (M0–M5) | pendiente | |

**Insumo de la etapa 1** (`docs/investigacion/radar-ideas.md`). Pendiente de validar:

- [x] Trigger de GitHub 'PR merged' en rutinas y filtro por etiqueta (radar-ideas.md:49, :262) [3ros]
- [x] Topes diarios de corridas de rutinas en tu plan (radar-ideas.md:279) [3ros, se contradicen] → refutado, ver validacion.md #2
- [x] Endpoint por rutina con token, para la v2 con Telegram (radar-ideas.md:50) [3ros]
- [x] Eventos de issues como trigger (radar-ideas.md:81) [sin verificar]
- [x] Páginas de portfolio de cada aceleradora (radar-ideas.md:100) [sin verificar] → YC, Techstars y Station F prohíben robots (validacion.md #5)
- [x] Fuentes de LatAm, India e Israel (radar-ideas.md:104) [sin verificar] → Geektime se cae (validacion.md #6)
- [x] API de HN y Algolia (radar-ideas.md:108) [sin verificar]
- [x] Términos de Bumeran, ZonaJobs y Computrabajo (radar-ideas.md:125) [sin verificar] → prohíben bots: solo fragmentos de búsqueda (validacion.md #8)
- [x] Que firecrawl y perplexity por OAuth anden dentro de una rutina (no está en el brief) → desde .mcp.json no conectan; como conectores de claude.ai sí (ADR 0004)
- [x] Que la rutina arranque pueda clonar gh:MatPizzolo/my-playbook (privado) para el copier copy → refutado en P1; el arranque pasa a GitHub Actions (ADR 0003)
- [x] Que uvx exista en el entorno de la nube → confirmado en P1 (uvx 0.11.32)
- [x] Que la nube cargue .claude/skills/ de una subcarpeta (incubadora/proyectos/<slug>/) → ya no aplica (ADR 0002 y 0003)
- [x] Si /schedule acepta la hora de Buenos Aires (07:41) o hay que pasarla a UTC

## Decisiones

**Resueltas**

- [x] Kit de arranque: el playbook, tipo herramienta-interna (ADR 0001).
- [x] Decisión 0005 §4 (/schedule solo deja PRs de etapas 1 y 6) y GATE 1: arranque corre copier y la etapa 1 en el repo propio de la idea y deja un PR ahí (ADR 0002). Las etapas 2 y 3 las corre el owner en local, con sus gates. (ADR 0001).
- [x] Nada se mergea, publica ni envía solo (decisiones 0002 y 0005): El radar puede cerrar esos PRs con el comentario 'sin decisión'; nunca mergea ni borra ramas. Cerrar se deshace reabriendo. (ADR 0001).
- [x] Decisión 0006 (conectores por proyecto, por OAuth, sin escritura en la nube): Sin Gmail en la v1. firecrawl y perplexity por OAuth, solo lectura; perplexity cobra por llamada y entra en el tope de costo; los tests usan fixtures. En claude.ai se sacan de las rutinas los conectores con escritura. (ADR 0001).
- [x] my-playbook guarda plantillas y plugins: docs/ideas/, el PR diario y el trigger 'PR merged' viven en my-radar-ideas. (ADR 0001).
- [x] La nube no carga plugins (skills en .claude/skills/ del repo donde corren): Este repo va con skills_en_la_nube vacío. Si el arranque corre en la nube, genera el repo de cada idea con corre_en_la_nube=true y skills_en_la_nube=[investigar]; si corre en local, la skill la carga el plugin (ADR 0002). (ADR 0001).
- [x] Única puerta: `make ci` escribe `.playbook/ci-ok`.

**Diferidas**

- [ ] Dónde se hostea el pipeline (M5).
- [ ] Arranque por GitHub Actions (ADR 0003): falta la prueba P3b.
- [ ] Lectura en la nube (ADR 0004): falta la prueba P3a.
- [ ] GitHub Pro para proteger repos privados; mientras tanto, my-radar-ideas y los repos de ideas van públicos.

## Backlog

- [ ] Completar los `[TODO]` de `docs/PROJECT_BRIEF.md` antes de `/etapa M0`.
- [ ] Revisar `docs/cumplimiento.md` antes de la primera publicación.
- [ ] **P3a, prueba de red antes de M0** (ADR 0004; la hace el owner en la web):
  - [ ] En claude.ai/code, editar el entorno `radar`: red en "Limited", destildar "Allow package managers" y cargar en Allowed domains, uno por línea: betakit.com, www.betakit.com, techcrunch.com, sifted.eu, eu-startups.com, www.eu-startups.com, tech.eu, technode.com, pandaily.com, contxto.com, latamlist.com, inc42.com, yourstory.com, www.joinef.com, seedcamp.com, www.ycombinator.com, hacker-news.firebaseio.com, hn.algolia.com.
  - [ ] Abrir una sesión en ese entorno y correr el prompt de P3a (abajo). Pasar la tabla para cerrar el ADR 0004.
  - [ ] Si una URL da 403 sin `x-deny-reason`, la bloquea el propio sitio: esa fuente pasa a leerse con Firecrawl. Si aparece `x-deny-reason`, falta sumar ese dominio (por ejemplo, el de un CDN o una redirección).
- [ ] **Conector de Perplexity para búsqueda** (ADR 0004): en claude.ai/customize/connectors, "Add custom connector" con `https://api.perplexity.ai/mcp`. Se entra con OAuth eligiendo una organización de la API de Perplexity. Saldo prepago y recarga automática apagada: ese es el tope de costo.

  Prompt de P3a:
  ```txt
  Prueba de red, solo lectura. Para cada URL corré `curl -s -o /dev/null -w "%{http_code}" -D - URL | grep -iE "^HTTP|x-deny-reason"` y reportá el código y si aparece x-deny-reason:
  https://betakit.com/feed/ https://techcrunch.com/feed/ https://sifted.eu/feed https://www.eu-startups.com/feed/ https://tech.eu/feed/ https://technode.com/feed/ https://pandaily.com/feed/ https://contxto.com/es/feed/ https://latamlist.com/feed/ https://inc42.com/feed/ https://yourstory.com/feed https://www.joinef.com/feed/ https://seedcamp.com/feed/ https://www.ycombinator.com/blog/feed https://hacker-news.firebaseio.com/v0/topstories.json https://hn.algolia.com/api/v1/search_by_date?tags=show_hn
  Además, un WebFetch de https://hacker-news.firebaseio.com/v0/topstories.json.
  Al final, una tabla: URL · código · x-deny-reason sí/no.
  ```
- [ ] **Preparar P3b antes de M0** (ADR 0003; lo hace el owner en la web):
  - [ ] Crear la GitHub App `radar-bot` en github.com/settings/apps/new, sin webhook. Permisos: Administration, Contents y Pull requests en escritura; Metadata en lectura.
  - [ ] Instalarla en la cuenta con "All repositories". Ojo: con Administration en escritura también puede borrar repos, así que la clave va solo como secreto de Actions.
  - [ ] En `my-radar-ideas`, cargar la variable `RADAR_APP_ID` y el secreto `RADAR_APP_PRIVATE_KEY`.
  - [ ] Correr `claude setup-token` en local y cargar el resultado como secreto `CLAUDE_CODE_OAUTH_TOKEN` (dura un año: renovarlo antes de que venza).
  - Después: primera card de M0, el workflow `radar-probe` (`workflow_dispatch`), revisado con `agentic-actions-auditor` antes de correrlo.

## Historial

| Etapa | Estado | Fecha | Notas |
|---|---|---|---|
| M0 | pendiente | | |
| M1 | pendiente | | |
| M2 | pendiente | | |
| M3 | pendiente | | |
| M4 | pendiente | | |
| M5 | pendiente | | |

<!-- generado:inicio (scripts/estado.py, no editar a mano) -->
## Dónde estamos (todavía no generado: corré `make estado`)
- Ramas de trabajo: ninguna
- Worktrees: ninguno
- Último `make ci` verde: ninguno registrado (corré `make ci`)
- Cards activas: ninguna
<!-- generado:fin -->
