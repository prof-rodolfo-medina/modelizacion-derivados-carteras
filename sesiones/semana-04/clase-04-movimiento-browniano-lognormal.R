# =============================================================================
#  Clase 4 · Movimiento browniano y modelo log-normal  —  VERSIÓN EN R
#
#  Semana 4 (23–27/11/2026) · Tema 5
#  Equivalente al cuaderno  clase-04-movimiento-browniano-lognormal.ipynb
#
#  Este script es de APOYO para quien ya programa en R: sigue las mismas
#  secciones que el cuaderno de Python para que puedas compararlos.
#  Las actividades evaluables se entregan en Python.
#
#  Cómo usarlo: ábrelo en RStudio y ejecútalo sección a sección (Ctrl+Enter),
#  o completo con  source("clase-04-movimiento-browniano-lognormal.R").
#  Guía de equivalencias Python ↔ R:  r/README.md
#
#  Nota: R y NumPy usan generadores aleatorios distintos. Con la misma semilla
#  no salen las mismas trayectorias, así que los números simulados difieren un
#  poco de los del cuaderno; los valores teóricos son idénticos.
#
#  Objetivos:
#   1. Simular el proceso de Wiener y comprobar sus propiedades.
#   2. Obtener el movimiento browniano geométrico como solución de la EDE
#      log-normal.
#   3. Verificar por simulación la media y la varianza teóricas.
#   4. Comparar la solución exacta con el esquema de Euler-Maruyama.
# =============================================================================


# ---- 0. Configuración --------------------------------------------------------
f <- Find(file.exists, file.path(c(".", "..", "../.."), "r", "mvdc", "cargar.R"))
source(if (is.null(f)) paste0("https://raw.githubusercontent.com/prof-rodolfo-medina/",
                              "modelizacion-derivados-carteras/main/r/mvdc/cargar.R")
       else f)
cargar_mvdc()


# ---- 1. Proceso de Wiener: 100 trayectorias (Figura 2 del tema) --------------
w <- wiener_paths(T = 1, n_steps = 500, n_paths = 100, seed = 7)
t <- w$t; W <- w$W                      # Python: t, W = ln.wiener_paths(...)

# matplot dibuja una curva por COLUMNA: por eso se traspone W (Python: W.T)
matplot(t, t(W), type = "l", lty = 1, lwd = 0.6, col = adjustcolor(rainbow(10), 0.6),
        main = "100 simulaciones del proceso de Wiener y banda ±1.96·sqrt(t)",
        xlab = "t", ylab = "W(t)")
lines(t,  1.96 * sqrt(t), lty = 2, lwd = 1.5)
lines(t, -1.96 * sqrt(t), lty = 2, lwd = 1.5)
grid()


# ---- 2. Comprobación empírica de las propiedades -----------------------------
#   W(t) ~ N(0, t)      Cov(W(t1), W(t2)) = min{t1, t2}

w <- wiener_paths(T = 1, n_steps = 100, n_paths = 50000, seed = 1)
W <- w$W
i1 <- 30; i2 <- 80                      # t1 = 0.3, t2 = 0.8
# Python: W[:, i2] (columnas desde 0)  ·  R: W[, i2 + 1] (columnas desde 1)
# Python .var() divide entre n; var() de R entre n - 1 (con 50 000 datos no se nota)
cat(sprintf("Var W(0.8): %.4f  (teórico 0.8)\n", var(W[, i2 + 1])))
cat(sprintf("Cov(W(0.3), W(0.8)): %.4f  (teórico 0.3)\n", cov(W[, i1 + 1], W[, i2 + 1])))


# ---- 3. Modelo log-normal ----------------------------------------------------
#
#   dS = μ S dt + σ S dW   ⇒   S(t) = S0 e^{(μ - σ²/2) t + σ W(t)}
#
#   E[S(t)] = S0 e^{μ t},      V[S(t)] = S0² e^{2 μ t} (e^{σ² t} - 1)

S0 <- 25; mu <- 0.10; sigma <- 0.30; T <- 1.0
g <- gbm_paths(S0, mu, sigma, T, n_steps = 252, n_paths = 20000, seed = 3)
t <- g$t; S <- g$S

