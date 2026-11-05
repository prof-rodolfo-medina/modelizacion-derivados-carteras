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

cat(sprintf("Pruebas de R: %d comprobaciones correctas.\n", n_ok))
