# Evaluación continua

La suma de todas las actividades ofertadas es **15 puntos**; puedes hacer las que prefieras hasta alcanzar 
el **máximo de 10 puntos** de la evaluación continua.

| Actividad | Puntos | Se presenta | Entrega (23:59) | Se resuelve | Carpeta |
|---|---:|---|---|---|---|
| **Actividad 1** · Análisis de una estrategia sintética con opciones (*long straddle*) | 5.0 | Clase 2 (sem. 2) | **lun 23/11/2026** | Clase 4 (sem. 4) | [actividad-1-straddle](actividad-1-straddle/) |
| **Actividad 2** · Construcción de una cartera financiera de mínimo riesgo | 6.0 | Clase 5 (sem. 5) | **lun 14/12/2026** | Clase 7 (sem. 7) | [actividad-2-cartera-minimo-riesgo](actividad-2-cartera-minimo-riesgo/) |
| **Microtests** (30: tres por tema) | 4.0 | Semanal | **dom 10/01/2027** | — | [microtests](../microtests/) |
| **Total ofertado** | **15.0** | | | | |

> ⚠️ **Las entregas se hacen en el aula virtual de UNIR, no en GitHub.** Este repositorio contiene 
> enunciados resumidos, plantillas y código de apoyo. El enunciado oficial es el publicado en el aula.

## Formato común de entrega (ambas actividades)

- **Código** en `.py` o `.ipynb`, **debidamente comentado** y que **se ejecute sin errores** de principio a fin.
- **El código entregado debe ser autocontenido**: usa solo `numpy`, `scipy`, `pandas` y `matplotlib` e implementa 
  tú las fórmulas. La biblioteca `mvdc` de este repositorio sirve para estudiar y **comprobar** resultados, 
  pero quien corrige no la tendrá instalada.
- **Informe en PDF**, máximo **6 páginas de cuerpo** (no cuentan portada, resumen, índices, referencias ni anexos), 
  siguiendo el [Formato Básico para Documentos Universitarios Evaluables](../plantillas/formato-basico-documentos.md).
- Se acepta el informe como **Jupyter Notebook** solo si sigue ese mismo formato; en caso contrario, únicamente PDF.
- Si importas datos, **adjúntalos**.
- Informe y código se suben **por separado**; el resto de archivos en `.zip` o `.7z`.
- Nombre de archivos:
  - Actividad 1: `apellido1 nombre1.extensión`
  - Actividad 2: `Grupo.apellido1 nombre1.extensión`
- **Cualquier entrega que no cumpla estos requisitos no se evalúa.** Antes de subir, ejecuta 
  [`herramientas/verificar_entrega.py`](../herramientas/verificar_entrega.py).
