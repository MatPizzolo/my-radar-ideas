# Decisiones de arquitectura (ADR)

Cada ADR registra una decisión, su contexto y sus consecuencias. Son cortos, numerados y **no se reescriben**: si una decisión cambia, se escribe un ADR nuevo que reemplaza al anterior y el viejo solo cambia su `Estado:` (el hook `scope_guard` permite exactamente eso). Formato: `NNNN-slug.md` con **Fecha**, **Estado**, Contexto, Decisión, Consecuencias.

Los ADR los escribe el orquestador al cerrar cada etapa (`/cerrar-etapa`) o con `/decision` cuando aparece una decisión estructural en el GATE 1.

| # | Título | Estado |
|---|---|---|
| [0001](0001-kit-de-arranque.md) | Kit de arranque: el playbook | Aceptada |

Los ADR del proyecto arrancan en 0002 y no los pisa `copier update`.
