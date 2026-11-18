# 0002 — Un repo por idea aprobada, sin incubadora

- Fecha: 2026-11-18
- Estado: Aceptada
- Reemplaza a: los acuerdos 1 (la parte "deja un PR en incubadora") y 5 (skills en `incubadora/proyectos/<slug>/`) del ADR 0001. El resto del 0001 sigue vigente.

## Contexto
El brief proponía un repo `incubadora` con una carpeta por idea aprobada (radar-ideas.md:55), para no crear un repo por cada OK. El owner prefiere que cada idea aprobada sea desde el principio un proyecto completo del playbook, con su propio repo, CLAUDE.md, reglas y hooks. La validación de la etapa 1 (`docs/investigacion/validacion.md`, #10 y #15) mostró que una rutina en la nube solo trabaja con los repos que tiene conectados. Un repo que la rutina crea durante la corrida probablemente no le sirva para pushear, pero eso no está documentado.

## Decisión
Cada idea aprobada por el radar sale con su propio repo, generado con Copier desde `gh:MatPizzolo/my-playbook`, y el repo `incubadora` se elimina. Para decidir cómo corre el arranque, se suma a la prueba P1 un paso que crea un repo y pushea a él desde una rutina:
- **si funciona**, la rutina arranque crea el repo de la idea, corre copier y la etapa 1, y deja un PR en ese repo;
- **si da 403**, el merge del PR del radar es el OK y el owner corre el arranque en local con `/my-flow:nuevo-proyecto`, usando como brief la propuesta mergeada (`docs/ideas/propuestas/<fecha>-<slug>.md`).

## Consecuencias
- Cada idea nace con su repo, así que no hace falta mudarla al llegar a la etapa 4. A cambio, por cada OK aparece un repo nuevo en la cuenta.
- La protección de `main` sin bypass tiene que aplicarse a cada repo nuevo. Mientras la cuenta no tenga GitHub Pro, los repos van públicos; la propuesta y la investigación de cada idea quedan a la vista.
- Si el arranque queda en local, se pierde el "mergeo desde el celular y arranca solo". El merge sigue registrando el OK en `registro.yaml`, y el radar del día siguiente recuerda las ideas aprobadas que todavía no tienen repo.
- La skill `investigar` viaja con cada proyecto generado (`skills_en_la_nube=[investigar]`) solo si el arranque corre en la nube. En local la carga el plugin.
- `CLAUDE.md`, `README.md` y `docs/PROJECT_BRIEF.md` se actualizan en este mismo cambio. `.copier-answers.yml` sigue con los acuerdos viejos: un `copier update` volvería a escribir el texto de incubadora en el CLAUDE.md. Hay que corregir los acuerdos en las respuestas antes del próximo update.
- Trip-wire: si P1 confirma que la rutina puede crear un repo y pushear a él, pero ese repo queda sin protección de `main` en el momento del primer push, revisar esta decisión antes de prender la rutina.

## Alternativas
- **Mantener `incubadora`** (lo que proponía el brief): un solo repo conectado a la rutina y sin repos nuevos. El owner lo descartó porque mezcla proyectos y después obliga a mudarlos.
- **Darle a la rutina un token propio de GitHub** como secreto del entorno: probablemente le permita crear repos y pushear, pero choca con la decisión 0006 del playbook (OAuth, ninguna clave escrita) y le da permiso sobre todos los repos de la cuenta.
