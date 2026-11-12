# =============================================================================
#  Tema 5 — Movimiento browniano y modelo log-normal.
#  Versión en R de  src/mvdc/lognormal.py  (Temas 5 y 6).
#
#  Modelo:   dS = μ S dt + σ S dW,   S(0) = S0
#  Solución: S(t) = S0 · exp((μ - σ²/2) t + σ W(t))
#  Media:    E[S(t)] = S0 e^{μ t}
#  Varianza: V[S(t)] = S0² e^{2 μ t} (e^{σ² t} - 1)
#
#  Trayectorias como matrices: una FILA por trayectoria y una COLUMNA por
#  instante, igual que en Python. Python: W[i, k] (desde 0) · R: W[i + 1, k + 1].
#
#  Las simulaciones no dan los mismos números que NumPy con la misma semilla
#  (los generadores son distintos): compara propiedades (medias, varianzas,
#  convergencia), no trayectorias concretas.
# =============================================================================


# -----------------------------------------------------------------------------
# Simulación
# -----------------------------------------------------------------------------
.incrementos <- function(T, n_steps, n_paths, seed) {
  # Matriz n_paths × n_steps de incrementos ΔW = sqrt(Δt)·Z, Z ~ N(0, 1).
  # wiener_paths, gbm_paths y euler_maruyama la sortean del mismo modo:
  # con la misma semilla usan exactamente los mismos incrementos.
  if (!is.null(seed)) set.seed(seed)
  dt <- T / n_steps
  matrix(sqrt(dt) * rnorm(n_paths * n_steps), nrow = n_paths, ncol = n_steps)
}


wiener_paths <- function(T = 1.0, n_steps = 250, n_paths = 100, seed = NULL) {
  # Trayectorias del proceso de Wiener por recurrencia
  #   W(t_i) = W(t_{i-1}) + sqrt(Δt)·Z,   Z ~ N(0, 1).
  # Devuelve list(t = ..., W = ...), con W de tamaño n_paths × (n_steps + 1).
  #
  # Python: t, W = ln.wiener_paths(...)     R: res <- wiener_paths(...); res$t, res$W
  dW <- .incrementos(T, n_steps, n_paths, seed)
  # Suma acumulada por filas (Python: np.cumsum(dW, axis=1)), columna a columna
  W  <- matrix(0, nrow = n_paths, ncol = n_steps + 1)
  for (k in seq_len(n_steps)) W[, k + 1] <- W[, k] + dW[, k]
  list(t = seq(0, T, length.out = n_steps + 1), W = W)
}


gbm_paths <- function(S0, mu, sigma, T = 1.0, n_steps = 250, n_paths = 100, seed = NULL) {
  # Trayectorias exactas del movimiento browniano geométrico (solución de Itô).
  # Devuelve list(t = ..., S = ...).
  w <- wiener_paths(T, n_steps, n_paths, seed)
  # sweep suma el vector (μ - σ²/2)·t a cada fila (Python lo hace con broadcasting)
  S <- S0 * exp(sweep(sigma * w$W, 2, (mu - 0.5 * sigma^2) * w$t, "+"))
  list(t = w$t, S = S)
}


euler_maruyama <- function(S0, mu, sigma, T = 1.0, n_steps = 250, n_paths = 100, seed = NULL) {
  # Aproximación de Euler-Maruyama:  S_{i+1} = S_i + μ S_i Δt + σ S_i ΔW_i.
  # Con la misma semilla usa los mismos incrementos que gbm_paths, así que se
  # puede medir el error trayectoria a trayectoria.
  # Devuelve list(t = ..., S = ...).
  dW <- .incrementos(T, n_steps, n_paths, seed)
  dt <- T / n_steps
  S  <- matrix(NA_real_, nrow = n_paths, ncol = n_steps + 1)
  S[, 1] <- S0
  for (i in seq_len(n_steps)) {                 # Python: for i in range(n_steps):
    S[, i + 1] <- S[, i] * (1 + mu * dt + sigma * dW[, i])
  }
  list(t = seq(0, T, length.out = n_steps + 1), S = S)
}


# -----------------------------------------------------------------------------
# Media, desviación típica y banda de confianza
# -----------------------------------------------------------------------------
lognormal_mean <- function(S0, mu, t) {
  S0 * exp(mu * t)
}


