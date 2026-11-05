# =============================================================================
#  Clase 2 · Árboles binomiales monoperiodo y cobertura delta  —  VERSIÓN EN R
#
#  Semana 2 (09–13/11/2026) · Tema 3
#  Equivalente al cuaderno  clase-02-arboles-binomiales-monoperiodo.ipynb
#
#  Este script es de APOYO para quien ya programa en R: sigue las mismas
#  secciones que el cuaderno de Python para que puedas compararlos.
#  Las actividades evaluables (incluida la Actividad 1) se entregan en Python.
#
#  Cómo usarlo: ábrelo en RStudio y ejecútalo sección a sección (Ctrl+Enter),
#  o completo con  source("clase-02-arboles-binomiales-monoperiodo.R").
#  Guía de equivalencias Python ↔ R:  r/README.md
#
#  Objetivos:
#   1. Calcular la prima racional de una opción europea en un árbol de un
#      periodo (Métodos I y II).
#   2. Mostrar con números por qué cualquier otro precio genera arbitraje.
#   3. Implementar la cobertura delta de un corredor que vende calls.
# =============================================================================


# ---- 0. Configuración --------------------------------------------------------
f <- Find(file.exists, file.path(c(".", "..", "../.."), "r", "mvdc", "cargar.R"))
source(if (is.null(f)) paste0("https://raw.githubusercontent.com/prof-rodolfo-medina/",
                              "modelizacion-derivados-carteras/main/r/mvdc/cargar.R")
       else f)
cargar_mvdc()


# ---- 1. Método I — cartera de acciones y opciones sin riesgo -----------------
# Con b* = -1 (vendemos una opción) la cartera a*·S - V es sin riesgo si
#
#     a* = (U - D) / (Su - Sd) = Δ ,     V0 = a*·S0 + (U - a*·Su)·e^{-r·tau}
#
# ---- 2. Método II — réplica con acciones y bonos -----------------------------
#
#     V0 = e^{-r·tau}·( q*·U + (1 - q*)·D ),     q* = (e^{r·tau}·S0 - Sd) / (Su - Sd)

res <- one_period_price(S0 = 100, Su = 120, Sd = 90, K = 105, r = 0.04879, tau = 1,
                        kind = "call")
round(unlist(res), 4)                  # Python: pd.Series(res).round(4)


# ---- 3. ¿Qué pasa si el mercado cotiza otra prima? — Arbitraje ---------------
# Reproducimos la discusión del tema con V = 7.25 (cara) y V = 7.00 (barata).

S0 <- 100; Su <- 120; Sd <- 90; K <- 105; r <- 0.04879

arbitraje <- function(V_mercado) {
  V_justo <- one_period_price(S0, Su, Sd, K, r)$prima_metodo_I
  signo   <- if (V_mercado > V_justo) -1 else +1   # vendemos si está cara, compramos si está barata
  a       <- -signo * 1                            # b = -2a  (una acción, dos opciones)
  bopc    <-  signo * 2
  coste0  <- a * S0 + bopc * V_mercado             # > 0: pedimos prestado; < 0: invertimos
  finales <- c()
  for (escenario in c("sube", "baja")) {
    S <- if (escenario == "sube") Su else Sd
    finales[escenario] <- a * S + bopc * max(S - K, 0) - coste0 * exp(r)
  }
  list(V_justo = V_justo, finales = finales)       # Python devolvía una tupla
}

for (V in c(7.25, 7.00)) {
  out <- arbitraje(V)
  cat(sprintf("V mercado = %.2f (justo %.4f) → ganancia sin riesgo: sube %.4f, baja %.4f\n",
              V, out$V_justo, out$finales["sube"], out$finales["baja"]))
}


# ---- 4. Cobertura delta del corredor (Sección 3.3) ---------------------------
# El corredor vende N = 100 000 calls (S0 = 60, Su = 80, Sd = 50, K = 65,
# r = 0.048) y compra a*·N acciones financiadas en el banco.

primas <- c(6.00, one_period_price(60, 80, 50, 65, 0.048)$prima_metodo_I, 6.25)
for (prima in primas) {
  r_ <- delta_hedge_pnl(60, 80, 50, 65, 0.048, 1, prima, 100000)
  cat(sprintf("prima cobrada %7.4f → ganancia si sube %15s | si baja %15s\n", prima,
              formatC(r_$ganancia_sube, format = "f", digits = 2, big.mark = ","),
              formatC(r_$ganancia_baja, format = "f", digits = 2, big.mark = ",")))
}

# Nota: en los apuntes la ganancia con prima 6.25 aparece como 6 250, porque se
# redondea e^{0.048} ≈ 1.05. Con el factor exacto la ganancia es ≈ 8 219.69 en
# ambos escenarios — lo importante es que COINCIDE en los dos.


# ---- 5. Ejercicio en clase ---------------------------------------------------
# Repite el análisis para una PUT europea con los mismos datos (K = 65).
# ¿Qué signo tiene la delta? ¿Qué hace ahora el corredor para cubrirse?

# Tu código aquí
# one_period_price(60, 80, 50, 65, 0.048, kind = "put")


# ---- 6. Presentación de la Actividad 1 — Long straddle -----------------------
# El enunciado completo, la rúbrica, la plantilla y la lista de comprobación
# están en  actividades/actividad-1-straddle/README.md
#
# Entrega: lunes 23/11/2026, 23:59 (por el aula virtual de UNIR, no por GitHub).
# La entrega se hace en Python (cuaderno .ipynb); puedes explorar primero en R
# y luego migrar tu código con ayuda de r/README.md.
#
# Ideas a repasar hoy: B/P de call larga y put larga (Clase 1), puntos de
# equilibrio, por qué la estrategia *apuesta por volatilidad* y no por dirección.
