# =============================================================================
#  Clase 5 · Estimación del modelo log-normal y fórmula de Black-Scholes
#  —  VERSIÓN EN R
#
#  Semana 5 (30/11–04/12/2026) · Temas 6 y 7
#  Equivalente al cuaderno  clase-05-estimacion-lognormal-black-scholes.ipynb
#
#  Este script es de APOYO para quien ya programa en R: sigue las mismas
#  secciones que el cuaderno de Python para que puedas compararlos.
#  Las actividades evaluables (incluida la Actividad 2) se entregan en Python.
#
#  Cómo usarlo: ábrelo en RStudio y ejecútalo sección a sección (Ctrl+Enter),
#  o completo con  source("clase-05-estimacion-lognormal-black-scholes.R").
#  Guía de equivalencias Python ↔ R:  r/README.md
#
#  Objetivos:
#   1. Estimar μ y σ con tres métodos (MME, MMV, MMNP) sobre datos reales.
#   2. Validar el ajuste (ECM, EPAM) y predecir con intervalos de confianza
#      al 95 %.
#   3. Aplicar Black-Scholes, verificar la paridad put-call y la convergencia
#      binomial → Black-Scholes.
# =============================================================================


# ---- 0. Configuración --------------------------------------------------------
f <- Find(file.exists, file.path(c(".", "..", "../.."), "r", "mvdc", "cargar.R"))
source(if (is.null(f)) paste0("https://raw.githubusercontent.com/prof-rodolfo-medina/",
                              "modelizacion-derivados-carteras/main/r/mvdc/cargar.R")
       else f)
cargar_mvdc()


# =============================================================================
#  Parte A · Tema 6 — Estimación, validación y predicción
# =============================================================================

# ---- A.1 Datos (Tabla 1 del Tema 6) ------------------------------------------
S <- cargar("tema6_ibex_28dias.csv")$S        # Python: mvdc.datos.cargar(...)["S"].to_numpy()
plot(0:(length(S) - 1), S, type = "o", pch = 19, cex = 0.6,
     main = "Cotización - 28 días hábiles (Tema 6)", xlab = "t (días)", ylab = "S(t)")
grid()


# ---- A.2 Tres estimadores ----------------------------------------------------
#
#   Momentos (U_i = ln S_i/S_{i-1}):     μ = (Ū + s²/2)/Δt,   σ = s/√Δt
#   Máx. verosimilitud (U_i = S_i/S_{i-1} - 1):  μ = Ū/Δt,  σ = sqrt((n-1)/(nΔt))·s
#   No paramétrico:   μ = ΣΔS_i / (Δt ΣS_i),   σ = sqrt(Σ(ΔS_i)² / (Δt ΣS_i²))

tabla <- fit_and_validate(S, dt = 1.0)
round(tabla, 5)                                # Python: tabla.round(5)
# Nota: los apuntes dan μ_MMNP = 0.00284; con la fórmula (6) sale 0.00278
# (ver docs/erratas-temario.md).


# ---- A.3 Bandas de confianza al 95 % y predicción a 5 días -------------------
# Figura 2 y Tabla 2 del tema. El último dato es t = 27; la predicción a
# 5 días corresponde a t = 28..32 (en la Tabla 2 aparecen rotuladas 27..31).

t_fit  <- 0:(length(S) - 1)
t_pred <- length(S) + 0:4                      # Python: np.arange(len(S), len(S) + 5)
tt     <- 0:(length(S) + 4)

op <- par(mfrow = c(1, 3), mar = c(4.2, 4.2, 2.5, 1))   # Python: plt.subplots(1, 3)
pred <- list()
for (met in c("MME", "MMV", "MMNP")) {
  mu <- tabla[met, "mu"]; sigma <- tabla[met, "sigma"]  # Python: tabla.loc[met, "mu"]
  b <- confidence_band(S[1], mu, sigma, tt)
  plot(t_fit, S, pch = 19, cex = 0.5, xlim = range(tt), ylim = c(21, 32),
       main = met, xlab = "t", ylab = "S(t)")
  # Python: ax.fill_between(tt, lo, hi, alpha=0.2)
  polygon(c(tt, rev(tt)), c(b$lo, rev(b$hi)), col = adjustcolor("steelblue", 0.2), border = NA)
  lines(tt, b$m, col = "steelblue", lwd = 2)
  abline(v = length(S) - 1)
  legend("topleft", legend = c("datos", "media", "IC 95 %"), pch = c(19, NA, 15),
         lty = c(NA, 1, NA), col = c("black", "steelblue", adjustcolor("steelblue", 0.3)),
         bty = "n", cex = 0.8)
  bp <- confidence_band(S[1], mu, sigma, t_pred)
  pred[[met]] <- data.frame(media = bp$m, IC_inf = bp$lo, IC_sup = bp$hi, row.names = t_pred)
}
par(op)
# Python: pd.concat(pred, axis=1).round(2)
round(do.call(cbind, pred), 2)

