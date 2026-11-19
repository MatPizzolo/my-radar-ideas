# Validación del insumo de la etapa 1

Valida la lista "validar" de `docs/etapas/ESTADO.md` contra el insumo `docs/investigacion/radar-ideas.md`. No lo rehace.
Todas las fuentes se consultaron el **2026-11-18**. Ninguna página de la documentación de Claude Code muestra fecha de "última actualización".
`docs/routines` es https://code.claude.com/docs/en/routines; `docs/cloud-env` es https://code.claude.com/docs/en/cloud-environments; `docs/skills` es https://code.claude.com/docs/en/skills.

> Las rutinas ahora se llaman "scheduled tasks (formerly routines)". La URL claude.ai/code/routines y la API siguen diciendo "routines". Siguen en *research preview* (docs/routines).

## Tabla

| # | Punto | Resultado | Fuente | Qué cambia en el diseño |
|---|---|---|---|---|
| 1 | Trigger de GitHub "PR merged" y filtro por etiqueta (radar-ideas.md:49, :262) | **Confirmado.** "a GitHub trigger runs on `pull_request.closed` filtered to merged PRs". Hay filtros "Is merged" y "Labels". Todas las condiciones tienen que cumplirse. También se puede configurar desde el CLI (v2.1.225+), no solo desde la web: eso refuta radar-ideas.md:48. Requiere la Claude GitHub App instalada en el repo. | docs/routines | Nada en el flujo. Hay que instalar la GitHub App en `my-radar-ideas` (`/web-setup` no alcanza). |
| 2 | Topes diarios de corridas (radar-ideas.md:279) | **Refutado.** El tope de 5 por día en Pro y 15 en Max existió al lanzar ([blog del 2026-04-14](https://claude.com/blog/introducing-routines-in-claude-code)) y se sacó el **2026-06-18**, no en octubre ([changelog](https://claude.com/docs/cowork/changelog)): ahora las corridas consumen el uso normal del plan. Quedan topes por hora: 100 corridas programadas por cuenta, 30 disparos a mano o por API por tarea y 100 disparos por API por cuenta. Los topes de eventos de GitHub no se publican, y "events beyond the limit are dropped". | docs/routines | No hay tope diario. El tope de costo del prompt pasa a ser el único freno. Si se pierde un evento de merge, el arranque no corre: el radar del día siguiente tiene que detectar un PR mergeado que no tiene PR en incubadora y avisarlo. |
| 3 | Endpoint por rutina con token, para la v2 con Telegram (radar-ideas.md:50) | **Confirmado.** "Each scheduled task has its own token, scoped to triggering that task only." El token se genera solo en la web y se muestra una sola vez. `/fire` necesita el header `anthropic-beta: experimental-cc-routine-2026-04-01`. El texto que llega por `/fire` se trata como no confiable salvo que el prompt guardado diga lo contrario. | docs/routines | La v2 es viable. El Worker manda el header beta, y el prompt de arranque dice explícitamente qué campo del payload usar (solo el slug, nunca instrucciones). |
| 4 | Eventos de issues como trigger (radar-ideas.md:81) | **Confirmado en parte.** Hay eventos de issue (opened, edited, closed, labeled…). No hay eventos de **comentarios** en issues ni en PRs. | docs/routines | Sin cambios: el diseño usa el merge. Un comentario nunca dispara nada, así que el descarte (cerrar con comentario) solo lo lee el radar al otro día, como ya dice el brief. |
| 5 | Páginas de portfolio de las aceleradoras (radar-ideas.md:100) | **Confirmado en parte; refutado como lectura automática en 4 casos.** Los términos de [YC](https://www.ycombinator.com/legal) (directorio y Launch YC), [Techstars](https://www.techstars.com/terms-of-use) y [Station F](https://stationf.co/terms) prohíben robots y scraping. [a16z speedrun](https://speedrun.a16z.com/terms-of-use) prohíbe reutilizar los datos. El robots.txt de Antler bloquea las páginas de cada empresa. 500 Global solo se ve con JavaScript. Plug and Play no tiene un portfolio público. Entrepreneurs First (`joinef.com/feed/`) y Seedcamp (`seedcamp.com/feed/`) tienen RSS y no encontramos términos que lo prohíban. | Links en la columna anterior; robots.txt de cada sitio | **Launch YC y el directorio de YC dejan de ser una fuente "fija diaria" leída directo** (radar-ideas.md:98-99 y :138). Se leen solo por resultados de búsqueda web y por el feed del blog de YC (`ycombinator.com/blog/feed`). `fuentes.yaml` guarda un modo de acceso por fuente (rss / búsqueda / prohibido). |
| 6 | Fuentes de LatAm, India e Israel (radar-ideas.md:104) | **Confirmado, salvo Geektime.** Contxto está activo (`contxto.com/es/feed/`, notas del 16 y 17/11). LatamList, Inc42 (con muro de pago medido) y YourStory tienen RSS. Geektime no se puede usar: el dominio en inglés está "Under Construction" y el hebreo devuelve 403 de Cloudflare. Europa, Canadá y China: Sifted (muro de pago; el feed `sifted.eu/feed` funciona), EU-Startups, Tech.eu, BetaKit, TechNode y Pandaily tienen RSS. KrASIA y 36Kr English no tienen RSS. | Feeds verificados con curl el 2026-11-18 | Geektime sale de la lista. Para Israel, CTech (calcalistech.com) queda como candidata **sin verificar**. KrASIA y 36Kr se leen por búsqueda. |
| 7 | API de HN y Algolia (radar-ideas.md:108) | **Confirmado.** La [API oficial](https://github.com/HackerNews/API) es pública, sin clave y "There is currently no rate limit". [Algolia HN](https://hn.algolia.com/api) es pública y sin clave, pero su límite de uso y sus términos están **sin fuente**. | Links | HN pasa de "exploratorio" a una fuente estable vía API. Ojo: los hosts `hacker-news.firebaseio.com` y `hn.algolia.com` probablemente haya que sumarlos a Allowed domains en la nube (inferencia, ver el punto 17). |
| 8 | Términos de Bumeran, ZonaJobs y Computrabajo (radar-ideas.md:125) | **Refutado como fuente que se lee con la herramienta.** Los tres prohíben bots y scripts aunque su robots.txt lo permita. Bumeran y ZonaJobs: "cualquier máquina, software, herramienta, agente u otro mecanismo para navegar o buscar en este Sitio Web" (términos en la app de JS, versión del 2022-12-02). [Computrabajo](https://ar.computrabajo.com/avisolegal/): "el copiado mediante tecnologías de buscador tipo 'Robot/Crawler' … queda prohibido expresamente". | Links | Solo se usan títulos y fragmentos que devuelve una búsqueda web general, sin abrir las páginas de los sitios. La regla propia 2 del CLAUDE.md ya lo cubre. Hay que anotarlo en `fuentes.yaml`. |
| 9 | firecrawl y perplexity por OAuth dentro de una rutina | **Sin fuente.** Los conectores de claude.ai funcionan en rutinas sin login, y la nube autentica por vos. Los servidores de `.mcp.json` se cargan **solo en una tarea con un solo repo**, el login OAuth es una tarjeta interactiva que puede vencer, y no hay nada que diga que funcione sin nadie mirando. Los hosts de `.mcp.json` probablemente tengan que estar en Allowed domains. **Además:** todos tus conectores de claude.ai entran por defecto en cada rutina, **con escritura**. | docs/routines; https://code.claude.com/docs/en/mcp | **Necesita una prueba (P2).** Mientras tanto, el radar v1 lee solo con WebSearch, WebFetch y RSS (radar-ideas.md:16 ya lo permite). Si firecrawl y perplexity no andan desde `.mcp.json`, hay que elegir entre agregarlos como conectores de claude.ai o usar una clave como secreto del entorno (choca con la decisión 0006). Es una decisión abierta. |
| 10 | Que arranque pueda clonar `gh:MatPizzolo/my-playbook` (privado) | **Sin fuente directa; probablemente refutado.** "An API request for another repository gets a 403 … `is not enabled for this session`", lo mismo para archivos tar o zip de `codeload`, "even a public one". Git usa una credencial limitada a los repos conectados. No hay una frase sobre `git clone` en sí. | docs/cloud-env (GitHub proxy) | **Necesita una prueba (P1).** El arreglo esperable es conectar `my-playbook` como repo de la tarea arranque. Eso la vuelve multi-repo y tiene un costo (ver el punto 15). Con el ADR 0002 se suma una duda más: si la rutina puede **crear un repo nuevo y pushear a él**. También va en P1. |
| 11 | Que `uvx` exista en la nube | **Confirmado en parte.** Viene "Python 3.x with pip, poetry, uv…" en Ubuntu 24.04. `uvx` no se menciona; normalmente viene con `uv` (inferencia). Un setup script puede instalar con `pip install uv`, porque PyPI está permitido. `astral.sh` **no** está en la lista por defecto. | docs/cloud-env (installed tools, setup scripts, allowlist) | **Prueba trivial (P1).** Si falta, el arranque usa `uv tool run copier`, o el setup script corre `pip install uv`. Nunca `curl astral.sh`. |
| 12 | Que la nube cargue `.claude/skills/` de una subcarpeta (`incubadora/proyectos/<slug>/`) | **Confirmado, con carga diferida.** "Skills in a `.claude/skills/` directory below where you started don't load at startup. They load the first time Claude reads or edits a file in that subdirectory." Hasta entonces no se pueden invocar por nombre. `/add-dir` las carga antes. Lo mismo pasa con el CLAUDE.md anidado. Si dos skills se llaman igual, la anidada se invoca como `/<subdir>:<nombre>`. | docs/skills; https://code.claude.com/docs/en/memory | El acuerdo de ADR 0001 (la skill viaja con cada proyecto) **se mantiene**, con un paso más en el prompt de arranque: después del `copier copy`, leer `proyectos/<slug>/CLAUDE.md` (o correr `/add-dir proyectos/<slug>`) y recién ahí invocar investigar. Conviene confirmarlo en P1. **Con el ADR 0002 deja de aplicar:** cada idea tiene su propio repo y el proyecto queda en la raíz, así que la skill carga al arrancar. |
| 13 | Si `/schedule` acepta 07:41 de Buenos Aires o hay que pasarla a UTC | **Confirmado.** Con los presets se escribe "the time in your local time zone". Un cron de 5 campos va en UTC, salvo que lleve el prefijo `CRON_TZ=`. El mínimo es una vez por hora. No dice si acepta el nombre IANA `America/Argentina/Buenos_Aires`. | docs/routines | Usar el preset diario a las 07:41 hora local, o el cron `41 10 * * *` (UTC; Argentina es UTC-3 sin horario de verano). Sin prueba: alcanza con mirar "próxima corrida" en la web al crearla. |

## Hallazgos que no estaban en la lista y cambian el diseño

| # | Hallazgo | Fuente | Qué cambia |
|---|---|---|---|
| 14 | **`gh pr` y `gh issue` no funcionan en la nube**: "The proxy rejects subcommands that use GraphQL, such as `gh pr` and `gh issue`", aunque pongas tu propio `GH_TOKEN`. La API REST con `gh api` sí funciona. | docs/cloud-env | El prompt de radar-ideas.md:330 (`gh pr list --label radar …`) **no funciona**. Hay que reescribirlo con `gh api repos/{o}/{r}/pulls?state=closed…` y cerrar los PRs sin decisión con `gh api -X PATCH …/pulls/{n} -f state=closed` (inferencia, porque la documentación solo dice que REST funciona). Va en M0. |
| 15 | **Una tarea multi-repo no aplica `.claude/settings.json`**: lee solo `enabledPlugins` y `extraKnownMarketplaces`, "not permission rules, hooks, `env`", y tampoco carga `.mcp.json`. | https://code.claude.com/docs/en/settings | Si el arranque tiene `incubadora` más `my-playbook` (punto 10), **el deny de los conectores con escritura y los hooks no corren**. La protección queda en sacar los conectores en claude.ai y en la protección de ramas. El acuerdo 0006 del ADR 0001 ("conectores con escritura en deny") se debilita para el arranque. |
| 16 | **El proxy no limita a qué rama se pushea**: "It doesn't limit which branches a push can update. To do that, use branch protection rules or rulesets", y las reglas que tu usuario puede saltear no frenan una corrida. | docs/cloud-env; docs/routines | La protección de `main` (radar-ideas.md:275) tiene que tener activado **"Do not allow bypassing"** (o un ruleset sin bypass para admins). Si no, la rutina, que actúa como vos, puede pushear a `main`. |
| 17 | La red por defecto es "Limited", con GitHub, PyPI y los gestores de paquetes permitidos. Los conectores no pasan por esa lista; los sitios de RSS y las APIs de HN probablemente sí (inferencia). | docs/cloud-env | Hay que definir Allowed domains para el entorno del radar (los feeds del punto 6 y HN), o probar si WebFetch sale por fuera de esa lista. Se incluye en P1. |

## Pruebas propuestas (no corridas)

Las dos son tareas "Run now", sin schedule ni triggers y con todos los conectores sacados. `incubadora` ya no existe (ADR 0002), así que el repo conectado es `my-radar-ideas`.

- **P1. Entorno, clonación y repo nuevo (puntos 10, 11, 14 y 17, más el ADR 0002).** Es una tarea con **solo** `my-radar-ideas` conectado. El prompt pide correr y reportar; lo único que escribe es el repo de prueba del paso 5:
  1. `uv --version && uvx --version`
  2. `git ls-remote https://github.com/MatPizzolo/my-playbook HEAD`
  3. `gh api "repos/MatPizzolo/my-radar-ideas/pulls?state=all&per_page=1"` (REST) y `gh pr list -R MatPizzolo/my-radar-ideas` (debería fallar)
  4. `curl -sI https://betakit.com/feed/ | head -1` y un WebFetch de la misma URL
  5. `gh api -X POST user/repos -f name=prueba-arranque -F private=false`; después, en `/tmp/pa`: `git init -b main`, un README, un commit y `git push https://github.com/MatPizzolo/prueba-arranque main`

  Si el paso 2 da 403, se repite con `my-playbook` conectado como segundo repo y se suma `uvx copier copy --trust --defaults --data-file <yaml de prueba> gh:MatPizzolo/my-playbook /tmp/p`.
  Si el paso 5 crea el repo pero el push da 403, el arranque queda en local (ADR 0002). Al terminar, el owner borra `prueba-arranque`.
  Costo: una corrida corta del plan.
- **P2. Conectores (punto 9).** Es la misma tarea, con `my-radar-ideas` como **único** repo (para que cargue `.mcp.json`). Se pide listar las herramientas MCP disponibles y hacer una búsqueda con perplexity y un scrape con firecrawl. Se anota si aparece la tarjeta de login.

## Resumen

1. La arquitectura del brief se sostiene: el trigger "PR merged" con filtro por etiqueta `radar` y el endpoint por rutina para la v2 están confirmados en la documentación oficial.
2. El tope diario de corridas no existe desde el 2026-06-18: todo consume el uso normal del plan, y solo quedan topes por hora. Los eventos de GitHub que pasan el tope se pierden sin aviso.
3. Hay que reescribir el prompt diario: `gh pr` no funciona en la nube (se usa `gh api`), y Launch YC, el directorio de YC y las bolsas de empleo solo se pueden leer por búsqueda web, nunca abriendo sus páginas.
4. El arranque es la parte frágil. Clonar el playbook privado casi seguro exige conectarlo como segundo repo, y eso apaga el deny, los hooks y `.mcp.json`. Con un repo por idea (ADR 0002), además hay que probar si la rutina puede crear un repo y pushear a él; si no puede, el arranque queda en local.
5. Quedan dos pruebas cortas (P1 y P2) antes de M0. Mientras tanto, el radar v1 lee solo con WebSearch, WebFetch y RSS.

## Qué decisiones del brief se caen o cambian

| Decisión del brief | Estado |
|---|---|
| "Algunas fuentes hablan de 5 corridas diarias en Pro y 15 en Max" (radar-ideas.md:279) | **Se cae.** No hay tope diario; el tope de costo del prompt es el único freno. |
| "El trigger de GitHub … se configura en la web" (radar-ideas.md:48) | **Cambia.** También se puede desde el CLI (v2.1.225+). |
| "Fijo diario: Launch YC y TechCrunch" (radar-ideas.md:138) | **Cambia.** Launch YC solo por búsqueda; TechCrunch por RSS. |
| Avisos de empleo "por búsqueda web" (radar-ideas.md:125) | **Se ajusta.** Solo resultados de búsqueda, sin abrir las páginas de los sitios. |
| Geektime para Israel (radar-ideas.md:104) | **Se cae.** CTech queda como candidata sin verificar. |
| `gh pr list --label radar …` en el prompt (radar-ideas.md:330) | **Se cae.** Se reemplaza por `gh api` (REST). |
| "Las rutinas solo tienen acceso a `my-playbook` e `incubadora`" (radar-ideas.md:271) | **Cambia (ADR 0002).** No hay `incubadora`: cada idea tiene su repo. El radar usa `my-radar-ideas`. El arranque depende de P1: en la nube necesitaría `my-playbook` más el repo nuevo (multi-repo, sin deny ni hooks); si no, corre en local. |
| Protección de `main` "no permite saltearla" (radar-ideas.md:275) | **Se refuerza.** Tiene que estar sin bypass para admins; el proxy no lo impide. |
| Acuerdo ADR 0001: firecrawl y perplexity en las rutinas | **Queda abierto** hasta P2. |
| Acuerdo ADR 0001: la skill investigar viaja con cada proyecto | **Reemplazado por el ADR 0002.** Viaja solo si el arranque corre en la nube; ya no hay subcarpeta. |

## Resultados de P1 y P2 (2026-11-18)

Las dos se corrieron como sesiones comunes de Claude Code en la web (la misma VM y el mismo proxy que una rutina), con solo `my-radar-ideas` conectado y la red en "Limited". P1 corrió sin conectores y P2 con los conectores de claude.ai.

### P1. Entorno

| Paso | Resultado | Salida textual | Cierra |
|---|---|---|---|
| 1 `uv` / `uvx` | **Funcionó** | `uv 0.11.32`, `uvx 0.11.32` | #11 confirmado |
| 2 `git ls-remote` de `my-playbook` (privado, no conectado) | **Falló** | `fatal: could not read Username for 'https://github.com': terminal prompts disabled` | #10 refutado con un solo repo |
| 3a `gh api …/pulls` (REST) | **Funcionó** | `1` | #14 confirmado |
| 3b `gh pr list` | **Falló** | `HTTP 403: GitHub GraphQL is not available from Claude Code sessions` | #14 confirmado |
| 4a `curl` del RSS de BetaKit | **Falló** | `HTTP/1.1 403 Forbidden` | #17 confirmado: la red "Limited" no deja salir |
| 4b WebFetch del mismo feed | **Falló** | `getaddrinfo ENOTFOUND betakit.com` | #17: WebFetch también pasa por la red de la VM |
| 5a crear un repo (`POST user/repos`) | **Falló** | `This GitHub API path is not available: sessions are bound to their configured repositories` (403) | ADR 0002: la rutina no puede crear repos |
| 5b `git init` y commit local | Funcionó | commit `33ebda9` en `/tmp/pa` | — |
| 5c push al repo nuevo | **Falló** | `access denied by the git proxy: MatPizzolo/prueba-arranque is not in this session's authorized repository set` (403) | ADR 0002: tampoco puede pushear a un repo que no esté conectado |
| Extra: `.mcp.json` al arrancar | **Falló** | firecrawl y perplexity: `ERR_PROXY_TUNNEL: Proxy refused to open a tunnel: 403 Forbidden` | #9: los servidores de `.mcp.json` no salen con la red "Limited" |

### P2. Conectores de claude.ai

| Conector | Disponible | Funcionó | Nota | Cierra |
|---|---|---|---|---|
| Firecrawl | Sí | **Sí**: scrape de seedcamp.com/our-companies con 200 y unos 52.700 caracteres | Sin pedido de login. Pasa por fuera de la lista de dominios permitidos. | #9 confirmado para Firecrawl como conector |
| Perplexity_Computer | Sí | **No** | Es otro producto: tiene 4 herramientas para importar dashboards y ninguna de búsqueda. | #9 refutado para Perplexity con este conector |
| Google Drive/Docs/Sheets, Notion, Canva, Figma, Claude_Docs, claude-code-remote | Sí | No probados | **Entran por defecto y con escritura** (#9). Hay que sacarlos de cada rutina. | — |

### Qué queda abierto

Todavía no se busca acá la vuelta a cada falla. Para cada una se investiga una alternativa que funcione:
- arranque: crear el repo, clonar el playbook y pushear;
- red: feeds, WebFetch y `.mcp.json`;
- búsqueda: Perplexity.

### P2b. Prompt para los conectores que no se probaron (no corrida)

Es una sesión común en claude.ai/code con solo `my-radar-ideas`, la red en "Limited" y **todos** los conectores de claude.ai. Responde dos preguntas: qué conectores sirven para el radar y qué escritura habría que sacarle a cada rutina.

```txt
Prueba de conectores, SOLO LECTURA. Prohibido crear, editar, borrar, comentar, compartir, mover o publicar nada en ningún conector, y prohibido escribir en el repo. Si una prueba necesita escribir, no la hagas y anotalo.

Para CADA conector MCP que tengas (Firecrawl, Perplexity_Computer, Google Drive, Google Docs, Google Sheets, Notion, Canva, Figma, Claude_Docs, claude-code-remote y cualquier otro):
a) Listá sus herramientas y marcá cuáles escriben (crean, editan, borran, envían o comparten).
b) Hacé UNA llamada de solo lectura, la más chica posible:
   - Google Drive: buscá archivos con el texto "radar", máximo 1 resultado.
   - Google Docs / Sheets: si la búsqueda de Drive devolvió un archivo de ese tipo, leé solo su título; si no, anotá "sin archivo para probar".
   - Notion: buscá "radar", máximo 1 resultado.
   - Canva: buscá diseños con "radar", máximo 1 resultado.
   - Figma: whoami.
   - Claude_Docs: la consulta o el listado de solo lectura más chico que tenga.
   - claude-code-remote: listá los entornos y las tareas programadas, solo lectura.
   - Perplexity_Computer: si tiene alguna herramienta de búsqueda, buscá "Launch YC Fall 2026"; si no, anotalo.
c) Si aparece un pedido de login o de autorización, anotalo y no lo aceptes.

Además, para el radar:
1. WebSearch (la herramienta integrada): buscá "site:ycombinator.com/launches Fall 2026" y reportá si devolvió resultados.
2. Firecrawl search: buscá "fintech startup Argentina seed round 2026", máximo 3 resultados.
3. Firecrawl scrape de un feed RSS: https://betakit.com/feed/ ; decí si trajo XML con ítems.
4. WebFetch de https://hacker-news.firebaseio.com/v0/topstories.json ; decí si trajo datos.

Al final, dos tablas:
- Conector · herramientas de escritura (lista) · llamada de lectura · funcionó sí/no · error textual.
- Prueba del radar (1 a 4) · funcionó sí/no · error textual.

### Resultados de P2b (2026-11-18)

Ningún conector escribió nada y ninguno pidió login.

| Prueba | Resultado | Nota |
|---|---|---|
| WebSearch `site:ycombinator.com/launches Fall 2026` | **Parcial** | Respondió, pero no respetó `site:` y casi todo vino de terceros (Extruct, Crustdata). Sirve para descubrir; no reemplaza a la fuente oficial. |
| Firecrawl search (3 resultados) | **Funcionó** | Ejemplo: UIN (fintech argentina) levantó USD 2M de seed, LatamList, 2026-10-02. Cuesta 2 créditos. |
| Firecrawl scrape de `betakit.com/feed/` | **Funcionó** | Trajo XML RSS 2.0 con 150 ítems, **de la caché de Firecrawl**, no en vivo. |
| WebFetch de la API de HN | **Falló** | `getaddrinfo ENOTFOUND hacker-news.firebaseio.com` (dominio no permitido). |
| Perplexity_Computer | **No sirve** | No tiene búsqueda. |
| Drive, Notion, Canva, Figma, Claude_Docs | Leen bien | **Todos tienen herramientas de escritura.** Ninguno lo usa el radar: hay que sacarlos de cada rutina. |
| claude-code-remote | Lee bien | Hay 3 entornos (`radar`, `dilo-studio`, `Default`) y ninguna tarea. **Tiene `add_repo`, `create_session`, `fire_trigger` y `update_environment`**: es candidato para el arranque (ver la propuesta). |

## Alternativas para lo que falló (investigado el 2026-11-18)

[V] = está en la documentación oficial · [I] = inferido, sin probar.

### Arranque: crear el repo de la idea, generar con Copier, investigar y abrir el PR

Ninguna vía de la nube de Claude puede crear un repo ni conectar a una corrida un repo elegido en el momento:
- `/fire` acepta solo `text` [V];
- la lista de repos de una rutina se cambia solo a mano [V];
- `claude --cloud` no sirve desde un CI efímero, porque su token dura 30 días [V];
- el proxy rechaza `POST user/repos` [P1].

| # | Alternativa | Cómo funciona | Costo y riesgo | Estado |
|---|---|---|---|---|
| A | **GitHub Actions hace todo** | Un workflow en `my-radar-ideas` se dispara con `pull_request: closed` + merged + etiqueta `radar`. Pasos: un token de una GitHub App propia ("radar-bot") crea el repo público con solo un README en `main` [V: `POST /user/repos` con permiso Administration o Repository creation] → checkout de `my-playbook` y `copier copy` local → `anthropics/claude-code-action` con `CLAUDE_CODE_OAUTH_TOKEN` (tu suscripción, generado con `claude setup-token`) [V] investiga en una rama → un `gh pr create` fijo abre el PR. | Gratis en un repo público [V]. Dos secretos de Actions, no escritos en archivos: la clave de la App y el token OAuth, que dura un año. Que la action trabaje sobre otro repo distinto del suyo está **sin documentar [I]**. | Necesita la prueba P3b |
| B | Actions crea el repo y genera, y **un link de un toque** arranca la investigación | Igual que A hasta Copier. Después el workflow comenta en el PR un link `claude.ai/code?repositories=MatPizzolo/<slug>&prompt=…` [V: los parámetros prellenan la sesión], y la investigación arranca cuando tocás el link desde el celular. | Un solo secreto (la App) y nada de Claude en CI. Cuesta un toque. | Variante de A, también va con P3b |
| C | La rutina investiga y Actions solo mueve archivos | La rutina, disparada por el merge, investiga dentro de `my-radar-ideas` y abre un PR. Cuando lo mergeás, Actions crea el repo, genera con Copier y copia la investigación. | Ningún token de Claude en CI. Suma una revisión más, y la investigación no corre dentro del proyecto generado. | Posible, más incómoda |
| D | Projects (beta): un hilo se agrega el repo nuevo a sí mismo [V] | — | Está en beta y no se sabe si una tarea de proyecto se puede disparar sola. Además, los hilos no cargan las skills del repo. | Descartada por ahora |
| E | Conector oficial de GitHub (MCP) en la rutina | Tiene `create_repository`, `push_files` y `create_pull_request` [V]. | Es un conector **con escritura sin supervisión** y con alcance sobre todos tus repos (choca con las decisiones 0005 y 0006). Hay bugs abiertos. | Descartada |

### Red: feeds, WebFetch y `.mcp.json`

- **Por qué falló [V]:** "a `403` or a DNS error such as `ENOTFOUND` can mean that the requested host isn't on the cloud environment's allowlist" (https://code.claude.com/docs/en/errors). WebFetch sale desde la VM y pasa por la misma lista.
- **Arreglo [V]:** en el entorno `radar`, que ya existe, se deja la red en "Limited" y se cargan los dominios en **Allowed domains**, uno por línea; `*.` cubre los subdominios. Los cambios se aplican en alrededor de un minuto (https://code.claude.com/docs/en/cloud-environments). "Full" no conviene: si un feed trae una inyección de prompt, podría mandar datos a cualquier host.
- **Lista inicial:** betakit.com, techcrunch.com, sifted.eu, eu-startups.com, tech.eu, technode.com, pandaily.com, contxto.com, latamlist.com, inc42.com, yourstory.com, joinef.com, seedcamp.com, ycombinator.com, `*.ycombinator.com`, hacker-news.firebaseio.com y hn.algolia.com. Hay que cargar cada dominio solo y con `www.`, porque no está documentado si `*.` incluye el dominio pelado.
- **`.mcp.json` en la nube [I]:** el OAuth no funciona sin nadie mirando. En la nube conviene usar los conectores de claude.ai, que no pasan por la lista. `.mcp.json` queda para uso local.

### Búsqueda: Perplexity

- **"Perplexity_Computer" no es el buscador [V]:** es el agente Computer de Perplexity. El buscador es otro servidor, `https://api.perplexity.ai/mcp` (`perplexity_search`), y se paga: USD 5 cada 1.000 búsquedas, o USD 1 con Fast Search, sin plan gratis (https://docs.perplexity.ai/getting-started/pricing).
- **WebSearch integrada [V]** "runs a query against Anthropic's web search backend". No pasa por la red de la VM y entra en el uso del plan. En P2b sirvió para descubrir, pero no respetó `site:`.
- **Firecrawl como conector [P2b]:** la búsqueda y el scrape funcionan. El plan gratis trae 1.000 créditos por mes [V]; la búsqueda cuesta 2 créditos y el scrape 1 por página.
- **Exa [V]:** USD 10 de crédito gratis por mes, sin tarjeta; unos USD 4 a 7 por mes para 30 búsquedas diarias. **Tavily [V]:** 1.000 créditos gratis por mes, sin tarjeta.

### Pruebas que faltan

- **P3a. Red:** en el entorno `radar` con la lista cargada, correr `curl -sI <feed> | grep -i x-deny-reason` para cada feed y un WebFetch a la API de HN.
- **P3b. Arranque A/B:** un workflow `workflow_dispatch` que: crea el token de la App → `POST user/repos` (`radar-probe`) → `copier copy` desde el checkout de `my-playbook` → `claude-code-action` con un prompt mínimo ("escribí HELLO.md") en el repo nuevo → `gh pr create`. Después se borra `radar-probe`.
