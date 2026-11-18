---
name: etapa
description: Abre una etapa de construcción (M0–M5) con plan, GATE 1, leads por área y cards. Alias local de la skill del plugin my-flow para seguir tecleando /etapa.
argument-hint: M0 | M1 | M2 | M3 | M4 | M5
---

# /etapa $ARGUMENTS

Delegá en la skill `my-flow:etapa` con los mismos argumentos: invocá `/my-flow:etapa $ARGUMENTS` y seguí sus instrucciones al pie de la letra.

Si el plugin `my-flow` no está instalado (la skill no existe), frená y pedile al owner que corra `make doctor` y `claude plugin install my-flow@my-playbook`. No improvises el flujo de la etapa sin el plugin.
