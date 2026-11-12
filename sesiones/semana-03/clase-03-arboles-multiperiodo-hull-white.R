# =============================================================================
#  Clase 3 · Árboles multiperiodo y calibración de Hull-White  —  VERSIÓN EN R
#
#  Semana 3 (16–20/11/2026) · Tema 4
#  Equivalente al cuaderno  clase-03-arboles-multiperiodo-hull-white.ipynb
#
#  Este script es de APOYO para quien ya programa en R: sigue las mismas
#  secciones que el cuaderno de Python para que puedas compararlos.
#  Las actividades evaluables (incluida la Actividad 1) se entregan en Python.
#
#  Cómo usarlo: ábrelo en RStudio y ejecútalo sección a sección (Ctrl+Enter),
#  o completo con  source("clase-03-arboles-multiperiodo-hull-white.R").
#  Guía de equivalencias Python ↔ R:  r/README.md
#
#  Objetivos:
#   1. Construir el árbol recombinante del subyacente y valorar por inducción
#      hacia atrás.
#   2. Contrastar con la fórmula cerrada binomial.
#   3. Explorar la sensibilidad de la prima (Tabla 1 del tema).
#   4. Calibrar u y d a partir de datos con el algoritmo de Hull-White.
# =============================================================================


# ---- 0. Configuración --------------------------------------------------------
f <- Find(file.exists, file.path(c(".", "..", "../.."), "r", "mvdc", "cargar.R"))
source(if (is.null(f)) paste0("https://raw.githubusercontent.com/prof-rodolfo-medina/",
                              "modelizacion-derivados-carteras/main/r/mvdc/cargar.R")
       else f)
cargar_mvdc()


# ---- 1. Árbol del subyacente (Figura 4 del tema) -----------------------------
# S0 = 100, u = 1.1, d = 0.9, 3 periodos.
# El árbol es una matriz triangular: fila = número de bajadas j, columna = periodo t.
# Python: S[j, t] (desde 0)   ·   R: S[j + 1, t + 1] (desde 1)

S <- stock_tree(100, 1.1, 0.9, 3)
print_tree(S)
S[2, 3]                                # j = 1 bajada, t = 2  →  u·d·S0 = 99   (Python: S[1, 2])


# ---- 2. Árbol de la call por inducción hacia atrás (Figura 7) ----------------
# K = 105, r = 0.05.
# En cada nodo:  V[t, j] = e^{-r}·( q*·V[t+1, j] + (1 - q*)·V[t+1, j+1] )

res <- option_tree(100, 105, 1.1, 0.9, 0.05, 3, kind = "call")
V <- res$V; q <- res$q                 # Python: V, q = b.option_tree(...)
cat(sprintf("q* = %.4f\n", q))
print_tree(V)
cat(sprintf("\nPrima por inducción: %.4f   |   fórmula cerrada: %.4f\n",
            V[1, 1], binomial_price(100, 105, 1.1, 0.9, 0.05, 3)))

# Errata de los apuntes: en el último paso aparece 0.2436·2.05; el nodo vale 2.02.
round(V[2, 2], 4)                      # Python: V[1, 1]


# ---- 3. Fórmula cerrada ------------------------------------------------------
#
#   V0 = e^{-rn} Σ_{j=0}^{n} C(n,j) (q*)^{n-j} (1-q*)^j (u^{n-j} d^j S0 - K)^+
#
# (q* va con las SUBIDAS; en los apuntes los exponentes aparecen intercambiados.)
# Put con K = 100 (el tema obtiene 1.601):

round(binomial_price(100, 100, 1.1, 0.9, 0.05, 3, kind = "put"), 4)


# ---- 4. Análisis de sensibilidad (Tabla 1 del Tema 4) ------------------------
base <- list(S0 = 100, K = 105, u = 1.1, d = 0.9, r = 0.05, n = 3)
prima <- function(kind = "call", ...) {
  p <- modifyList(base, list(...))     # Python: p = {**base, **cambios}
  binomial_price(p$S0, p$K, p$u, p$d, p$r, p$n, kind = kind)
}
# Ejemplo:  prima("put", r = 0.08)  cambia solo r respecto del caso base.

op <- par(mfrow = c(1, 3), mar = c(4.2, 4.2, 2.5, 1))   # Python: plt.subplots(1, 3)

xs <- seq(80, 130, length.out = 51)
plot(xs, sapply(xs, function(x) prima(S0 = x)), type = "l", lwd = 2, col = "steelblue",
     main = "Precio del subyacente S0", xlab = expression(S[0]), ylab = "prima",
     ylim = c(0, 40))
lines(xs, sapply(xs, function(x) prima("put", S0 = x)), lwd = 2, col = "darkorange")
legend("topleft", legend = c("call", "put"), col = c("steelblue", "darkorange"), lwd = 2, bty = "n")
grid()

plot(xs, sapply(xs, function(x) prima(K = x)), type = "l", lwd = 2, col = "steelblue",
     main = "Precio de ejercicio K", xlab = "K", ylab = "prima", ylim = c(0, 35))
lines(xs, sapply(xs, function(x) prima("put", K = x)), lwd = 2, col = "darkorange")
grid()

vol <- seq(0.06, 0.3, length.out = 40)  # u = 1+v, d = 1-v; v > e^{0.05}-1 para que q* esté en (0,1)
plot(vol, sapply(vol, function(v) prima(u = 1 + v, d = 1 - v)), type = "l", lwd = 2,
     col = "steelblue", main = "«Volatilidad» (u = 1+v, d = 1-v)", xlab = "v", ylab = "prima",
     ylim = c(0, 26))
lines(vol, sapply(vol, function(v) prima("put", u = 1 + v, d = 1 - v)), lwd = 2, col = "darkorange")
grid()

par(op)


# ---- 5. Calibración de Hull-White (p = 1/2) ----------------------------------
#
#   U_i = S_i/S_{i-1} - 1,     u = 1 + Ū + s_U,     d = 1 + Ū - s_U
#
# Usamos las 28 cotizaciones del Tema 6 (incluidas en datos/).

serie <- cargar("tema6_ibex_28dias.csv")$S      # Python: mvdc.datos.cargar(...)["S"]
hw <- hull_white_ud(serie)
print(round(unlist(hw), 5))

# Valoramos una call at-the-money a 5 días con los factores calibrados
# (r diario ≈ 3 % anual / 252)
S0 <- serie[length(serie)]                      # Python: serie.iloc[-1]
cat("Prima call ATM a 5 días:",
    round(binomial_price(S0, S0, hw$u, hw$d, 0.03 / 252, 5), 4), "\n")


# ---- 6. Ejercicio en clase ---------------------------------------------------
# 1. ¿Qué ocurre con q* si e^{r·Δt} > u? Pruébalo con risk_neutral_q.
# 2. Avance del Tema 7: con u = e^{σ√Δt} y d = 1/u, grafica la prima binomial
#    para n = 1, ..., 200. ¿Hacia qué valor converge? (lo veremos en la Clase 5).

# Tu código aquí
# Pistas:
# - risk_neutral_q() lanza un error; para verlo sin detener el script:
#     tryCatch(risk_neutral_q(...), error = function(e) conditionMessage(e))
# - Para un vencimiento T fijo, Δt = T/n y el tipo por periodo entra con dt = Δt
#   en binomial_price(S0, K, u, d, r, n, dt = ...).
# - sapply(1:200, function(n) ...) devuelve el vector de primas; plot(..., type = "l").


# > Recordatorio: la Actividad 1 se entrega el lunes 23/11/2026 a las 23:59.
