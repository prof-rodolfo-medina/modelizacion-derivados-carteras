# =============================================================================
#  Pruebas de la versión en R: comprueba que da los mismos resultados que la
#  biblioteca de Python (los valores de referencia salen de src/mvdc).
#  Ejecutar desde la raíz del repositorio:   Rscript r/pruebas.R
# =============================================================================

source("r/mvdc/cargar.R")
cargar_mvdc()

cerca <- function(a, b, tol = 1e-8) isTRUE(all.equal(a, b, tolerance = tol))
n_ok <- 0
comprobar <- function(descripcion, condicion) {
  if (!isTRUE(condicion)) stop("FALLA: ", descripcion, call. = FALSE)
  n_ok <<- n_ok + 1
}

# --- Temas 1 y 2 --------------------------------------------------------------
ST <- seq(50, 150, length.out = 501)
comprobar("call larga en S_T = 120", long_call(120, 100, 6) == 14)
comprobar("put corta en S_T = 80",   short_put(80, 100, 5) == -15)
comprobar("moneyness", identical(moneyness(100, c(90, 100, 110)), c("ITM", "ATM", "OTM")))
comprobar("moneyness put", identical(moneyness(100, 110, "put"), "ITM"))
comprobar("valor extrínseco", extrinsic_value(12, 100, 90) == 2)
comprobar("Call − Put = Futuro",
          cerca(call_payoff(ST, 100) - put_payoff(ST, 100), long_future(ST, 100)))
spread <- list(list(tipo = "call", posicion = +1, K = 95,  prima = 8),
               list(tipo = "call", posicion = -1, K = 110, prima = 2))
comprobar("equilibrio bull call spread", cerca(breakeven_points(ST, strategy(ST, spread)), 101))
cubierta <- list(list(tipo = "future", posicion = +1, K = 100),
                 list(tipo = "call",   posicion = -1, K = 100, prima = 6))
comprobar("equilibrio call cubierta", cerca(breakeven_points(ST, strategy(ST, cubierta)), 94))
comprobar("cantidad", cerca(strategy(120, list(list(tipo = "call", posicion = 1, K = 100,
                                                     prima = 5, cantidad = 2))), 30))

# --- Tema 3 -------------------------------------------------------------------
res <- one_period_price(100, 120, 90, 105, 0.04879, 1, "call")
comprobar("prima Método I",  cerca(res$prima_metodo_I, 7.1428501070237616))
comprobar("Métodos I y II coinciden", cerca(res$prima_metodo_I, res$prima_metodo_II))
comprobar("delta call", res$delta == 0.5)
comprobar("q*", cerca(res$q, 0.4999994254070349))
put <- one_period_price(60, 80, 50, 65, 0.048, kind = "put")
comprobar("prima put", cerca(put$prima_metodo_I, 8.12535148310019))
comprobar("delta put", put$delta == -0.5)
cob <- delta_hedge_pnl(60, 80, 50, 65, 0.048, 1, 6.25, 100000)
comprobar("cobertura delta, prima 6.25", cerca(cob$ganancia_sube, 8219.69360438222, 1e-6))
comprobar("cobertura perfecta", cerca(cob$ganancia_sube, cob$ganancia_baja))
comprobar("Su > Sd", inherits(try(one_period_price(100, 90, 120, 105, 0.05),
                                  silent = TRUE), "try-error"))

# --- Tema 4 -------------------------------------------------------------------
comprobar("q* del árbol del tema", cerca(risk_neutral_q(1.1, 0.9, 0.05), 0.7563554818801203))
comprobar("q* fuera de (0,1) da error", inherits(try(risk_neutral_q(1.1, 0.9, 0.2),
                                                     silent = TRUE), "try-error"))
S <- stock_tree(100, 1.1, 0.9, 3)
comprobar("árbol del subyacente", cerca(S[, 4], c(133.1, 108.9, 89.1, 72.9)) &&
                                  is.na(S[2, 1]) && cerca(S[2, 3], 99))
arb <- option_tree(100, 105, 1.1, 0.9, 0.05, 3)
comprobar("call por inducción (Figura 7)", cerca(arb$V[1, 1], 11.868641351285918))
comprobar("nodo t = 1 abajo (errata 2.05)", cerca(arb$V[2, 2], 2.018771089514609))
comprobar("inducción = fórmula cerrada",
          cerca(arb$V[1, 1], binomial_price(100, 105, 1.1, 0.9, 0.05, 3)))
comprobar("put K = 100 (fórmula cerrada)",
          cerca(binomial_price(100, 100, 1.1, 0.9, 0.05, 3, kind = "put"), 1.6010577694145187))
comprobar("put K = 100 (inducción)",
          cerca(option_tree(100, 100, 1.1, 0.9, 0.05, 3, kind = "put")$V[1, 1], 1.6010577694145187))
comprobar("call K = 100", cerca(binomial_price(100, 100, 1.1, 0.9, 0.05, 3), 15.530260126908768))
comprobar("sensibilidad u = 1.2, d = 0.8",
          cerca(binomial_price(100, 105, 1.2, 0.8, 0.05, 3), 18.32985139672265))
comprobar("sensibilidad put r = 0.08",
          cerca(binomial_price(100, 105, 1.1, 0.9, 0.08, 3, kind = "put"), 0.2548583368039528))
u200 <- exp(0.2 * sqrt(1 / 200))
comprobar("n > 60 (dbinom)", cerca(binomial_price(100, 100, u200, 1 / u200, 0.05 / 200, 200),
                                   10.440591259859852))
serie <- cargar("tema6_ibex_28dias.csv")$S
comprobar("datos del Tema 6", length(serie) == 28 && serie[1] == 24.38)
hw <- hull_white_ud(serie)
comprobar("Hull-White u", cerca(hw$u, 1.0171082566580978))
comprobar("Hull-White d", cerca(hw$d, 0.9885731600841047))
comprobar("Hull-White media y desviación",
          cerca(hw$media, 0.0028407083711013722) && cerca(hw$desv, 0.014267548286996582))
comprobar("call ATM a 5 días con Hull-White",
          cerca(binomial_price(serie[28], serie[28], hw$u, hw$d, 0.03 / 252, 5), 0.320881233868429))

cat(sprintf("Pruebas de R: %d comprobaciones correctas.\n", n_ok))
