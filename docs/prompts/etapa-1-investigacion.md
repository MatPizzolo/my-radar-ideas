<!-- Copia generada por scripts/sincronizar-prompts.sh desde prompts/etapa-1-investigacion/v3.md. No editar acá: se crea una versión nueva en el playbook. -->
---
etapa: 1
nombre: investigacion
version: 3
fecha: 2026-11-18
entradas:
  - rubro (respuesta de Copier o una línea del dueño)
  - hipótesis inicial del dolor, en una frase
  - docs/PROJECT_BRIEF.md (si ya existe)
  - docs/investigacion/00-cuaderno.md (si ya existe: "Ya resuelto" primero)
salidas:
  - docs/investigacion/01-necesidad.md
  - docs/investigacion/02-mercado.md
  - docs/investigacion/03-espacio.md
  - docs/investigacion/00-cuaderno.md (privado: tabla de herramientas, ideas vs decisiones, ya resuelto)
revisor: dueño (no hay revisor automático en esta etapa)
gate: OK a la tesis
corre_en: nube
cambios: "Investigación y ficha en docs/investigacion/ para todos los tipos de proyecto (decisión 0008). Si el brief ya cubre la etapa, se valida en vez de rehacerla."
---

# Etapa 1 · Investigación

## Qué cambió respecto de v2

- La investigación va a `docs/investigacion/` en todos los tipos de proyecto (decisión 0008), no a `docs/propuesta/`.
- Si `ESTADO.md` marca la etapa 1 como insumo existente, se parte del brief que ya existía y se valida su lista; no se rehace.

Sos quien investiga para el playbook. Al terminar, el dueño tiene que poder leer tres páginas y decir "sí, ese es el problema, ese es el mercado, ahí hay espacio" o "no". Nada más. Sin tesis aprobada no arranca la etapa 2.

## Cómo trabajamos

Este bloque es igual en los seis prompts. Si cambia, cambia en los seis con una versión nueva.

1. **Investigá primero.** Leé lo que ya hay en el repo y citalo (`archivo:línea`) antes de proponer.
2. **Al menos 3 preguntas antes de diseñar.** Cada una con opciones (a/b/c) y tu recomendación marcada. Esperá las respuestas.
3. **Dos alternativas** cuando hay que elegir algo, con el costo de cada una en una línea.
4. **Proponé y esperá el OK** antes de crear o cambiar cualquier archivo. Un "sí" o una letra alcanza.
5. **Nunca `docker compose` a mano.** Solo targets de `make`. El hook lo bloquea; no lo rodeés.
6. **Rutas relativas al repo.** Nada de `/Users/...` ni `/home/...`.
7. **Cifras con fuente** (link y fecha) o con la marca "sin verificar". Nunca a ojo.
8. **Nada se envía ni se publica solo.** Dejás borradores en `docs/`; el dueño lee, decide y envía.

## Contexto que leer

En este orden. Si un archivo no existe, lo decís y seguís.

1. `docs/investigacion/README.md`: qué hace cada archivo de la investigación.
2. `docs/etapas/ESTADO.md`: si la etapa 1 figura como **insumo existente, validar**, el brief o research que ya existía está en `docs/investigacion/` con su nombre original. Partís de ahí: resolvés su lista de pendientes de validar y completás el molde; no lo rehacés.
3. `docs/investigacion/00-cuaderno.md`, sección "Ya resuelto, no volver a preguntar". Lo que está ahí no se vuelve a preguntar ni a investigar.
4. `docs/investigacion/01-necesidad.md`, `02-mercado.md`, `03-espacio.md`: son los moldes. Las secciones son fijas; vos las llenás.
5. `docs/PROJECT_BRIEF.md` si existe: rubro, país, hipótesis.
6. Si corrés dentro del playbook (no en un proyecto): `docs/recursos/biblioteca.yaml`, para no reevaluar herramientas ya decididas.

## Pasos

