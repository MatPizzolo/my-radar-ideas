# Estado del proyecto

- **Etapa actual:** ninguna (M0 pendiente; se abre con `/etapa M0`).
- **Próxima etapa:** M0 Esqueleto.

## Etapas del playbook (herramienta-interna)

| Etapa | Estado | Notas |
|---|---|---|
| 1 Investigación | insumo existente, validar | `docs/investigacion/radar-ideas.md`: validar antes de seguir (lista abajo). No se rehace. |
| 5 Construcción (M0–M5) | pendiente | |

**Insumo de la etapa 1** (`docs/investigacion/radar-ideas.md`). Pendiente de validar:

- [ ] Trigger de GitHub 'PR merged' en rutinas y filtro por etiqueta (radar-ideas.md:49, :262) [3ros]
- [ ] Topes diarios de corridas de rutinas en tu plan (radar-ideas.md:279) [3ros, se contradicen]
- [ ] Endpoint por rutina con token, para la v2 con Telegram (radar-ideas.md:50) [3ros]
- [ ] Eventos de issues como trigger (radar-ideas.md:81) [sin verificar]
- [ ] Páginas de portfolio de cada aceleradora (radar-ideas.md:100) [sin verificar]
- [ ] Fuentes de LatAm, India e Israel (radar-ideas.md:104) [sin verificar]
- [ ] API de HN y Algolia (radar-ideas.md:108) [sin verificar]
- [ ] Términos de Bumeran, ZonaJobs y Computrabajo (radar-ideas.md:125) [sin verificar]
- [ ] Que firecrawl y perplexity por OAuth anden dentro de una rutina (no está en el brief)
- [ ] Que la rutina arranque pueda clonar gh:MatPizzolo/my-playbook (privado) para el copier copy
- [ ] Que uvx exista en el entorno de la nube
- [ ] Que la nube cargue .claude/skills/ de una subcarpeta (incubadora/proyectos/<slug>/)
- [ ] Si /schedule acepta la hora de Buenos Aires (07:41) o hay que pasarla a UTC

## Decisiones

**Resueltas**

- [x] Kit de arranque: el playbook, tipo herramienta-interna (ADR 0001).
- [x] Decisión 0005 §4 (/schedule solo deja PRs de etapas 1 y 6) y GATE 1: arranque corre copier y la etapa 1, y deja un PR en incubadora. Las etapas 2 y 3 las corre el owner en local, con sus gates. (ADR 0001).
- [x] Nada se mergea, publica ni envía solo (decisiones 0002 y 0005): El radar puede cerrar esos PRs con el comentario 'sin decisión'; nunca mergea ni borra ramas. Cerrar se deshace reabriendo. (ADR 0001).
- [x] Decisión 0006 (conectores por proyecto, por OAuth, sin escritura en la nube): Sin Gmail en la v1. firecrawl y perplexity por OAuth, solo lectura; perplexity cobra por llamada y entra en el tope de costo; los tests usan fixtures. En claude.ai se sacan de las rutinas los conectores con escritura. (ADR 0001).
- [x] my-playbook guarda plantillas y plugins: docs/ideas/, el PR diario y el trigger 'PR merged' viven en my-radar-ideas. (ADR 0001).
- [x] La nube no carga plugins (skills en .claude/skills/ del repo donde corren): Este repo va con skills_en_la_nube vacío. El prompt de arranque genera cada proyecto en incubadora/proyectos/<slug>/ con corre_en_la_nube=true y skills_en_la_nube=[investigar], así la skill viaja con cada proyecto y sigue la versión del plugin. (ADR 0001).
- [x] Única puerta: `make ci` escribe `.playbook/ci-ok`.

**Diferidas**

- [ ] Dónde se hostea el pipeline (M5).

## Backlog

- [ ] Completar los `[TODO]` de `docs/PROJECT_BRIEF.md` antes de `/etapa M0`.
- [ ] Revisar `docs/cumplimiento.md` antes de la primera publicación.

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
