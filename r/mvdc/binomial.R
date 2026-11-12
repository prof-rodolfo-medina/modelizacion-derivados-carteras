# =============================================================================
#  Temas 3 y 4 — Valoración de opciones europeas con árboles binomiales.
#  Versión en R de  src/mvdc/binomial.py
#
#  Convenciones (las del temario):
#  - Interés compuesto continuo: actualizar un periodo multiplica por e^{-r·dt}.
#  - Probabilidad neutral al riesgo  q* = (e^{r·dt}·S0 - Sd) / (Su - Sd),
#    que en un árbol recombinante con factores u, d queda q* = (e^{r·dt} - d)/(u - d).
#
#  Árboles como matrices: en Python  tree[j, t]  (índices desde 0);
#  en R  tree[j + 1, t + 1]  (índices desde 1). j = número de bajadas, t = periodo.
#
#  Requiere payoffs.R (call_payoff, put_payoff).
# =============================================================================


# -----------------------------------------------------------------------------
# Tema 3 — árbol monoperiodo
# -----------------------------------------------------------------------------
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


# -----------------------------------------------------------------------------
# Tema 4 — árbol multiperiodo recombinante
# -----------------------------------------------------------------------------
risk_neutral_q <- function(u, d, r, dt = 1) {
  q <- (exp(r * dt) - d) / (u - d)
  if (!(0 < q && q < 1))
    stop(sprintf("q* = %.4f fuera de (0,1): existe arbitraje con estos u, d, r.", q),
         call. = FALSE)
  q
}


stock_tree <- function(S0, u, d, n) {
  # Árbol del subyacente como matriz triangular superior (n+1)x(n+1):
  #   tree[j + 1, t + 1] = S0 · u^(t-j) · d^j   para j <= t   (j = número de bajadas).
  # Las casillas sin nodo quedan en NA (Python: np.nan).
  tree <- matrix(NA_real_, n + 1, n + 1)
  for (t in 0:n) {
    for (j in 0:t) {
      tree[j + 1, t + 1] <- S0 * u^(t - j) * d^j
    }
  }
  tree
}


option_tree <- function(S0, K, u, d, r, n, dt = 1, kind = "call") {
  # Árbol de valores de la opción europea por inducción hacia atrás
  # (se resuelve un árbol monoperiodo en cada nodo, de derecha a izquierda).
  # Devuelve  list(V = arbol_opcion, q = q*);  la prima es  V[1, 1].
  # Python devuelve la tupla (V, q):   V, q = b.option_tree(...)
  # R:                                 res <- option_tree(...); res$V; res$q
  q    <- risk_neutral_q(u, d, r, dt)
  disc <- exp(-r * dt)
  S    <- stock_tree(S0, u, d, n)
  pay  <- if (kind == "call") call_payoff else put_payoff
  V    <- matrix(NA_real_, n + 1, n + 1)
  V[, n + 1] <- pay(S[, n + 1], K)                # columna final: el pago
  for (t in rev(seq_len(n)) - 1) {                # t = n-1, ..., 0   (Python: range(n - 1, -1, -1))
    for (j in 0:t) {
      V[j + 1, t + 1] <- disc * (q * V[j + 1, t + 2] + (1 - q) * V[j + 2, t + 2])
    }
  }
  list(V = V, q = q)
}


binomial_price <- function(S0, K, u, d, r, n, dt = 1, kind = "call") {
  # Fórmula cerrada del Tema 4:
  #   V0 = e^{-r n dt} Σ_j C(n,j) q^{n-j} (1-q)^j · payoff(u^{n-j} d^j S0).
  q   <- risk_neutral_q(u, d, r, dt)
  pay <- if (kind == "call") call_payoff else put_payoff
  j   <- 0:n
  ST  <- S0 * u^(n - j) * d^j
  if (n <= 60) {                  # fórmula literal del temario
    w <- choose(n, j) * q^(n - j) * (1 - q)^j
  } else {                        # misma fórmula, evaluada con dbinom para n grande
    w <- dbinom(j, n, 1 - q)      # Python: scipy.stats.binom.pmf(j, n, 1 - q)
  }
  exp(-r * n * dt) * sum(w * pay(ST, K))
}


print_tree <- function(tree, decimals = 2) {
  # Impresión legible de un árbol triangular (filas = nº de bajadas).
  n <- ncol(tree) - 1
  for (j in 0:n) {
    fila <- vapply(0:n, function(t)
      if (j <= t) formatC(tree[j + 1, t + 1], width = 9, format = "f", digits = decimals)
      else strrep(" ", 9), character(1))
    cat(paste(fila, collapse = ""), "\n", sep = "")
  }
  invisible(tree)
}


# -----------------------------------------------------------------------------
# Sección 4.4 — Calibración de Hull-White (p = 1/2)
# -----------------------------------------------------------------------------
hull_white_ud <- function(prices) {
  # Estima u y d a partir de un histórico {S_0, ..., S_n}:
  #   U_i = S_i/S_{i-1} - 1,  u = 1 + Ū + s_U,  d = 1 + Ū - s_U
  # (s_U con divisor n-1, que es lo que hace sd() en R;
  #  Python: U.std(ddof=1)). Devuelve una lista con u, d, media y desviación.
  S <- as.numeric(prices)
  U <- S[-1] / S[-length(S)] - 1                  # Python: S[1:] / S[:-1] - 1
  m <- mean(U); s <- sd(U)
  list(u = 1 + m + s, d = 1 + m - s, media = m, desv = s)
}
