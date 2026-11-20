# =============================================================================
#  Clase 6 · Carteras de mínimo riesgo y frontera eficiente de Markowitz
#  —  VERSIÓN EN R
#
#  Semana 6 (07–11/12/2026) · Temas 8 y 9
#  Equivalente al cuaderno  clase-06-carteras-minimo-riesgo-markowitz.ipynb
#
#  Este script es de APOYO para quien ya programa en R: sigue las mismas
#  secciones que el cuaderno de Python para que puedas compararlos.
#  Las actividades evaluables (incluida la Actividad 2) se entregan en Python,
#  con código autocontenido (sin la biblioteca del curso).
#
#  Cómo usarlo: ábrelo en RStudio y ejecútalo sección a sección (Ctrl+Enter),
#  o completo con  source("clase-06-carteras-minimo-riesgo-markowitz.R").
#  Guía de equivalencias Python ↔ R:  r/README.md
#
#  Objetivos:
#   1. Resolver con multiplicadores de Lagrange una minimización cuadrática
#      con restricciones lineales.
#   2. Calcular la cartera de mínimo riesgo  w* = 1 C⁻¹ / (1 C⁻¹ 1ᵀ).
#   3. Trazar la frontera eficiente y la «bala» de Markowitz con datos.
# =============================================================================


# ---- 0. Configuración --------------------------------------------------------
f <- Find(file.exists, file.path(c(".", "..", "../.."), "r", "mvdc", "cargar.R"))
source(if (is.null(f)) paste0("https://raw.githubusercontent.com/prof-rodolfo-medina/",
                              "modelizacion-derivados-carteras/main/r/mvdc/cargar.R")
       else f)
cargar_mvdc()


# ---- 1. Tema 8 - Lagrange (Ejemplo 1) ----------------------------------------
#
#   mín x A xᵀ  s.a.  B xᵀ = b,     λ* = 2 bᵀ (B A⁻¹ Bᵀ)⁻¹,   x* = ½ λ* B A⁻¹

A <- diag(c(2, 1, 3))                           # Python: np.diag([2, 1, 3])
B <- rbind(c(1, 1, 1), c(5, 10, 15))            # Python: [[1, 1, 1], [5, 10, 15]]
sol <- lagrange_quadratic(A, B, c(14, 150))     # Python: x, lam = pf.lagrange_quadratic(...)
x <- sol$x; lam <- sol$lam
riesgo <- function(x) drop(x %*% A %*% x)       # Python: x @ A @ x
cat("x* =", round(x, 6), "  λ* =", round(lam, 6), "  riesgo mínimo =", riesgo(x), "\n")

# Interpretación de λ*: sensibilidad del riesgo mínimo a cada restricción
cambios <- list("invertir 1 u.m. más" = c(15, 150), "exigir rentabilidad 145" = c(14, 145))
for (etiqueta in names(cambios)) {               # Python: for b_nuevo, etiqueta in [...]
  b_nuevo <- cambios[[etiqueta]]
  x2 <- lagrange_quadratic(A, B, b_nuevo)$x
  cat(sprintf("%s: ΔR real = %+.3f   aprox. λ*·Δb = %+.3f\n", format(etiqueta, width = 25),
              riesgo(x2) - riesgo(x), sum(lam * (b_nuevo - c(14, 150)))))
}


# ---- 2. Tema 9 - Cartera de mínimo riesgo (Ejemplo 1) ------------------------
m <- c(0.3, 0.2, 0.5)
C <- cov_from_corr(c(0.15, 0.02, 0.3),
                   rbind(c(1, -0.07, 0.02), c(-0.07, 1, 0.2), c(0.02, 0.2, 1)))
w <- min_variance_weights(C)
st <- portfolio_stats(w, m, C)                  # Python: mu_w, s_w = pf.portfolio_stats(...)
cat("w* =", round(w, 6), "\n")
cat(sprintf("μ* = %.6f   σ*² = %.7f   σ* = %.5f\n", st$mu, st$sigma^2, st$sigma))
# Los pesos no dependen de m, solo de C. Hay una venta en corto (w3 < 0):
# el problema (P-I) no impone w_i >= 0.


# ---- 3. Frontera eficiente con rendimiento prefijado (Teorema 3) -------------
plot_frontier(m, C, mu_range = c(0.1, 0.55), asset_labels = c("a1", "a2", "a3"),
              main = "Bala y frontera eficiente de Markowitz - Ejemplo del Tema 9")

# Los pesos de mínimo riesgo son lineales en μ: comprobación
mus <- seq(0.15, 0.45, length.out = 7)          # Python: np.linspace(0.15, 0.45, 7)
W <- efficient_frontier(m, C, mus)$pesos
tabla_w <- data.frame(round(W, 4), row.names = round(mus, 3))
names(tabla_w) <- c("w1", "w2", "w3")
tabla_w                                          # filas: μ objetivo


# ---- 4. Con datos: 4 activos simulados (2 años, diarios) ---------------------
# El mismo flujo que pide la Actividad 2, con otros datos (los de la Clase 7).
precios <- cargar("mercado_simulado.csv")[, c("AK1", "AK2", "AK3", "AK4")]
# Python: mvdc.datos.cargar("mercado_simulado.csv")[["AK1", "AK2", "AK3", "AK4"]]
R <- log_returns(precios)
est <- mean_cov(R, periods_per_year = 252)      # anualizados; Python: m5, C5 = pf.mean_cov(...)
m4 <- est$m; C4 <- est$C
round(data.frame("μ anual" = m4, "σ anual" = sqrt(diag(C4)), check.names = FALSE), 4)
round(cor(R), 2)                                 # Python: np.corrcoef(R, rowvar=False)

w4 <- min_variance_weights(C4)
round(w4, 4)
plot_frontier(m4, C4, asset_labels = colnames(precios),
              main = "Frontera eficiente - activos AK1-AK4 de mercado_simulado.csv (anualizado)")


# ---- 5. Ejercicio en clase ---------------------------------------------------
# 1. Repite la cartera de mínimo riesgo SIN ventas en corto (pesos entre 0 y 1
#    que sumen 1). ¿Cambia la solución? ¿Por qué?
# 2. ¿Qué tan estables son los pesos? Estima C con solo el primer año de datos
#    y compara.

# Tu código aquí
# Pistas:
# - En Python se usa scipy.optimize.minimize con bounds=[(0, 1)]*n. En R base,
#   optim(..., method = "L-BFGS-B", lower = 0, upper = 1) admite cotas; la
#   restricción sum(w) = 1 se puede imponer optimizando n - 1 pesos y
#   calculando el último como 1 - sum(resto), o con constrOptim().
# - El primer año son unas 252 filas: R[1:252, ] (Python: R.iloc[:252]).


# ---- Recordatorio ------------------------------------------------------------
# La Actividad 2 se entrega el lunes 14/12/2026 a las 23:59 (en Python).
