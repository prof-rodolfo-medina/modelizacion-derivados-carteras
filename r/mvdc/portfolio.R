# =============================================================================
#  Temas 8, 9 y 10 — Carteras de mínimo riesgo, Markowitz y CAPM.
#  Versión en R de  src/mvdc/portfolio.py
#
#  Notación (vectores fila, como en el temario):
#    m  = vector de rendimientos esperados (1 x n)
#    C  = matriz de varianzas-covarianzas (n x n)
#    1  = vector de unos
#    w  = vector de pesos, con 1·wᵀ = 1 (se admiten ventas en corto: w_i < 0)
#
#  En R un vector no es fila ni columna: m %*% w  y  w %*% C %*% w  funcionan
#  igual que  m @ w  y  w @ C @ w  de NumPy (devuelven matrices 1 x 1; por eso
#  se usa sum(m * w) o drop(...) para obtener un número).
# =============================================================================


# -----------------------------------------------------------------------------
# Datos: de precios a rendimientos y estadísticos
# -----------------------------------------------------------------------------
log_returns <- function(prices) {
  # Log-retornos R = ln(S_t / S_{t-1}) (Tema 8). Acepta un data.frame
  # (columnas = activos, nombres de fila = fechas) o una matriz (filas = fechas).
  # Python: np.log(prices / prices.shift(1)).dropna()
  P <- as.matrix(prices)
  R <- log(P[-1, , drop = FALSE] / P[-nrow(P), , drop = FALSE])
  if (is.data.frame(prices)) as.data.frame(R, check.names = FALSE) else R
}


mean_cov <- function(returns, periods_per_year = 1) {
  # Devuelve list(m, C) a partir de una matriz de rendimientos.
  # periods_per_year permite anualizar (252 para datos diarios).
  # cov() de R divide entre n - 1, como np.cov(..., ddof=1).
  R <- as.matrix(returns)
  list(m = colMeans(R) * periods_per_year,
       C = cov(R) * periods_per_year)
}


cov_from_corr <- function(sigmas, corr) {
  # C_ij = ρ_ij σ_i σ_j (Ejemplo 1 del Tema 9).   Python: corr * np.outer(s, s)
  as.matrix(corr) * outer(sigmas, sigmas)
}


portfolio_stats <- function(w, m, C) {
  # Rendimiento esperado μ = m·wᵀ y riesgo (desviación típica) σ = sqrt(w C wᵀ).
  # Python devuelve una tupla (mu, sigma); R, list(mu = ..., sigma = ...).
  list(mu = sum(m * w), sigma = sqrt(drop(w %*% C %*% w)))
}


# -----------------------------------------------------------------------------
# Tema 8 — Lagrange para formas cuadráticas con restricciones lineales
# -----------------------------------------------------------------------------
lagrange_quadratic <- function(A, B, b) {
  # Resuelve  mín x A xᵀ  s.a.  B xᵀ = b  (Ejemplo 1 del Tema 8).
  # λ* = 2 bᵀ (B A⁻¹ Bᵀ)⁻¹,   x* = ½ λ* B A⁻¹.
  # Los multiplicadores miden la sensibilidad del riesgo mínimo a cada
  # término independiente: ∂R*/∂b_i = λ*_i.
  # Python devuelve (x, lam); R, list(x = ..., lam = ...).
  A <- as.matrix(A)
  if (!is.matrix(B)) B <- matrix(B, ncol = ncol(A), byrow = TRUE)   # vector -> filas de B
  Ainv <- solve(A)
  lam <- drop(2 * b %*% solve(B %*% Ainv %*% t(B)))
  x <- drop(0.5 * lam %*% B %*% Ainv)
  list(x = x, lam = lam)
}


# -----------------------------------------------------------------------------
# Tema 9 — Cartera pura en riesgo
# -----------------------------------------------------------------------------
min_variance_weights <- function(C) {
  # Teorema 2 (Tema 9):  w* = 1 C⁻¹ / (1 C⁻¹ 1ᵀ).
  x <- solve(C, rep(1, nrow(C)))                 # C⁻¹ 1ᵀ sin invertir C
  x / sum(x)
}