op <- par(mfrow = c(1, 2), mar = c(4.2, 4.2, 2.5, 1))   # Python: plt.subplots(1, 2)

matplot(t, t(S[1:60, ]), type = "l", lty = 1, lwd = 0.6,
        col = adjustcolor(rainbow(10), 0.7), main = "Trayectorias del MBG",
        xlab = "t", ylab = "S(t)")
b <- confidence_band(S0, mu, sigma, t)  # Python: m, lo, hi = ln.confidence_band(...)
lines(t, b$m, lwd = 2)
lines(t, b$lo, lty = 2); lines(t, b$hi, lty = 2)
legend("topleft", legend = "E[S(t)]", lwd = 2, bty = "n")

ST <- S[, ncol(S)]                      # Python: S[:, -1]
hist(ST, breaks = 80, freq = FALSE, col = adjustcolor("steelblue", 0.5), border = "white",
     main = "Distribución de S(T)", xlab = "S(T)", ylab = "densidad")
x <- seq(min(ST), max(ST), length.out = 300)
# Python: lognorm.pdf(x, s=σ√T, scale=S0·e^{(μ-σ²/2)T})  ·  R: dlnorm(x, meanlog, sdlog)
lines(x, dlnorm(x, meanlog = log(S0) + (mu - sigma^2 / 2) * T, sdlog = sigma * sqrt(T)),
      col = "red", lwd = 2)
legend("topright", legend = c("simulación S(T)", "densidad log-normal"),
       fill = c(adjustcolor("steelblue", 0.5), NA), border = NA,
       col = c(NA, "red"), lwd = c(NA, 2), bty = "n")
par(op)

# Python .std() divide entre n; sd() de R entre n - 1. Para replicarlo:
desv <- function(x) sqrt(mean((x - mean(x))^2))
cat(sprintf("Media  simulada %.3f  vs teórica %.3f\n", mean(ST), lognormal_mean(S0, mu, T)))
cat(sprintf("Desv.  simulada %.3f  vs teórica %.3f\n", desv(ST), lognormal_std(S0, mu, sigma, T)))


# ---- 4. Euler-Maruyama frente a la solución exacta ---------------------------
# Misma semilla ⇒ mismos incrementos ΔW en los dos esquemas: el error se puede
# medir trayectoria a trayectoria. Al multiplicar los pasos por 4, el error se
# reduce más o menos a la mitad (orden fuerte 1/2).

for (pasos in c(5, 20, 100, 1000)) {
  Sx <- gbm_paths(S0, mu, sigma, T, n_steps = pasos, n_paths = 2000, seed = 11)$S
  Se <- euler_maruyama(S0, mu, sigma, T, n_steps = pasos, n_paths = 2000, seed = 11)$S
  k  <- pasos + 1                        # última columna (Python: [:, -1])
  cat(sprintf("pasos=%5d   error fuerte medio |S_exacta - S_EM| en T: %.4f\n",
              pasos, mean(abs(Sx[, k] - Se[, k]))))
}


# ---- 5. Ejercicio en clase ---------------------------------------------------
# Calcula por simulación Cov(S(t1), S(t2)) y compárala con el resultado del
# cuaderno de ejercicios del tema:  S0² e^{μ(t1+t2)} (e^{σ² min{t1,t2}} - 1).

# Tu código aquí
# Pistas:
# - Usa la matriz S de la sección 3 (252 pasos en [0, 1]): el instante t
#   está en la columna round(t * 252) + 1.
# - cov(x, y) da la covarianza muestral de dos vectores.
# - Prueba con t1 = 0.3 y t2 = 0.8.


# ---- 6. Resolución de la Actividad 1 -----------------------------------------
# La resolución comentada se comparte en la sesión DESPUÉS de la fecha de
# entrega (23/11/2026). Puntos que revisaremos: desembolso inicial C + P,
# B/P a trozos, puntos de equilibrio E ± (C + P), interpretación en términos
# de volatilidad y calidad del informe según la rúbrica.