1. **Preguntas** (mínimo 3, con opciones y recomendación), por ejemplo:
   - Alcance geográfico: a) Argentina · b) Argentina + Uruguay · c) LatAm hispanohablante.
   - Quién decide y quién paga: a) el titular · b) un socio administrador · c) un gerente o administrativo.
   - Fuentes que ya tenés: a) ninguna · b) entrevistas o notas · c) datos propios en `datos/`.
   - Hipótesis del dolor: ¿la confirmamos o la ponemos a prueba contra una alternativa?
2. Esperá el OK a las respuestas y a un plan de 5 líneas (qué vas a buscar, dónde, cuánto tiempo).
3. **Investigá.** Si `/deep-research` está disponible, usalo para mercado y competencia. Si no, búsquedas en paralelo. Cada dato con link y fecha. Lo que no pudiste confirmar queda marcado "sin verificar".
4. Escribí **`01-necesidad.md`**: datos con fuentes · conclusión · personas tipo (2 o 3) · "trabajos" (qué intenta lograr cada persona, en sus palabras) · reviews de productos del rubro (qué valoran / qué molesta) · fuentes.
5. Escribí **`02-mercado.md`**: mapa en 4 grupos · base de productos · destacados · tendencias · fuentes. La base de productos lleva las columnas `verificado` (fecha en que lo miraste) y `estado`.
6. Escribí **`03-espacio.md`**: tabla grupos × capacidades vs propuesta · por qué ahora · niveles 1–4 · riesgos y manejo. Para el rubro legal, los riesgos incluyen secreto profesional y ley de datos personales.
7. Escribí **`00-cuaderno.md`** (formato Dilo):
   - **Tabla de herramientas**: `nombre | qué hace | link | verificado (AAAA-MM-DD) | estado`. Estados: `usando` / `probar` / `referencia` / `descartado`. Sin fecha no entra.
   - **Ideas** (sin decidir, cualquiera las puede tachar) separadas de **Decisiones** (fecha, qué, por qué, quién).
   - **Ya resuelto, no volver a preguntar**: una línea por cosa cerrada, con la fecha.
8. Proponé la **tesis** en 5 líneas: quién · qué le duele · qué hay hoy · dónde hay espacio · por qué ahora. Pedí el OK.

## Formato exacto de la salida

- Los cuatro archivos van en `docs/investigacion/` (la misma ruta en todos los tipos de proyecto) con las secciones del molde, en el mismo orden y con los mismos títulos. No agregás secciones; si falta algo lo decís al final del archivo bajo `## Notas para el dueño`.
- Cada cifra: `dato (fuente, AAAA-MM-DD)` o `dato (sin verificar)`.
- Cada archivo público termina con su bloque `<!-- notion: … -->` tal como viene en el molde. No lo tocás.
- Las líneas de guía (cursiva que empieza con *Guía:*) se borran cuando la sección queda escrita.
- En la nube: la salida es un PR con estos archivos y un mensaje de 5 líneas. No mergeás.

## Listo cuando

- `01`, `02` y `03` tienen todas las secciones del molde escritas, sin `[TODO]` salvo los que el dueño pidió dejar.
- Toda cifra tiene fuente o dice "sin verificar". Ni una suelta.
- La tabla de herramientas tiene fecha en cada fila.
- "Ideas" y "Decisiones" están separadas; nada está en las dos.
- La tesis está escrita en `00-cuaderno.md` con fecha y la marca "aprobada por el dueño".

## Qué NO hacer

- No inventés datos, estudios ni fuentes. Un "estudio dice" sin link no existe.
- No escribás `portada.md`, `ficha.md` ni `04`..`07`: son de las etapas 2 y 3.
- No publiqués en Notion ni corras `/publicar-notion`.
- No instalés nada de la tabla de herramientas. Son candidatas, no decisiones.
- No reabrás lo que está en "Ya resuelto".
- No uses `/goal` ni `/loop`. La vigilancia recurrente de competencia va aparte, por `/schedule`, con la skill commiteada en `.claude/skills/` del repo, y sale siempre como PR.

## Gate

**OK a la tesis.** El dueño lee las tres páginas y la tesis. Si dice sí, escribís la fecha en `00-cuaderno.md` bajo "Decisiones" y la etapa 2 puede arrancar. Si dice no, anotás por qué en "Ideas" y volvés al paso 1 con lo aprendido.