target_return_weights <- function(m, C, mu) {
  # Teorema 3 (Tema 9): pesos de mínimo riesgo con rendimiento esperado μ.
  # Forma matricial  w* = bᵀ (B C⁻¹ Bᵀ)⁻¹ B C⁻¹,  B = [m; 1], b = (μ, 1).
  B <- rbind(m, rep(1, length(m)))               # Python: np.vstack([m, ones])
  lagrange_quadratic(C, B, c(mu, 1))$x
}


efficient_frontier <- function(m, C, mus) {
  # Frontera de mínima varianza (curva de Markowitz) para una malla de μ.
  # Python devuelve (sigmas, mus, pesos); R, list(sigmas, mus, pesos) con
  # una fila de pesos por cada μ.  La rama eficiente es μ >= μ_mín.
  W <- t(sapply(mus, function(mu) target_return_weights(m, C, mu)))
  if (length(mus) == 1) W <- matrix(W, nrow = 1)
  list(sigmas = sqrt(rowSums((W %*% C) * W)), mus = mus, pesos = W)
}


random_portfolios <- function(m, C, n = 5000, seed = 0, allow_short = FALSE) {
  # Carteras aleatorias para ilustrar la «bala de Markowitz».
  # Sin cortos: pesos Dirichlet(1, ..., 1), que se obtienen normalizando
  # variables exponenciales (Python: rng.dirichlet).  El generador de R no es
  # el de NumPy: la nube es otra, pero con la misma distribución.
  if (!is.null(seed)) set.seed(seed)
  k <- length(m)
  W <- if (!allow_short) matrix(rexp(n * k), n, k) else matrix(rnorm(n * k), n, k)
  W <- W / rowSums(W)
  list(sigmas = sqrt(rowSums((W %*% C) * W)), mus = drop(W %*% m), pesos = W)
}


# -----------------------------------------------------------------------------
# Tema 10 — Cartera mixta, CML y CAPM
# -----------------------------------------------------------------------------
tangency_weights <- function(m, C, mu_rf) {
  # Teorema 1 (Tema 10), Cartera del Mercado Capital:
  # w* = (m - μ_rf 1) C⁻¹ / ((m - μ_rf 1) C⁻¹ 1ᵀ).
  x <- solve(C, m - mu_rf)
  x / sum(x)
}


sharpe_ratio <- function(w, m, C, mu_rf) {
  s <- portfolio_stats(w, m, C)
  (s$mu - mu_rf) / s$sigma
}


capital_market_line <- function(sigma, mu_rf, mu_M, sigma_M) {
  # CML: μ = μ_rf + (μ_M - μ_rf)/σ_M · σ.
  mu_rf + (mu_M - mu_rf) / sigma_M * sigma
}


mixed_portfolio <- function(w_risky_total, mu_rf, mu_der, sigma_der) {
  # Ecuación (1) del Tema 10: punto (σ, μ) de una cartera mixta.
  # Python devuelve (sigma, mu); R, list(sigma = ..., mu = ...).
  list(sigma = w_risky_total * sigma_der,
       mu = mu_rf + w_risky_total * (mu_der - mu_rf))
}


beta <- function(asset_returns, market_returns) {
  # β_K = Cov(R_K, R_M) / σ²_M (recta de regresión del Tema 10).
  # cov() y var() de R dividen entre n - 1 (Python: ddof=1).
  # Ojo: este beta() oculta la función beta de R base; si la necesitas,
  # llámala como base::beta(a, b).
  cov(asset_returns, market_returns) / var(market_returns)
}


security_market_line <- function(beta_k, mu_M, mu_rf) {
  # SML: μ_K = μ_rf + β_K (μ_M - μ_rf).
  mu_rf + beta_k * (mu_M - mu_rf)
}


