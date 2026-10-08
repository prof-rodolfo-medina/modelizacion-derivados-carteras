# Actividad 1 · Análisis de una estrategia sintética con opciones

| | |
|---|---|
| **Valor** | 5.0 puntos |
| **Presentación** | Clase 2 · semana del 09/11/2026 |
| **Entrega** | **Lunes 23/11/2026, 23:59** (aula virtual) |
| **Resolución** | Clase 4 · semana del 23/11/2026 |
| **Temas de apoyo** | Tema 1 (B/P de call y put) y Tema 2 (estrategias combinadas) |
| **Material del repo** | [Clase 1](../../sesiones/semana-01/), módulo [`mvdc.payoffs`](../../src/mvdc/payoffs.py), [plantilla](plantilla-actividad-1.ipynb) |

## Objetivo

Analizar la estrategia **long straddle**: compra simultánea de una **call** y una **put** sobre el mismo 
subyacente, con **idéntico precio de ejercicio $E$** y **misma fecha de vencimiento $T$**.

## Planteamiento

Un inversor, con el subyacente cotizando hoy a $S_0$:

- compra una call con prima $C$, precio de ejercicio $E$ y vencimiento $T$;
- compra una put con prima $P$, el mismo $E$ y el mismo $T$.

Sea $S_T$ el precio del subyacente al vencimiento. No hay costes de transacción ni comisiones. 
El inversor busca beneficiarse de una **alta volatilidad** del subyacente.

## Preguntas

1. Desembolso inicial total del inversor (expresión algebraica).
2. Valor de la call y de la put al vencimiento (expresiones algebraicas).
3. Posición neta final del inversor al vencimiento, considerando la estrategia completa.
4. ¿Bajo qué condiciones sobre $S_T$ es rentable la estrategia? Explícalo.
5. Código en Python que grafique el perfil de ganancia/pérdida total en función de $S_T$ con 
   **$C = 5$ €, $E = 100$ €, $P = 4$ €**, identificando claramente los puntos relevantes del gráfico.

## Criterios de evaluación

| Criterio | Descripción | Peso |
|---|---|---:|
| 1 | Calidad del informe: formato y claridad de los contenidos | 50 % |
| 2 | Código debidamente comentado y que se ejecuta correctamente | 10 % |
| 3 | Respuestas correctas a las preguntas | 40 % |

> El 50 % del peso está en el **informe**: cuida portada, índice, introducción (objetivo, justificación, 
> metodología), figuras numeradas y referenciadas, conclusiones y bibliografía en un estilo reconocido.

## Lista de comprobación antes de entregar

- [ ] Las cinco preguntas están respondidas con expresiones algebraicas y explicación.
- [ ] La gráfica tiene título, ejes rotulados, leyenda y marca los puntos relevantes (¿cuáles son?).
- [ ] El código se ejecuta de principio a fin en un kernel limpio (*Restart & Run All*).
- [ ] Informe en PDF ≤ 6 páginas de cuerpo, Times New Roman/Arial 12, interlineado 1.5, márgenes 2.5 cm, justificado, páginas numeradas.
- [ ] Archivos nombrados `apellido1 nombre1.pdf` y `apellido1 nombre1.ipynb` (o `.py`), subidos por separado.
- [ ] `python herramientas/verificar_entrega.py --actividad 1 <archivos>` sin errores.

## Sugerencias

- Implementa los pagos con `numpy` en tu propio código (debe ejecutarse sin la biblioteca del curso). 
  Puedes usar `mvdc.payoffs` (`long_call`, `long_put`, `breakeven_points`...) para **comprobar** tus resultados.
- Para ir más allá (no obligatorio): compara con un *short straddle* o con un *strangle*, o estima con el 
  modelo log-normal (Tema 5) la probabilidad de que la estrategia termine en beneficios.
