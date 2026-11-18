# Prompts de las etapas del playbook

El playbook versiona en `prompts/etapa-N-<nombre>/vN.md` el prompt de cada una de sus seis etapas (1 Investigación · 2 A quién va · 3 Página · 4 Lanzamiento cuidado · 5 Construcción · 6 Marketing). **Copier copia acá la versión vigente de cada etapa que aplica al tipo de este proyecto** (lo dice `CLAUDE.md`) al generar el proyecto y la renueva con `copier update`.

- Si un prompt tiene una sección "Según el tipo de proyecto", se sigue solo la del tipo de `.copier-answers.yml`.
- Los archivos de esta carpeta no se editan: si un prompt necesita cambiar, se propone en el playbook como `vN+1.md` y llega con la próxima actualización.
- Si este proyecto necesita una variante propia, va en `docs/prompts/local/` con una nota de por qué, y se evalúa subirla al playbook.
- `make lint-prompts` revisa esta carpeta junto con `docs/etapas/`: nada de `docker compose` a mano ni rutas absolutas.

Si la carpeta está vacía es porque la versión del playbook con la que se generó el proyecto todavía no publicaba prompts: `copier update` los trae.
