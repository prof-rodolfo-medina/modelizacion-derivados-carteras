# Ejemplos en R

Material de apoyo para quien ya programa en **R** y quiere pasar a Python, o al revés.

> ⚠️ **Las actividades evaluables se entregan en Python.** Los scripts de R sirven para entender
> los métodos con un lenguaje que ya dominas y para comparar, línea a línea, cómo se escribe lo
> mismo en Python. No sustituyen a los cuadernos `.ipynb` de cada sesión.

## Qué hay

| Archivo | Equivale en Python a | Contenido |
|---|---|---|
| [`mvdc/payoffs.R`](mvdc/payoffs.R) | `src/mvdc/payoffs.py` | Temas 1 y 2: pay-off, B/P, ITM/ATM/OTM, estrategias, puntos de equilibrio, gráficas |
| [`mvdc/binomial.R`](mvdc/binomial.R) | `src/mvdc/binomial.py` | Tema 3: árbol monoperiodo (Métodos I y II) y cobertura delta. Tema 4: árbol multiperiodo, inducción hacia atrás, fórmula cerrada y calibración de Hull-White |
| [`mvdc/datos.R`](mvdc/datos.R) | `src/mvdc/datos.py` | `cargar(nombre)`: lee un CSV de `datos/` (o de GitHub si no lo encuentra) |
| [`mvdc/cargar.R`](mvdc/cargar.R) | `import mvdc` | Carga las funciones desde el repositorio o, si no lo encuentra, desde GitHub |
| [`pruebas.R`](pruebas.R) | `tests/` | Comprueba que R y Python dan los mismos resultados |

Scripts de las sesiones (junto al cuaderno de Python de cada semana):

| Sesión | Script de R | Cuaderno de Python |
|---|---|---|
| Clase 1 · Temas 1 y 2 | [`clase-01-opciones-y-estrategias-sinteticas.R`](../sesiones/semana-01/clase-01-opciones-y-estrategias-sinteticas.R) | [`.ipynb`](../sesiones/semana-01/clase-01-opciones-y-estrategias-sinteticas.ipynb) |
| Clase 2 · Tema 3 | [`clase-02-arboles-binomiales-monoperiodo.R`](../sesiones/semana-02/clase-02-arboles-binomiales-monoperiodo.R) | [`.ipynb`](../sesiones/semana-02/clase-02-arboles-binomiales-monoperiodo.ipynb) |
| Clase 3 · Tema 4 | [`clase-03-arboles-multiperiodo-hull-white.R`](../sesiones/semana-03/clase-03-arboles-multiperiodo-hull-white.R) | [`.ipynb`](../sesiones/semana-03/clase-03-arboles-multiperiodo-hull-white.ipynb) |

Las funciones de R tienen **el mismo nombre y los mismos argumentos** que en Python
(`long_call(ST, K, C)`, `strategy(ST, legs)`, `one_period_price(S0, Su, Sd, K, r, tau, kind)`…),
y los scripts siguen **las mismas secciones** que los cuadernos.

## Cómo ejecutarlos

Solo hace falta **R ≥ 4.2**; no se usa ningún paquete adicional (gráficos base de R).

- **RStudio (recomendado):** abre el repositorio como proyecto (*File → Open Project…* o
  simplemente abre la carpeta), abre el script de la sesión y ejecútalo sección a sección con
  `Ctrl+Enter`. El panel *Outline* muestra las secciones (`# ---- 1. … ----`).
- **Terminal**, desde la raíz del repositorio:
  ```bash
  Rscript sesiones/semana-01/clase-01-opciones-y-estrategias-sinteticas.R
  Rscript r/pruebas.R          # debe terminar con "comprobaciones correctas"
  ```
- **Sin instalar nada** (Google Colab con *Entorno de ejecución → Cambiar tipo → R*, o Posit Cloud):
  pega en una celda la sección 0 del script; al no encontrar el repositorio, `cargar_mvdc()`
  descarga las funciones de GitHub. Después pega el resto de secciones.

