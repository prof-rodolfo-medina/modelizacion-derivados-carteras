# Modelización y Valoración de Derivados y Carteras en Finanzas

**Maestría en Ciencias Computacionales y Matemáticas Aplicadas · UNIR** · Edición noviembre–diciembre 2026  
Docente: **Rodolfo Rafael Medina** · [github.com/prof-rodolfo-medina](https://github.com/prof-rodolfo-medina)

[![Pruebas](https://github.com/prof-rodolfo-medina/modelizacion-derivados-carteras/actions/workflows/ci.yml/badge.svg)](https://github.com/prof-rodolfo-medina/modelizacion-derivados-carteras/actions/workflows/ci.yml)

Repositorio de apoyo para las **sesiones síncronas**: cuadernos Jupyter de cada clase, una pequeña biblioteca de 
Python (`mvdc`) que implementa los métodos del temario, datos, plantillas de las actividades y herramientas para 
revisar las entregas.

> El aula virtual de UNIR sigue siendo el canal oficial: allí están los enunciados oficiales, se entregan 
> las actividades y se responden los microtests.

---

## Calendario

| Sem. | Fechas | Temas | Sesión síncrona | Evaluación |
|---:|---|---|---|---|
| 1 | 02/11 – 06/11 | 1. Introducción a las opciones · 2. Estrategias sintéticas | [Clase 1](sesiones/semana-01/) y presentación (90′) | Microtests 1.x, 2.x |
| 2 | 09/11 – 13/11 | 3. Árboles binomiales I | [Clase 2](sesiones/semana-02/) y **presentación Actividad 1** (60′) | Microtests 3.x |
| 3 | 16/11 – 20/11 | 4. Árboles binomiales II · Hull-White | [Clase 3](sesiones/semana-03/) (60′) | Microtests 4.x |
| 4 | 23/11 – 27/11 | 5. Modelo log-normal | [Clase 4](sesiones/semana-04/) y **resolución Actividad 1** (90′) | 🔴 **Actividad 1: lun 23/11 23:59** · Microtests 5.x |
| 5 | 30/11 – 04/12 | 6. Estimación y predicción · 7. Black-Scholes | [Clase 5](sesiones/semana-05/) y **presentación Actividad 2** (60′) | Microtests 6.x, 7.x |
| 6 | 07/12 – 11/12 | 8. Fundamentos de carteras · 9. Markowitz | [Clase 6](sesiones/semana-06/) (60′) | Microtests 8.x, 9.x |
| 7 | 14/12 – 18/12 | 10. Cartera mixta y CAPM | [Clase 7](sesiones/semana-07/) y **resolución Actividad 2** (90′) | 🔴 **Actividad 2: lun 14/12 23:59** · Microtests 10.x |
| — | 21/12 – 03/01 | *Receso institucional (Navidad y Año Nuevo)* | — | — |
| 8 | 04/01 – 08/01/2027 | Repaso | [Clase 8](sesiones/semana-08/) · Repaso (90′) | **Examen** |
| — | **10/01/2027** | | | 🔴 **Fecha límite de los 30 microtests** |

> La semana 8 figuraba en el calendario original del 21 al 25/12; se traslada a la primera semana de enero por el receso institucional. Si el aula virtual publica otra fecha, prevalece la del aula.

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
├── sesiones/            Una carpeta por semana: guion (README) + cuaderno de la clase
├── actividades/         Actividad 1 y 2: requisitos, rúbrica, checklist y plantilla
├── microtests/          Relación de los 30 microtests y su temario
├── src/mvdc/            Biblioteca del curso (un módulo por bloque del temario)
├── tests/               Pruebas que reproducen los ejemplos numéricos de los apuntes
├── datos/               CSV del curso (ejemplo del Tema 6 y datos simulados)
├── plantillas/          Formato básico para documentos evaluables
├── herramientas/        Verificador de entregas, descarga de datos del IBEX-35, generador de datos
├── calendario/          Fechas del curso en formato .ics
└── docs/                Guía del entorno y erratas detectadas en el temario
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

## Licencia

Código bajo licencia [MIT](LICENSE). Textos y cuadernos bajo [CC BY-NC-SA 4.0](LICENSE-CONTENIDO.md). 
Los apuntes oficiales de UNIR **no** se incluyen en este repositorio.
