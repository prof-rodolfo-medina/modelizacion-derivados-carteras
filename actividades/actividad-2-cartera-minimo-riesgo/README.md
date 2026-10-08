# Actividad 2 · Construcción de una cartera financiera de mínimo riesgo

| | |
|---|---|
| **Valor** | 6.0 puntos |
| **Presentación** | Clase 5 · semana del 30/11/2026 |
| **Entrega** | **Lunes 14/12/2026, 23:59** (aula virtual) |
| **Resolución** | Clase 7 · semana del 14/12/2026 |
| **Temas de apoyo** | Tema 8 (notación, Lagrange) y Tema 9 (mínimo riesgo, frontera de Markowitz) |
| **Material del repo** | [Clase 6](../../sesiones/semana-06/), módulo [`mvdc.portfolio`](../../src/mvdc/portfolio.py), [plantilla](plantilla-actividad-2.ipynb), [datos](../../datos/) |

## Objetivo

Desarrollar soltura en Python aplicado al análisis de datos financieros y construir una **cartera de inversión 
de mínimo riesgo con al menos tres activos**, a partir de datos simulados o reales, graficando la 
**frontera eficiente de Markowitz**.

## Tareas

A partir de una base de datos con cotizaciones de grandes empresas (por ejemplo, del IBEX-35) **o** de datos 
simulados, selecciona **al menos tres activos** y:

1. Carga los datos en Python.
2. Calcula las estadísticas necesarias: rendimientos esperados, varianzas y covarianzas.
3. Construye la cartera de mínimo riesgo con la metodología del temario.
4. Grafica la frontera eficiente de Markowitz y **marca la cartera de mínimo riesgo**.
5. Analiza los resultados y discute las implicaciones financieras de la cartera óptima.

## Opciones de datos

| Opción | Cómo | Observaciones |
|---|---|---|
| Datos simulados del repositorio | `mvdc.datos.cargar("cartera_simulada.csv")` | 5 activos ficticios, 2 años diarios. Elige al menos 3. |
| Datos reales del IBEX-35 | `python herramientas/descargar_ibex.py SAN.MC ITX.MC IBE.MC --inicio 2024-01-01` | Requiere `pip install yfinance`. **Adjunta el CSV** en tu entrega. |
| Tus propios datos simulados | Generados en tu código (documenta el modelo y la semilla) | Justifica los parámetros elegidos. |

## Criterios de evaluación

| Criterio | Descripción | Peso |
|---|---|---:|
| 1 | Calidad del informe: formato y claridad de los contenidos | 50 % |
| 2 | Código debidamente comentado y que se ejecuta correctamente | 10 % |
| 3 | Cálculo de las estadísticas necesarias | 10 % |
| 4 | Gráfica de la frontera eficiente con la cartera de mínimo riesgo marcada | 10 % |
| 5 | Análisis de los resultados | 20 % |

## Lista de comprobación antes de entregar

- [ ] Al menos 3 activos; se explica por qué se eligieron y de dónde salen los datos (periodo, frecuencia, fuente).
- [ ] Rendimientos definidos como en el Tema 8 (log-retornos) y se indica si están anualizados.
- [ ] Vector $m$, matriz $C$ y matriz de correlaciones presentados en tablas numeradas.
- [ ] Pesos $w^*$ de mínimo riesgo, con $\sum w_i = 1$ comprobado; se comentan posibles ventas en corto.
- [ ] Frontera eficiente graficada, con la cartera de mínimo riesgo y los activos individuales marcados.
- [ ] Análisis: diversificación, papel de las correlaciones, riesgo vs. rendimiento, limitaciones (estabilidad de $C$, datos históricos).
- [ ] Datos adjuntos; el código se ejecuta en un kernel limpio **sin depender de `mvdc`** (implementa $w^*$ y la frontera con `numpy`).
- [ ] Informe ≤ 6 páginas de cuerpo con el formato básico.
- [ ] Archivos nombrados `Grupo.apellido1 nombre1.extensión`.
- [ ] `python herramientas/verificar_entrega.py --actividad 2 <archivos>` sin errores.