# Discusión: ¿por qué las bandas son tan anchas si se ajusta con S0 fijo en t = 0?
# ¿Qué cambiaría si re-anclamos el modelo en el último dato observado?
# (Pista: σ_S(t) crece con t.)


# =============================================================================
#  Parte B · Tema 7 — Black-Scholes
# =============================================================================
#
#   C = S0 N(d1) - K e^{-rT} N(d2),     P = K e^{-rT} N(-d2) - S0 N(-d1)
#   d1 = [ln(S0/K) + (r + σ²/2) T] / (σ√T),     d2 = d1 - σ√T

# ---- B.1 Ejemplos 1 y 2 del tema ---------------------------------------------
S0 <- 74.625; K <- 100; T <- 1.6; r <- 0.05; sig <- 0.375
d <- d1_d2(S0, K, T, r, sig)                   # Python: d1, d2 = bs.d1_d2(...)
C <- bs_call(S0, K, T, r, sig); P <- bs_put(S0, K, T, r, sig)
cat(sprintf("d1=%.4f  d2=%.4f  C=%.4f  P=%.4f\n", d$d1, d$d2, C, P))
cat("Residuo paridad put-call:", put_call_parity_gap(C, P, S0, K, T, r), "\n")


# ---- B.2 Cuaderno de ejercicios del Tema 7 (los 7 casos) ---------------------
casos <- data.frame(S0 = c(80, 60, 50, 100, 120, 40, 12),
                    K  = c(70, 66, 60, 100, 130, 40, 10),
                    T  = c(3/12, 2/12, 1, 4/12, 6/12, 2, 4/12),
                    r  = c(.05, .06, .04, .055, .059, .048, .045),
                    sigma = c(.30, .40, .25, .50, .22, .60, .33))
# Las funciones son vectoriales: se aplican a todas las filas a la vez
# (Python: una lista por comprensión sobre los casos)
d <- with(casos, d1_d2(S0, K, T, r, sigma))
casos$d1   <- d$d1
casos$d2   <- d$d2
casos$Call <- with(casos, bs_call(S0, K, T, r, sigma))
casos$Put  <- with(casos, bs_put(S0, K, T, r, sigma))
round(casos, 4)


# ---- B.3 Del árbol binomial a Black-Scholes, y Monte Carlo -------------------
ns <- 1:200
exacto <- bs_call(100, 100, 1, 0.05, 0.2)
arbol  <- sapply(ns, function(n) binomial_to_bs(100, 100, 1, 0.05, 0.2, n))
plot(ns, arbol, type = "l", col = "steelblue", lwd = 1,
     main = "Convergencia binomial -> Black-Scholes", xlab = "n (pasos)", ylab = "prima call")
abline(h = exacto, col = "red", lwd = 2)
legend("topright", legend = c("árbol CRR", sprintf("Black-Scholes = %.4f", exacto)),
       col = c("steelblue", "red"), lwd = c(1, 2), bty = "n")
mc <- mc_price(100, 100, 1, 0.05, 0.2)         # Python: mc, se = bs.mc_price(...)
cat(sprintf("Monte Carlo: %.4f ± %.4f\n", mc$precio, 1.96 * mc$error))


# ---- B.4 Ejercicio en clase --------------------------------------------------
# Grafica la prima de la call y de la put en función de σ ∈ [0.05, 0.8] y de
# T ∈ [0.05, 3]. ¿Concuerda con la Tabla 1 de sensibilidad del Tema 4?
# ¿Qué ocurre con la put europea al aumentar T?

# Tu código aquí
# Pistas:
# - seq(0.05, 0.8, length.out = 100) da la malla de σ.
# - bs_call() y bs_put() son vectoriales: aceptan un vector de σ o de T.
# - par(mfrow = c(1, 2)) para dos gráficas lado a lado; lines() para añadir la put.


# ---- Presentación de la Actividad 2 ------------------------------------------
# Enunciado, rúbrica, plantilla y datos en actividades/actividad-2-cartera-minimo-riesgo/
# Entrega: lunes 14/12/2026, 23:59. La teoría necesaria (Temas 8 y 9) se ve en
# la Clase 6; hoy conviene empezar con la carga de datos y el cálculo de
# rendimientos. Recuerda: la actividad se entrega en Python.
