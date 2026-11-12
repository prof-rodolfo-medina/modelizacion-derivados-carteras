# =============================================================================
#  Tema 7 — Fórmula de Black-Scholes para opciones europeas y paridad put-call.
#  Versión en R de  src/mvdc/black_scholes.py
#
#  C = S0 N(d1) - K e^{-rT} N(d2)
#  P = K e^{-rT} N(-d2) - S0 N(-d1)
#  d1 = [ln(S0/K) + (r + σ²/2) T] / (σ √T),   d2 = d1 - σ √T
#
#  N(x) es pnorm(x) en R (Python: scipy.stats.norm.cdf).
#  Requiere binomial.R (binomial_price) para binomial_to_bs.
# =============================================================================


d1_d2 <- function(S0, K, T, r, sigma) {
  # Python devuelve una tupla  d1, d2 = bs.d1_d2(...)
  # R devuelve una lista       d <- d1_d2(...); d$d1, d$d2
  d1 <- (log(S0 / K) + (r + 0.5 * sigma^2) * T) / (sigma * sqrt(T))
  list(d1 = d1, d2 = d1 - sigma * sqrt(T))
}


bs_call <- function(S0, K, T, r, sigma) {
  d <- d1_d2(S0, K, T, r, sigma)
  S0 * pnorm(d$d1) - K * exp(-r * T) * pnorm(d$d2)
}


bs_put <- function(S0, K, T, r, sigma) {
  d <- d1_d2(S0, K, T, r, sigma)
  K * exp(-r * T) * pnorm(-d$d2) - S0 * pnorm(-d$d1)
}


bs_price <- function(S0, K, T, r, sigma, kind = "call") {
  if (kind == "call") bs_call(S0, K, T, r, sigma) else bs_put(S0, K, T, r, sigma)
}


put_call_parity_gap <- function(C, P, S0, K, T, r, d0 = 0.0) {
  # Residuo de la paridad  P - C = K e^{-rT} + d0 - S0  (d0 = dividendo
  # actualizado; 0 si no hay). Debe ser ~0 para precios libres de arbitraje.
  (P - C) - (K * exp(-r * T) + d0 - S0)
}


mc_price <- function(S0, K, T, r, sigma, kind = "call", n = 200000, seed = 0) {
  # Precio por Monte Carlo bajo la medida neutral al riesgo (μ = r):
  # e^{-rT} E[payoff(S_T)]. Útil para comparar con la fórmula cerrada.
  # Python devuelve (precio, error_estándar); R, list(precio = ..., error = ...).
  # El generador de R no es el de NumPy: el precio difiere en el 3.er decimal.
  if (!is.null(seed)) set.seed(seed)
  Z  <- rnorm(n)
  ST <- S0 * exp((r - 0.5 * sigma^2) * T + sigma * sqrt(T) * Z)
  pay  <- if (kind == "call") pmax(ST - K, 0) else pmax(K - ST, 0)
  disc <- exp(-r * T) * pay
  list(precio = mean(disc), error = sd(disc) / sqrt(n))
}


binomial_to_bs <- function(S0, K, T, r, sigma, n, kind = "call") {
  # Árbol CRR (u = e^{σ√Δt}, d = 1/u) con n pasos: converge a Black-Scholes
  # cuando n → ∞. Puente entre los Temas 4 y 7.
  dt <- T / n
  u  <- exp(sigma * sqrt(dt))
  binomial_price(S0, K, u, 1 / u, r, n, dt, kind)
}