## Equivalencias Python ↔ R

| Idea | Python (lo que verás en los cuadernos) | R |
|---|---|---|
| Cargar la biblioteca | `from mvdc import payoffs as po` | `cargar_mvdc()` |
| Llamar a una función | `po.long_call(ST, K, C)` | `long_call(ST, K, C)` |
| Malla de valores | `np.linspace(50, 150, 501)` | `seq(50, 150, length.out = 501)` |
| Máximo elemento a elemento | `np.maximum(ST - K, 0)` | `pmax(ST - K, 0)` |
| Vector | `np.array([90, 95, 100])` | `c(90, 95, 100)` |
| Índices | empiezan en **0**: `x[0]` | empiezan en **1**: `x[1]` |
| Último elemento | `x[-1]` | `x[length(x)]` (en R, `x[-1]` *quita* el primero) |
| Recorrer índices | `for i in range(n):` | `for (i in seq_len(n)) { }` |
| Bloques | sangría | llaves `{ }` |
| Matriz (árbol) | `tree[j, t]`, sin nodo = `np.nan` | `tree[j + 1, t + 1]`, sin nodo = `NA` |
| Recorrer hacia atrás | `for t in range(n - 1, -1, -1):` | `for (t in rev(seq_len(n)) - 1) { }` |
| Quitar el último / el primero | `S[:-1]`, `S[1:]` | `S[-length(S)]`, `S[-1]` |
| Desviación típica muestral | `U.std(ddof=1)` | `sd(U)` (ya divide entre n − 1) |
| Coeficiente binomial | `math.comb(n, j)` | `choose(n, j)` |
| Leer un CSV | `pd.read_csv(ruta, index_col=0)` | `read.csv(ruta, row.names = 1)` |
| Una columna | `df["S"]` | `df$S` |
| Devolver varios valores | `return V, q` → `V, q = f()` | `list(V = V, q = q)` → `res$V`, `res$q` |
| Cambiar solo algunos argumentos | `{**base, **cambios}` | `modifyList(base, list(...))` |
| Capturar un error | `try: … except ValueError as e:` | `tryCatch(…, error = function(e) conditionMessage(e))` |
| Diccionario | `{"tipo": "call", "K": 100}` | `list(tipo = "call", K = 100)` |
| Acceder a un campo | `d["K"]`, `d.get("prima", 0)` | `d$K`, `if (is.null(d$prima)) 0 else d$prima` |
| Lista de patas | `[pata1, pata2]` | `list(pata1, pata2)` |
| Tabla | `pd.DataFrame({"K": [...]})` | `data.frame(K = c(...))` |
| Nueva columna | `tabla["VE"] = tabla.prima - tabla.VI` | `tabla$VE <- tabla$prima - tabla$VI` |
| Aplicar a cada elemento | `[f(k) for k in tabla.K]` | `sapply(tabla$K, f)` (o directamente `f(tabla$K)` si es vectorial) |
| Comparar con tolerancia | `np.allclose(a, b)` | `isTRUE(all.equal(a, b))` |
| Texto con formato | `f"{x:.4f}"` | `sprintf("%.4f", x)` |
| Exponencial | `from math import exp`; `exp(r)` | `exp(r)` |
| Varias gráficas | `fig, axs = plt.subplots(2, 2)` | `par(mfrow = c(2, 2))` |
| Lógicos | `True`, `False`, `and`, `or`, `not` | `TRUE`, `FALSE`, `&&`, `\|\|`, `!` |
| Asignación | `x = 3` | `x <- 3` |

Para el resto de Python que usa el curso, consulta la
[guía rápida de Python](../docs/guia-rapida-python.md).

## Consejo para migrar

1. Ejecuta el script de R de la sesión y fíjate en los resultados.
2. Abre el cuaderno de Python de la misma sesión: las secciones tienen el mismo número.
3. Traduce una sección cada vez con la tabla de equivalencias y comprueba que obtienes
   **los mismos números** que en R.
