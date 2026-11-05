# =============================================================================
#  Clase 1 · Opciones financieras y estrategias sintéticas  —  VERSIÓN EN R
#
#  Semana 1 (02–06/11/2026) · Temas 1 y 2
#  Equivalente al cuaderno  clase-01-opciones-y-estrategias-sinteticas.ipynb
#
#  Este script es de APOYO para quien ya programa en R: sigue las mismas
#  secciones que el cuaderno de Python para que puedas compararlos.
#  Las actividades evaluables se entregan en Python.
#
#  Cómo usarlo: ábrelo en RStudio y ejecútalo sección a sección (Ctrl+Enter),
#  o completo con  source("clase-01-opciones-y-estrategias-sinteticas.R").
#  Guía de equivalencias Python ↔ R:  r/README.md
#
#  Objetivos de la sesión:
#   1. Recordar los elementos de un contrato de opción (K, T, prima, posición).
#   2. Construir y leer los diagramas de B/P a vencimiento.
#   3. Combinar futuros y opciones para obtener estrategias sintéticas y
#      verificar numéricamente la relación fundamental  Call − Put = Futuro.
# =============================================================================


# ---- 0. Configuración --------------------------------------------------------
# Python:  import mvdc ;  from mvdc import payoffs as po
# En R no hay espacios de nombres "po.": las funciones quedan cargadas
# directamente (long_call(), strategy(), ...).
f <- Find(file.exists, file.path(c(".", "..", "../.."), "r", "mvdc", "cargar.R"))
source(if (is.null(f)) paste0("https://raw.githubusercontent.com/prof-rodolfo-medina/",
                              "modelizacion-derivados-carteras/main/r/mvdc/cargar.R")
       else f)
cargar_mvdc()


# ---- 1. Pay-off y B/P de las cuatro posiciones básicas -----------------------
#
#   Posición     B/P a vencimiento
#   Call larga   (S_T - K)^+ - C
#   Call corta   C - (S_T - K)^+
#   Put larga    (K - S_T)^+ - P
#   Put corta    P - (K - S_T)^+

K <- 100; C <- 6; P <- 5
ST <- seq(50, 150, length.out = 501)            # Python: np.linspace(50, 150, 501)

casos <- list(                                  # Python: lista de tuplas (título, B/P)
  "Call larga" = long_call(ST, K, C),
  "Call corta" = short_call(ST, K, C),
  "Put larga"  = long_put(ST, K, P),
  "Put corta"  = short_put(ST, K, P)
)

op <- par(mfrow = c(2, 2), mar = c(4, 4, 2.5, 1))   # Python: plt.subplots(2, 2)
for (titulo in names(casos)) {
  plot_strategy(ST, casos[[titulo]], title = titulo, label = "B/P")
}
par(op)

# Pregunta para el grupo: ¿en qué intervalo de S_T el tenedor de la call
# *ejerce aunque pierda dinero*?
# (Zona crítica [K, K + C]; para la put, [K - P, K].)


# ---- 2. Terminología ITM / ATM / OTM y valor intrínseco (Ejercicio 2, Tema 1)
# VI = valor intrínseco,  VE = valor extrínseco = prima - VI

S_t <- 100
tabla <- data.frame(K = c(90, 95, 100, 105, 110),     # Python: pd.DataFrame({...})
                    prima = c(12, 10, 8, 6, 4))
tabla$clasificacion <- moneyness(S_t, tabla$K)        # vectorizado: sin bucle
tabla$VI <- intrinsic_value(S_t, tabla$K)
tabla$VE <- tabla$prima - tabla$VI
print(tabla)


# ---- 3. Futuros y estrategias sintéticas (Tema 2) ----------------------------
# Se combinan, sobre el mismo subyacente, mismo K y mismo T, un futuro y una
# opción. La relación que guía todo el tema es   Call − Put = Futuro.

# Cada pata es una lista con nombres (en Python, un diccionario)
estrategias <- list(
  "Opción de compra cubierta\n(futuro largo + call corta)" =
    list(list(tipo = "future", posicion = +1, K = K),
         list(tipo = "call",   posicion = -1, K = K, prima = C)),
  "Opuesta a la cubierta\n(futuro corto + call larga)" =
    list(list(tipo = "future", posicion = -1, K = K),
         list(tipo = "call",   posicion = +1, K = K, prima = C)),
  "Protectora con put\n(futuro largo + put larga)" =
    list(list(tipo = "future", posicion = +1, K = K),
         list(tipo = "put",    posicion = +1, K = K, prima = P)),
  "Protectora con put\n(futuro corto + put corta)" =
    list(list(tipo = "future", posicion = -1, K = K),
         list(tipo = "put",    posicion = -1, K = K, prima = P))
)

nombre_pata <- function(leg) {
  tipo <- c(future = "futuro", call = "call", put = "put")[[leg$tipo]]
  lado <- if (leg$posicion > 0) "larg" else "cort"
  paste0(tipo, " ", lado, if (leg$tipo == "future") "o" else "a")
}

op <- par(mfrow = c(2, 2), mar = c(4, 4, 3.5, 1))
for (titulo in names(estrategias)) {
  legs  <- estrategias[[titulo]]
  comps <- lapply(legs, function(l) strategy(ST, list(l)))  # B/P de cada pata
  names(comps) <- sapply(legs, nombre_pata)
  plot_strategy(ST, strategy(ST, legs), title = titulo, components = comps)
}
par(op)

# Comprobación numérica de las equivalencias deducidas en el tema
# (en pay-off, sin primas).  Python: np.allclose(a, b)  ->  R: isTRUE(all.equal(a, b))
fut   <- long_future(ST, K)
callp <- call_payoff(ST, K)
putp  <- put_payoff(ST, K)
cat("Futuro − Call = −Put :", isTRUE(all.equal(fut - callp, -putp)), "\n")
cat("Futuro + Put  =  Call:", isTRUE(all.equal(fut + putp, callp)), "\n")
cat("−Futuro + Call =  Put:", isTRUE(all.equal(-fut + callp, putp)), "\n")


# ---- 4. Ejercicio en clase (10 min) ------------------------------------------
# Un inversor compra una call con K1 = 95 (prima 8) y vende una call con
# K2 = 110 (prima 2) — un *bull call spread*.
#   1. Escribe la expresión de B/P total a trozos.
#   2. Grafícala con strategy() y plot_strategy() y localiza el punto de equilibrio.
#   3. ¿Cuál es la pérdida máxima? ¿Y la ganancia máxima? ¿Qué visión del
#      mercado refleja?

# Tu código aquí
legs <- list(
  # list(tipo = "call", posicion = +1, K = 95, prima = 8),
  # ...
)


# ---- 5. Antes de la próxima sesión -------------------------------------------
# - Microtests 1.1–1.3 y 2.1–2.3 (fecha límite común: 10/01/2027 23:59).
# - La Actividad 1 se presenta en la Clase 2: repasa los B/P de call y put larga.
