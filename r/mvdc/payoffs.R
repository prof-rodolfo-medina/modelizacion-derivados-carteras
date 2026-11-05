# =============================================================================
#  Temas 1 y 2 — Pagos (pay-off) y beneficios/pérdidas (B/P) a vencimiento.
#  Versión en R del módulo de Python  src/mvdc/payoffs.py
#
#  Las funciones tienen el MISMO nombre y los MISMOS argumentos que en Python,
#  para que puedas comparar un código con el otro línea a línea.
#  Todas aceptan ST escalar o vector y devuelven un vector del mismo tamaño:
#
#    ST <- seq(0, 200, length.out = 401)
#    bp <- long_call(ST, K = 100, C = 5)
# =============================================================================


# -----------------------------------------------------------------------------
# Pay-off bruto (sin prima) — Tabla 4 del Tema 1
# -----------------------------------------------------------------------------
call_payoff <- function(ST, K) {
  # (S_T - K)^+       Python: np.maximum(ST - K, 0)
  pmax(as.numeric(ST) - K, 0)
}

put_payoff <- function(ST, K) {
  # (K - S_T)^+
  pmax(K - as.numeric(ST), 0)
}


# -----------------------------------------------------------------------------
# Beneficios/pérdidas con prima — expresión (1) del Tema 1
# -----------------------------------------------------------------------------
long_call  <- function(ST, K, C) call_payoff(ST, K) - C   # (B/P)_CL = (S_T - K)^+ - C
short_call <- function(ST, K, C) C - call_payoff(ST, K)   # (B/P)_CC = C - (S_T - K)^+
long_put   <- function(ST, K, P) put_payoff(ST, K) - P    # (B/P)_PL = (K - S_T)^+ - P
short_put  <- function(ST, K, P) P - put_payoff(ST, K)    # (B/P)_PC = P - (K - S_T)^+


# -----------------------------------------------------------------------------
# Futuros — expresión (1) del Tema 2
# -----------------------------------------------------------------------------
long_future  <- function(ST, K) as.numeric(ST) - K        # (B/P)_FL = S_T - K
short_future <- function(ST, K) K - as.numeric(ST)        # (B/P)_FC = K - S_T


# -----------------------------------------------------------------------------
# Terminología (Tabla 5 del Tema 1) y valor intrínseco/extrínseco
# -----------------------------------------------------------------------------
moneyness <- function(St, K, kind = "call") {
  # Devuelve "ITM", "ATM" u "OTM" para una call o una put.
  # Funciona con vectores: moneyness(100, c(90, 100, 110))
  diff <- if (kind == "call") St - K else K - St
  ifelse(abs(diff) < 1e-8, "ATM", ifelse(diff > 0, "ITM", "OTM"))
}

intrinsic_value <- function(St, K, kind = "call") {
  # Valor intrínseco VI (Definición 6 del Tema 1)
  if (kind == "call") call_payoff(St, K) else put_payoff(St, K)
}

extrinsic_value <- function(premium, St, K, kind = "call") {
  # Valor extrínseco VE = prima - VI (Definición 7 del Tema 1)
  premium - intrinsic_value(St, K, kind)
}


# -----------------------------------------------------------------------------
# Estrategias compuestas
# -----------------------------------------------------------------------------
# En Python cada pata es un diccionario:
#     {"tipo": "call", "posicion": +1, "K": 100, "prima": 5}
# En R es una lista con nombres:
#     list(tipo = "call", posicion = +1, K = 100, prima = 5)
# y la estrategia es una lista de patas:  list(pata1, pata2, ...)

leg_value <- function(ST, leg) {
  # B/P de una sola pata (sin multiplicar por la cantidad)
  prima <- if (is.null(leg$prima)) 0 else leg$prima
  clave <- paste(leg$tipo, leg$posicion)
  switch(clave,
    "call 1"    = long_call(ST, leg$K, prima),
    "call -1"   = short_call(ST, leg$K, prima),
    "put 1"     = long_put(ST, leg$K, prima),
    "put -1"    = short_put(ST, leg$K, prima),
    "future 1"  = long_future(ST, leg$K),
    "future -1" = short_future(ST, leg$K),
    stop("Pata no reconocida: tipo = '", leg$tipo, "', posicion = ", leg$posicion)
  )
}