# -----------------------------------------------------------------------------
# Gráfica estándar
# -----------------------------------------------------------------------------
plot_frontier <- function(m, C, mu_range = NULL, n_points = 200, mu_rf = NULL,
                          asset_labels = NULL, cloud = TRUE, main = "") {
  # Dibuja: carteras aleatorias (sin cortos), frontera de mínima varianza,
  # rama eficiente, cartera de mínimo riesgo, activos individuales y, si se
  # da mu_rf, la CML y la cartera tangente.
  # Python devuelve el objeto ax; R devuelve (invisible) la cartera de mínimo
  # riesgo: list(pesos, mu, sigma).
  w_min <- min_variance_weights(C)
  st <- portfolio_stats(w_min, m, C)
  if (is.null(mu_range)) {
    span <- max(m) - min(m)
    mu_range <- c(min(m) - 0.5 * span, max(m) + 0.5 * span)
  }
  mus <- seq(mu_range[1], mu_range[2], length.out = n_points)
  fr <- efficient_frontier(m, C, mus)
  sd <- sqrt(diag(C))
  labels <- if (is.null(asset_labels)) paste0("a", seq_along(m)) else asset_labels

  nube <- if (cloud) random_portfolios(m, C, 4000) else NULL
  cml <- NULL
  if (!is.null(mu_rf)) {                          # CML y cartera tangente (Tema 10)
    wt <- tangency_weights(m, C, mu_rf)
    tg <- portfolio_stats(wt, m, C)
    pendiente <- (tg$mu - mu_rf) / tg$sigma
    x_max <- min(max(fr$sigmas), max(tg$sigma * 1.6, (max(mus) - mu_rf) / pendiente))
    xs <- seq(0, x_max, length.out = 50)
    cml <- list(x = xs, y = capital_market_line(xs, mu_rf, tg$mu, tg$sigma))
  }
  xlim <- range(c(fr$sigmas, sd, nube$sigmas, cml$x))
  ylim <- range(c(fr$mus, m, nube$mus, cml$y))
  plot(NA, xlim = xlim, ylim = ylim, main = main,
       xlab = expression("Riesgo " * sigma), ylab = expression("Rendimiento esperado " * mu))
  grid()
  if (cloud) points(nube$sigmas, nube$mus, pch = 16, cex = 0.3, col = adjustcolor("grey40", 0.3))
  inef <- fr$mus < st$mu
  lines(fr$sigmas[inef], fr$mus[inef], lty = 2, col = "steelblue", lwd = 1.2)
  lines(fr$sigmas[!inef], fr$mus[!inef], col = "steelblue", lwd = 2.4)
  points(st$sigma, st$mu, pch = 8, cex = 2, lwd = 2, col = "firebrick")
  points(sd, m, pch = 19)
  text(sd, m, labels, pos = 4, cex = 0.85)
  leyenda <- c("Carteras aleatorias (sin cortos)", "Frontera eficiente",
               sprintf("Mínimo riesgo (sigma = %.4f, mu = %.4f)", st$sigma, st$mu))
  col_ley <- c("grey50", "steelblue", "firebrick"); pch_ley <- c(16, NA, 8); lty_ley <- c(NA, 1, NA)
  if (!cloud) { leyenda <- leyenda[-1]; col_ley <- col_ley[-1]; pch_ley <- pch_ley[-1]; lty_ley <- lty_ley[-1] }
  if (!is.null(mu_rf)) {
    lines(cml$x, cml$y, col = "forestgreen", lwd = 1.5)
    points(tg$sigma, tg$mu, pch = 18, cex = 2, col = "forestgreen")
    leyenda <- c(leyenda, "CML", "Cartera de mercado")
    col_ley <- c(col_ley, "forestgreen", "forestgreen"); pch_ley <- c(pch_ley, NA, 18); lty_ley <- c(lty_ley, 1, NA)
  }
  # Esquina en la que la leyenda tapa menos puntos (Python: legend(loc="best")):
  # se mide el recuadro de la leyenda y se cuentan los puntos que quedarían debajo.
  caja <- legend("topleft", legend = leyenda, pch = pch_ley, lty = lty_ley, bty = "n",
                 cex = 0.8, plot = FALSE)$rect
  usr <- par("usr")
  xs_all <- c(fr$sigmas, sd, nube$sigmas, cml$x); ys_all <- c(fr$mus, m, nube$mus, cml$y)
  debajo <- function(x0, y0) sum(xs_all >= x0 & xs_all <= x0 + caja$w &
                                 ys_all >= y0 & ys_all <= y0 + caja$h)
  ocupados <- c(bottomright = debajo(usr[2] - caja$w, usr[3]), bottomleft = debajo(usr[1], usr[3]),
                topright = debajo(usr[2] - caja$w, usr[4] - caja$h), topleft = debajo(usr[1], usr[4] - caja$h))
  legend(names(which.min(ocupados)), legend = leyenda, col = col_ley, pch = pch_ley, lty = lty_ley,
         lwd = ifelse(is.na(lty_ley), 1, 2), bty = "n", cex = 0.8)
  invisible(list(pesos = w_min, mu = st$mu, sigma = st$sigma))
}
