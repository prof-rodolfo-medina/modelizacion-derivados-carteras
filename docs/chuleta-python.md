# Chuleta de Python para el curso

Referencia rápida de lo que se usa en el curso. Se supone que ya ejecutaste:

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import norm
```

## Cálculo básico

| Quiero… | Código |
|---|---|
| $e^{x}$, $\ln x$, $\sqrt{x}$ | `np.exp(x)`, `np.log(x)`, `np.sqrt(x)` |
| Potencia $x^n$ | `x ** n` |
| Capitalizar / actualizar con interés continuo | `S0 * np.exp(r * T)` / `V * np.exp(-r * T)` |
| Número combinatorio $\binom{n}{j}$ | `from math import comb` → `comb(n, j)` |
| Mostrar un número con 4 decimales | `print(f"{x:.4f}")` |

## Vectores (NumPy)

| Quiero… | Código |
|---|---|
| Vector a partir de valores | `np.array([80, 100, 120])` |
| $n$ puntos equiespaciados entre $a$ y $b$ | `np.linspace(a, b, n)` |
| Parte positiva $(x)^+$ elemento a elemento | `np.maximum(x, 0)` |
| Suma, media, desviación típica (muestral) | `x.sum()`, `x.mean()`, `x.std(ddof=1)` |
| Vector de unos de tamaño $n$ | `np.ones(n)` |
| Elementos que cumplen una condición | `x[x > 100]` |
| Índices donde cambia de signo (puntos de equilibrio aproximados) | `np.where(np.diff(np.sign(y)) != 0)[0]` |

## Funciones

```python
def nombre_funcion(argumento1, argumento2=valor_por_defecto):
    """Qué calcula, con la notación de los apuntes."""
    resultado = ...            # sangría de 4 espacios
    return resultado
```

## Gráficas (Matplotlib)

| Quiero… | Código |
|---|---|
| Curva | `plt.plot(x, y, label="texto")` |
| Línea horizontal en el cero | `plt.axhline(0, color="black", linewidth=0.8)` |
| Línea vertical en $K$ | `plt.axvline(K, linestyle="--")` |
| Marcar un punto | `plt.plot(x0, y0, "o")` |
| Texto con flecha | `plt.annotate("texto", (x0, y0), xytext=(x1, y1), arrowprops=dict(arrowstyle="->"))` |
| Ejes, título, leyenda, rejilla | `plt.xlabel(...)`, `plt.ylabel(...)`, `plt.title(...)`, `plt.legend()`, `plt.grid(alpha=0.3)` |
| Varias gráficas en una figura | `fig, axs = plt.subplots(1, 2, figsize=(12, 4))` → `axs[0].plot(...)` |
| Guardar para el informe | `plt.savefig("figura1.png", dpi=200, bbox_inches="tight")` |

## Datos (pandas)

| Quiero… | Código |
|---|---|
| Leer un CSV con fechas en la primera columna | `df = pd.read_csv("archivo.csv", index_col=0, parse_dates=True)` |
| Ver las primeras filas, columnas, tamaño | `df.head()`, `df.columns`, `df.shape` |
| Elegir columnas | `df["SAN"]`, `df[["SAN", "ITX", "IBE"]]` |
| Log-rendimientos $\ln(S_t/S_{t-1})$ | `np.log(df / df.shift(1)).dropna()` |
| Rendimientos simples $S_t/S_{t-1}-1$ | `(df / df.shift(1) - 1).dropna()` |
| Media y desviación por columna | `R.mean()`, `R.std()` |
| Matriz de covarianzas / correlaciones | `R.cov()`, `R.corr()` |
| Anualizar desde datos diarios (≈ 252 sesiones) | `R.mean() * 252`, `R.cov() * 252` |
| Pasar a NumPy | `R.to_numpy()` |

## Matrices (álgebra lineal)

| Quiero… | Código |
|---|---|
| Producto matricial $AB$, $x^\top A x$ | `A @ B`, `x @ A @ x` |
| Traspuesta | `A.T` |
| Inversa | `np.linalg.inv(A)` |
| Resolver $Ax = b$ (más estable que invertir) | `np.linalg.solve(A, b)` |
| Covarianzas de un array (filas = días, columnas = activos) | `np.cov(R, rowvar=False)` |
| Determinante | `np.linalg.det(A)` |

## Probabilidad y simulación

| Quiero… | Código |
|---|---|
| Generador reproducible | `rng = np.random.default_rng(semilla)` |
| $n$ valores de $N(0,1)$ | `rng.standard_normal(n)` |
| Función de distribución normal $N(x)$ | `norm.cdf(x)` |
| Suma acumulada (trayectorias) | `np.cumsum(x)` |

## Antes de entregar

- [ ] **Reiniciar y ejecutar todo** sin errores.
- [ ] Todas las gráficas con título, ejes con unidades y leyenda.
- [ ] Comentarios que explican el porqué de cada paso.
- [ ] Sin dependencias de la biblioteca `mvdc` en el código entregado.
- [ ] Datos importados adjuntos.
