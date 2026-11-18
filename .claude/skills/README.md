# Skills del proyecto

Acá viven tres tipos de skills, y conviene no mezclarlos:

1. **Alias del playbook** (`etapa/`, `cerrar-etapa/`, `estado/`). Son de una línea: delegan en la skill homónima del plugin `my-flow` (`/my-flow:etapa`, etc.) para que se pueda seguir tecleando `/etapa`. La lógica vive en el plugin y se actualiza con `claude plugin update`; estas carpetas no se editan.

2. **Skills que corren en la nube.** Las sesiones y tareas programadas en la nube (`/schedule`, `claude --cloud`, `/autofix-pr`) **no cargan los plugins de `.claude/settings.json` ni `~/.claude/skills`**. Todo lo que tenga que correr allá (vigilancia de competencia, borradores de contenido de la etapa 6, investigación recurrente de la etapa 1) va commiteado acá, en una carpeta propia con su `SKILL.md`, y sale siempre como PR de borradores en `docs/` sin conectores con escritura.

3. **Copias de my-flow para la nube.** Si el proyecto se generó con `corre_en_la_nube`, el playbook copia acá las skills de `skills_en_la_nube` (por ejemplo `investigar/`) con un aviso arriba: si `my-flow` está instalado, se usa `/my-flow:<skill>`. Las renueva cada `copier update`; no se editan a mano. Si `estado` está en la lista, la copia completa reemplaza al alias.

Convenciones:

- Una carpeta por skill, `SKILL.md` con frontmatter `name` y `description` (la descripción dice cuándo usarla, en rioplatense).
- Las skills de la nube llevan `disable-model-invocation: true` si publican o envían algo: eso lo hace el owner.
- Si una skill de acá madura y sirve para otros proyectos, se mueve al playbook (`plugins/my-playbook-*/skills/`) y acá queda un alias.