strategy <- function(ST, legs) {
  # B/P total de una estrategia formada por varias patas.
  #
  # Ejemplo — opción de compra cubierta (Tema 2): futuro largo + call corta
  #   legs <- list(list(tipo = "future", posicion = +1, K = 100),
  #                list(tipo = "call",   posicion = -1, K = 100, prima = 5))
  #   strategy(ST, legs)
  total <- numeric(length(ST))
  for (leg in legs) {
    cantidad <- if (is.null(leg$cantidad)) 1 else leg$cantidad
    total <- total + cantidad * leg_value(ST, leg)
  }
  total
}

breakeven_points <- function(ST, values) {
  # Puntos de equilibrio (B/P = 0) estimados por interpolación lineal
  # entre los nodos de la malla ST.
  ST <- as.numeric(ST)
  v  <- as.numeric(values)
  n  <- length(ST)
  pts <- c()
  for (i in seq_len(n - 1)) {               # Python: for i in range(len(ST) - 1)
    if (v[i] == 0) {
      pts <- c(pts, ST[i])
    } else if (v[i] * v[i + 1] < 0) {
      pts <- c(pts, ST[i] - v[i] * (ST[i + 1] - ST[i]) / (v[i + 1] - v[i]))
    }
  }
  if (v[n] == 0) pts <- c(pts, ST[n])
  sort(unique(round(pts, 10)))
}

plot_strategy <- function(ST, values, title = NULL, label = "B/P total",
                          components = NULL, mark_breakeven = TRUE) {
  # Gráfica estándar de B/P a vencimiento (gráficos base de R, sin paquetes).
  # `components` es una lista opcional con nombres  list(etiqueta = vector, ...)
  # para dibujar las patas individuales con línea discontinua.
  todos <- c(list(values), components)
  ylim  <- range(unlist(todos))
  plot(ST, values, type = "n", ylim = ylim, main = title,
       xlab = expression(S[T]), ylab = "Beneficio / pérdida")
  grid(col = "grey85", lty = 1)
  abline(h = 0, lwd = 0.8)

  colores <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd")
  etiquetas <- c(); cols <- c(); ltys <- c(); lwds <- c()
  if (!is.null(components)) {
    for (i in seq_along(components)) {
      lines(ST, components[[i]], lty = 2, lwd = 1, col = colores[i + 1])
      etiquetas <- c(etiquetas, names(components)[i])
      cols <- c(cols, colores[i + 1]); ltys <- c(ltys, 2); lwds <- c(lwds, 1)
    }
  }
  lines(ST, values, lwd = 2.2, col = colores[1])
  etiquetas <- c(etiquetas, label); cols <- c(cols, colores[1])
  ltys <- c(ltys, 1); lwds <- c(lwds, 2.2)

  if (mark_breakeven) {
    for (be in breakeven_points(ST, values)) {
      points(be, 0, pch = 19)
      text(be, 0, sprintf("%.2f", be), pos = 3, cex = 0.8)
    }
  }
  # La leyenda va a la esquina con menos curvas (como loc="best" en matplotlib)
  xr <- range(ST); yr <- ylim
  ocupacion <- function(izq, arriba) {
    enx <- if (izq) ST <= xr[1] + 0.35 * diff(xr) else ST >= xr[2] - 0.35 * diff(xr)
    sum(sapply(todos, function(v) {
      eny <- if (arriba) v >= yr[2] - 0.3 * diff(yr) else v <= yr[1] + 0.3 * diff(yr)
      sum(enx & eny)
    }))
  }
  esquinas <- c(topleft = ocupacion(TRUE, TRUE), topright = ocupacion(FALSE, TRUE),
                bottomleft = ocupacion(TRUE, FALSE), bottomright = ocupacion(FALSE, FALSE))
  legend(names(which.min(esquinas)), legend = etiquetas, col = cols, lty = ltys, lwd = lwds,
         bg = "white", cex = 0.75)
  invisible(NULL)
}
