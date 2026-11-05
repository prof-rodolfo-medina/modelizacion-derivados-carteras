# =============================================================================
#  Tema 3 — Valoración de opciones europeas con un árbol binomial monoperiodo.
#  Versión en R de la parte del Tema 3 de  src/mvdc/binomial.py
#  (el árbol multiperiodo del Tema 4 se añadirá con la sesión 3).
#
#  Convenciones (las del temario):
#  - Interés compuesto continuo: actualizar un periodo multiplica por e^{-r·tau}.
#  - Probabilidad neutral al riesgo  q* = (e^{r·tau}·S0 - Sd) / (Su - Sd).
#
#  Requiere payoffs.R (call_payoff, put_payoff).
# =============================================================================


one_period_price <- function(S0, Su, Sd, K, r, tau = 1, kind = "call") {
  # Prima de una opción europea en un árbol monoperiodo.
  #
  # Devuelve una lista con la prima por el Método I (cartera acciones+opciones),
  # por el Método II (réplica con acciones+bonos), la Delta a* y q*.
  # Ambos métodos deben coincidir; se devuelven los dos con fines docentes.
  #
  # Python devuelve un dict:  res["prima_metodo_I"]
  # R devuelve una lista:     res$prima_metodo_I   (o res[["prima_metodo_I"]])
  if (!(Su > Sd)) stop("Se requiere Su > Sd.")
  pay  <- if (kind == "call") call_payoff else put_payoff
  U    <- pay(Su, K)
  D    <- pay(Sd, K)
  disc <- exp(-r * tau)

  # Método I: b* = -1 (se vende una opción), a* = (U - D)/(Su - Sd)
  a_star    <- (U - D) / (Su - Sd)
  V_metodo1 <- a_star * S0 + (U - a_star * Su) * disc

  # Método II: réplica; b* = (U - a* Su) e^{-r tau} bonos de valor 1
  b_star    <- (U - a_star * Su) * disc
  q_star    <- (exp(r * tau) * S0 - Sd) / (Su - Sd)
  V_metodo2 <- disc * (q_star * U + (1 - q_star) * D)

  list(
    U = U, D = D,
    delta = a_star,            # a* = ΔV/ΔS (Método I)
    bonos = b_star,            # b* (Método II)
    q = q_star,
    prima_metodo_I  = V_metodo1,
    prima_metodo_II = V_metodo2
  )
}


delta_hedge_pnl <- function(S0, Su, Sd, K, r, tau, premium_charged, n_options = 1) {
  # Resultado del corredor que vende n_options calls cobrando premium_charged
  # y se cubre comprando a*·n acciones financiadas al tipo libre de riesgo
  # (Sección 3.3). Devuelve la ganancia en ambos escenarios: deben coincidir
  # (cobertura perfecta).
  res    <- one_period_price(S0, Su, Sd, K, r, tau, "call")
  a      <- res$delta * n_options
  deuda  <- (a * S0 - premium_charged * n_options) * exp(r * tau)
  g_up   <- a * Su - deuda - res$U * n_options
  g_down <- a * Sd - deuda - res$D * n_options
  list(acciones = a, deuda_final = deuda, ganancia_sube = g_up, ganancia_baja = g_down)
}
