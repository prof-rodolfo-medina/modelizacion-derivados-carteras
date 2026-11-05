# Modelización y Valoración de Derivados y Carteras en Finanzas

**Maestría en Ciencias Computacionales y Matemáticas Aplicadas · UNIR** · Edición noviembre–diciembre 2026  
Docente: **Rodolfo Rafael Medina** · [github.com/prof-rodolfo-medina](https://github.com/prof-rodolfo-medina)

[![Pruebas](https://github.com/prof-rodolfo-medina/modelizacion-derivados-carteras/actions/workflows/ci.yml/badge.svg)](https://github.com/prof-rodolfo-medina/modelizacion-derivados-carteras/actions/workflows/ci.yml)

Repositorio de apoyo para las **sesiones síncronas**: cuadernos Jupyter de cada clase, una pequeña biblioteca de 
Python (`mvdc`) que implementa los métodos del temario, datos, plantillas de las actividades y herramientas para 
revisar las entregas.

> El aula virtual de UNIR sigue siendo el canal oficial: allí están los enunciados oficiales, se entregan 
> las actividades y se responden los microtests.
>
> **Dudas:** plantéalas en la sesión síncrona o en el foro **«Pregúntale a tu profesor»** del aula virtual. 
> Este repositorio es solo de consulta: no se atienden *issues*, *pull requests* ni mensajes por GitHub.

---

## Calendario

Las sesiones síncronas son los **miércoles a las 20:00 h (Ciudad de México)**.

| Sem. | Fechas | Temas | Sesión síncrona | Evaluación |
|---:|---|---|---|---|
| 0 | antes del 02/11 | Python esencial (autoestudio, opcional) | — · [cuaderno](sesiones/semana-00/) | — |
| 1 | 02/11 – 06/11 | 1. Introducción a las opciones · 2. Estrategias sintéticas | **mié 04/11** · [Clase 1](sesiones/semana-01/) y presentación (90′) | Microtests 1.x, 2.x |
| 2 | 09/11 – 13/11 | 3. Árboles binomiales I | **mié 11/11** · [Clase 2](sesiones/semana-02/) y **presentación Actividad 1** (60′) | Microtests 3.x |
| 3 | 16/11 – 20/11 | 4. Árboles binomiales II · Hull-White | **mié 18/11** · [Clase 3](sesiones/semana-03/) (60′) | Microtests 4.x |
| 4 | 23/11 – 27/11 | 5. Modelo log-normal | **mié 25/11** · [Clase 4](sesiones/semana-04/) y **resolución Actividad 1** (90′) | 🔴 **Actividad 1: lun 23/11 23:59** · Microtests 5.x |
| 5 | 30/11 – 04/12 | 6. Estimación y predicción · 7. Black-Scholes | **mié 02/12** · [Clase 5](sesiones/semana-05/) y **presentación Actividad 2** (60′) | Microtests 6.x, 7.x |
| 6 | 07/12 – 11/12 | 8. Fundamentos de carteras · 9. Markowitz | **mié 09/12** · [Clase 6](sesiones/semana-06/) (60′) | Microtests 8.x, 9.x |
| 7 | 14/12 – 18/12 | 10. Cartera mixta y CAPM | **mié 16/12** · [Clase 7](sesiones/semana-07/) y **resolución Actividad 2** (90′) | 🔴 **Actividad 2: lun 14/12 23:59** · Microtests 10.x |
| — | 21/12 – 03/01 | *Periodo no lectivo* | — | — |
| 8 | 04/01 – 08/01/2027 | Repaso | **mié 06/01** · [Clase 8](sesiones/semana-08/) · Repaso (90′) | **Examen** |
| — | **10/01/2027** | | | 🔴 **Fecha límite de los 30 microtests** |

> Fechas según la programación semanal oficial: del 21/12/2026 al 03/01/2027 es periodo no lectivo y la semana 8 (repaso y examen) es del 04 al 08/01/2027. Si el aula virtual publica otra fecha, prevalece la del aula.

📅 Importa todas las fechas en tu calendario: [`calendario/curso-mvdc-2026.ics`](calendario/curso-mvdc-2026.ics)

## Evaluación continua

Se ofertan **15 puntos**; cuentan hasta un **máximo de 10**.

| Actividad | Puntos | Entrega |
|---|---:|---|
| [Actividad 1 · Estrategia sintética con opciones (*long straddle*)](actividades/actividad-1-straddle/) | 5.0 | 23/11/2026 23:59 |
| [Actividad 2 · Cartera financiera de mínimo riesgo](actividades/actividad-2-cartera-minimo-riesgo/) | 6.0 | 14/12/2026 23:59 |
| [30 microtests (3 por tema)](microtests/) | 4.0 | 10/01/2027 23:59 |

Requisitos comunes de entrega, rúbricas y plantillas: [`actividades/`](actividades/).

---

## Empezar

> 🧭 **¿Poca experiencia programando?** Empieza por la [Guía para principiantes](docs/guia-principiantes.md) y el cuaderno de autoestudio [**Semana 0 · Python esencial**](sesiones/semana-00/) (60–90 min, con ejercicios autocorregibles). Ten a mano la [guía rápida de Python](docs/guia-rapida-python.md).

> 🔁 **¿Vienes de R?** En [`r/`](r/README.md) hay versiones en R de los cuadernos de las sesiones 1 y 2 y una tabla de equivalencias Python ↔ R. Las actividades se entregan en Python.

**Opción A — Google Colab (sin instalar nada).** Abre cualquier cuaderno de `sesiones/` y pulsa el botón 
*Open in Colab*; la primera celda instala la biblioteca del curso automáticamente.

**Opción B — En tu ordenador.**

```bash
git clone https://github.com/prof-rodolfo-medina/modelizacion-derivados-carteras.git
cd modelizacion-derivados-carteras
python -m venv .venv && source .venv/bin/activate      # Windows: .venv\Scripts\activate
pip install -e ".[dev]"
jupyter lab
```

¿Conda? `conda env create -f environment.yml && conda activate mvdc`.

**Opción C — Visual Studio Code con GitHub.** Requiere [VS Code](https://code.visualstudio.com/), 
[Git](https://git-scm.com/downloads) y Python ≥ 3.10.

1. En VS Code: `Ctrl+Shift+P` (macOS: `Cmd+Shift+P`) → **Git: Clone** → **Clone from GitHub**, inicia sesión 
   con tu cuenta de GitHub y elige `prof-rodolfo-medina/modelizacion-derivados-carteras`.
2. Al abrir la carpeta, acepta **instalar las extensiones recomendadas** (Python, Jupyter y GitHub Pull Requests).
3. `Ctrl+Shift+P` → **Python: Create Environment** → **Venv** → marca `requirements.txt` para instalar las dependencias.
4. Abre un cuaderno de `sesiones/`, pulsa **Select Kernel** (arriba a la derecha) y elige `.venv`.
5. Cada semana, en el panel **Source Control**, pulsa **Sync Changes** (equivale a `git pull`) para recibir el material nuevo.

[![Abrir en GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/prof-rodolfo-medina/modelizacion-derivados-carteras) 
¿Sin instalar nada pero con VS Code? **Codespaces** abre este repositorio en VS Code dentro del navegador, 
con todo instalado.

Paso a paso y solución de problemas: [`docs/guia-entorno.md`](docs/guia-entorno.md). 
Para recibir el material nuevo de cada semana: `git pull` (o *Sync Changes* en VS Code).

## Estructura

```
├── sesiones/            Una carpeta por semana (0 = autoestudio): guion + cuaderno
├── actividades/         Actividad 1 y 2: requisitos, rúbrica, checklist y plantilla
├── microtests/          Relación de los 30 microtests y su temario
├── src/mvdc/            Biblioteca del curso (un módulo por bloque del temario)
├── tests/               Pruebas que reproducen los ejemplos numéricos de los apuntes
├── datos/               CSV del curso (ejemplo del Tema 6 y datos simulados)
├── plantillas/          Formato básico para documentos evaluables
├── herramientas/        Verificador de entregas, descarga de datos del IBEX-35, generador de datos
├── calendario/          Fechas del curso en formato .ics
├── docs/                Guía del entorno, guía para principiantes, guía rápida de Python y erratas
└── r/                   Ejemplos en R equivalentes a la biblioteca y a los cuadernos (apoyo)
```

## La biblioteca `mvdc`

| Módulo | Temas | Funciones principales |
|---|---|---|
| `mvdc.payoffs` | 1–2 | `long_call`, `long_put`, `short_*`, `long_future`, `strategy`, `breakeven_points`, `plot_strategy` |
| `mvdc.binomial` | 3–4 | `one_period_price` (Métodos I y II), `delta_hedge_pnl`, `option_tree`, `binomial_price`, `hull_white_ud` |
| `mvdc.lognormal` | 5–6 | `wiener_paths`, `gbm_paths`, `euler_maruyama`, `estimate_mme/mmv/mmnp`, `fit_and_validate`, `confidence_band` |
| `mvdc.black_scholes` | 7 | `bs_call`, `bs_put`, `put_call_parity_gap`, `binomial_to_bs`, `mc_price` |
| `mvdc.portfolio` | 8–10 | `lagrange_quadratic`, `min_variance_weights`, `target_return_weights`, `efficient_frontier`, `tangency_weights`, `beta`, `security_market_line`, `plot_frontier` |

```python
from mvdc import black_scholes as bs
bs.bs_call(S0=74.625, K=100, T=1.6, r=0.05, sigma=0.375)   # 8.3164 (Ejemplo 1, Tema 7)
```

Cada resultado numérico de los apuntes está verificado en [`tests/test_temario.py`](tests/test_temario.py) 
(`pytest -q`). Las discrepancias encontradas están en [`docs/erratas-temario.md`](docs/erratas-temario.md).

## Bibliografía de referencia

- Hull, J. (2009). *Introducción a los mercados de futuros y opciones*. Pearson Educación.
- Wilmott, P., Howison, S. y Dewynne, J. (1995). *The Mathematics of Financial Derivatives: A Student Introduction*. Cambridge University Press.
- Allen, E. (2007). *Modeling with Itô Stochastic Differential Equations*. Springer.

### En la Biblioteca Virtual de UNIR

Los títulos anteriores no están en la Biblioteca Virtual. Estos sí, y cubren el temario:

> ⭐ **Referencia principal:** Casanovas Ramón, M. (2015). *Opciones financieras* (7.ª ed.). Ediciones Pirámide. [Leer en eLibro](https://elibro.net/es/ereader/unir/49093)

**Opciones y derivados (temas 1–4 y 7)**

- Lamothe Fernández, P. (2006). *Opciones financieras: productos estructurados* (3.ª ed.). McGraw-Hill España. [Leer en eLibro](https://elibro.net/es/ereader/unir/50298)
- Bertrán Jordana, J. y Gracia Ramos, M. C. (2019). *Instrumentos financieros derivados y gestión del riesgo*. Delta Publicaciones. [Leer en eLibro](https://elibro.net/es/ereader/unir/227434)
- Rona Szekely, J. Z. (2025). *Guía práctica de los instrumentos financieros derivados* (3.ª ed.). Fondo Editorial de la Pontificia Universidad Católica del Perú. [Leer en eLibro](https://elibro.net/es/ereader/unir/289629)
- Rodríguez Aranday, F. (2020). *Finanzas internacionales y productos derivados*. Instituto Mexicano de Contadores Públicos. [Leer en eLibro](https://elibro.net/es/ereader/unir/174898)
- Iacus, S. M. (2011). *Option Pricing and Estimation of Financial Models with R*. Wiley. [Leer en eLibro](https://elibro.net/es/ereader/unir/182859)

**Procesos estocásticos y modelo log-normal (temas 5 y 6)**

- Braumann, C. A. (2019). *Introduction to Stochastic Differential Equations with Applications to Modelling in Biology and Finance*. Wiley. [Leer en eLibro](https://elibro.net/es/ereader/unir/189244)
- Ólafsson, S., Nel, D. y Chin, E. (2014). *Problems and Solutions in Mathematical Finance: Stochastic Calculus*. Wiley. [Leer en eLibro](https://elibro.net/es/ereader/unir/181542)
- Núñez Velázquez, J. J. (2011). *Análisis dinámico mediante procesos estocásticos para actuarios y finanzas*. Editorial Universidad de Alcalá. [Leer en eLibro](https://elibro.net/es/ereader/unir/53550)
- Jimeno Moreno, J. P. (2012). *Los mercados financieros y sus matemáticas*. Delta Publicaciones. [Leer en eLibro](https://elibro.net/es/ereader/unir/42490)

**Carteras, Markowitz y CAPM (temas 8–10)**

- García Boza, J. (2015). *Inversiones financieras: selección de carteras, teoría y práctica*. Ediciones Pirámide. [Leer en eLibro](https://elibro.net/es/ereader/unir/49025)
- Berstein Kiguel, E. (2022). *Introducción al análisis de carteras de inversión*. RIL editores. [Leer en eLibro](https://elibro.net/es/ereader/unir/266718)
- Kim, D. y Francis, J. C. (2013). *Modern Portfolio Theory: Foundations, Analysis, and New Developments*. Wiley. [Leer en eLibro](https://elibro.net/es/ereader/unir/177925)
- Fabozzi, F. J. y Markowitz, H. M. (2011). *The Theory and Practice of Investment Management* (2.ª ed.). Wiley. [Leer en eLibro](https://elibro.net/es/ereader/unir/181540)

**Finanzas generales y programación**

- Chu Rubio, M. (2019). *Finanzas aplicadas: teoría y práctica* (4.ª ed.). Ediciones de la U. 414 p. [Leer en eLibro](https://elibro.net/es/ereader/unir/127073)
- Ramírez Gil, C. M. (2021). *Python para finanzas: curso práctico*. RA-MA Editorial. [Leer en eLibro](https://elibro.net/es/ereader/unir/222660)

> Los enlaces se abren con tu usuario de UNIR. Por derechos de autor, este repositorio no aloja los textos de la bibliografía.

## Licencia

Código bajo licencia [MIT](LICENSE). Textos y cuadernos bajo [CC BY-NC-SA 4.0](LICENSE-CONTENIDO.md). 
Los apuntes oficiales de UNIR **no** se incluyen en este repositorio.
