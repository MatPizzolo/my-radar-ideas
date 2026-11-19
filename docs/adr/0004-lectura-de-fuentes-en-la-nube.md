# 0004 — Cómo lee y busca el radar en la nube

- Fecha: 2026-11-18
- Estado: Aceptada

## Contexto
En P1 y P2b, con la red en "Limited", fallaron `curl` y WebFetch a los feeds y a la API de HN (`403` y `ENOTFOUND`). Los servidores de `.mcp.json` (firecrawl y perplexity) no conectaron (`ERR_PROXY_TUNNEL`). En cambio, los conectores de claude.ai funcionaron sin login. El conector "Perplexity_Computer" que estaba conectado no tiene búsqueda.

## Decisión
- El radar corre en el entorno `radar` con la red en "Limited" y una lista explícita de **Allowed domains**: los feeds y HN de `validacion.md`. Nunca con la red en "Full".
- Usa la **WebSearch integrada** para descubrir, lee los feeds y la API de HN con curl o WebFetch, y usa el **conector Firecrawl** de claude.ai (plan gratis) para los sitios sin RSS o que bloquean bots.
- Suma el **Perplexity de búsqueda** (`https://api.perplexity.ai/mcp`, `perplexity_search`) como conector propio en claude.ai, con OAuth y saldo prepago.
- La rutina incluye solo Firecrawl y Perplexity. Se sacan todos los demás conectores (Drive, Docs, Sheets, Notion, Canva, Figma, Claude_Docs, claude-code-remote y Perplexity_Computer), porque todos tienen herramientas de escritura (P2b).
- `.mcp.json` mantiene firecrawl y perplexity solo para uso local.

## Consecuencias
- Perplexity cuesta unos USD 1 a 5 por mes con ~30 búsquedas diarias (USD 5 cada 1.000, o USD 1 con Fast Search). No tiene plan gratis. El tope de costo del prompt cuenta las búsquedas de Perplexity y las de Firecrawl.
- Firecrawl en el plan gratis da 1.000 créditos por mes (búsqueda: 2; scrape: 1 por página). Si se acaban, el radar lo dice en el PR y sigue con WebSearch.
- Cada fuente nueva necesita sumar su dominio a la lista del entorno `radar`. `fuentes.yaml` anota el modo de acceso de cada una: rss, búsqueda, firecrawl o prohibido.
- Los conectores pasan por fuera de la lista de dominios: una inyección de prompt podría usarlos. Por eso la rutina tiene solo esos dos, y ninguno escribe.
- Trip-wire: si P3a muestra feeds bloqueados por el propio sitio (403 sin `x-deny-reason`), esa fuente pasa a leerse con Firecrawl.

## Alternativas
- **Red en "Full":** más simple, pero cualquier inyección podría mandar datos a cualquier host.
- **Exa o Tavily en lugar de Perplexity:** tienen plan gratis sin tarjeta. El owner eligió Perplexity; quedan como reemplazo si el costo o la calidad no cierran.
- **Firecrawl para todo, incluidos los feeds:** funciona, pero gasta créditos y devuelve contenido de caché, no en vivo (P2b).