lognormal_std <- function(S0, mu, sigma, t) {
  S0 * exp(mu * t) * sqrt(exp(sigma^2 * t) - 1)
}


confidence_band <- function(S0, mu, sigma, t, z = 1.96) {
  # Banda μ_S(t) ± z·σ_S(t) (Tema 6, predicción al 95 %).
  # Python devuelve una tupla  m, lo, hi = ln.confidence_band(...)
  # R devuelve una lista       b <- confidence_band(...); b$m, b$lo, b$hi
  m <- lognormal_mean(S0, mu, t)
  s <- lognormal_std(S0, mu, sigma, t)
  list(m = m, lo = m - z * s, hi = m + z * s)
}


# -----------------------------------------------------------------------------
# Tema 6 — estimación de parámetros
# -----------------------------------------------------------------------------
estimate_mme <- function(prices, dt = 1.0) {
  # Método de momentos estadísticos, ecuación (1) del Tema 6.
  # U_i = ln(S_i/S_{i-1});  μ = (Ū + s²/2)/Δt;  σ = s/√Δt.
  # Python devuelve una tupla  mu, sigma = ln.estimate_mme(S)
  # R devuelve una lista       e <- estimate_mme(S); e$mu, e$sigma
  S <- as.numeric(prices)
  U <- log(S[-1] / S[-length(S)])        # Python: np.log(S[1:] / S[:-1])
  m <- mean(U); s <- sd(U)               # sd() ya divide entre n - 1 (Python: ddof=1)
  list(mu = (m + s^2 / 2) / dt, sigma = s / sqrt(dt))
}


estimate_mmv <- function(prices, dt = 1.0) {
  # Máxima verosimilitud (vía Euler-Maruyama), ecuación (3) del Tema 6.
  # U_i = S_i/S_{i-1} - 1;  μ = Ū/Δt;  σ = sqrt((n-1)/(n Δt)) · s.
  S <- as.numeric(prices)
  U <- S[-1] / S[-length(S)] - 1
  n <- length(U)
  list(mu = mean(U) / dt, sigma = sqrt((n - 1) / (n * dt)) * sd(U))
}


estimate_mmnp <- function(prices, dt = 1.0) {
  # Método de momentos no paramétrico, ecuación (6) del Tema 6.
  S  <- as.numeric(prices)
  dS <- diff(S)                          # Python: S[1:] - S[:-1]
  Sp <- S[-length(S)]
  list(mu = sum(dS) / (dt * sum(Sp)),
       sigma = sqrt(sum(dS^2) / (dt * sum(Sp^2))))
}


ESTIMATORS <- list(MME = estimate_mme, MMV = estimate_mmv, MMNP = estimate_mmnp)


# -----------------------------------------------------------------------------
# Validación y predicción
# -----------------------------------------------------------------------------
rmse <- function(data, model) {
  # Error cuadrático medio (raíz), ecuación (7).
  sqrt(mean((as.numeric(data) - as.numeric(model))^2))
}


mape <- function(data, model) {
  # Error porcentual absoluto medio (%), ecuación (8).
  d <- as.numeric(data)
  100 * mean(abs((d - as.numeric(model)) / d))
}


fit_and_validate <- function(prices, dt = 1.0, methods = c("MME", "MMV", "MMNP")) {
  # Ajusta los estimadores pedidos, evalúa la media del modelo en t = 1..n
  # (t_i = i·Δt, S0 = primer dato) y devuelve un data.frame con μ, σ, ECM y EPAM.
  # Python: DataFrame con índice "método"  ·  R: data.frame con nombres de fila
  S <- as.numeric(prices)
  t <- (seq_along(S) - 1) * dt
  filas <- lapply(methods, function(nombre) {
    e <- ESTIMATORS[[nombre]](S, dt)
    ajuste <- lognormal_mean(S[1], e$mu, t)
    data.frame(mu = e$mu, sigma = e$sigma,
               ECM = rmse(S[-1], ajuste[-1]), "EPAM_%" = mape(S[-1], ajuste[-1]),
               check.names = FALSE)
  })
  tabla <- do.call(rbind, filas)          # Python: pd.DataFrame(rows)
  rownames(tabla) <- methods              # Python: .set_index("método")
  tabla
}
