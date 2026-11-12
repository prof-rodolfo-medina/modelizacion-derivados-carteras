# =============================================================================
#  Carga de los conjuntos de datos del repositorio (carpeta datos/).
#  Versión en R de  src/mvdc/datos.py
#
#  Funciona igual en local (repositorio clonado) y en Colab / Posit Cloud:
#  si el archivo no está en disco, se lee directamente desde GitHub.
# =============================================================================

cargar <- function(nombre, ...) {
  # Devuelve un data.frame con el CSV  datos/<nombre>.
  # La primera columna se usa como nombres de fila (Python: index_col=0).
  #
  # Conjuntos disponibles:
  # - tema6_ibex_28dias.csv   cotizaciones del ejemplo del Tema 6
  # - cartera_simulada.csv    precios diarios simulados de 5 activos (2 años)
  # - mercado_simulado.csv    índice de mercado + 4 activos (para β y CAPM)
  #
  # Python:  mvdc.datos.cargar("tema6_ibex_28dias.csv")["S"]
  # R:       cargar("tema6_ibex_28dias.csv")$S
  # Si la primera columna son fechas, quedan como nombres de fila en texto:
  # as.Date(rownames(df)) las convierte (Python lo hace con pd.to_datetime).
  url_base <- paste0("https://raw.githubusercontent.com/prof-rodolfo-medina/",
                     "modelizacion-derivados-carteras/main/datos/")
  ruta <- NULL
  base <- normalizePath(getwd(), winslash = "/")
  repeat {                                        # busca datos/<nombre> subiendo carpetas
    candidata <- file.path(base, "datos", nombre)
    if (file.exists(candidata)) { ruta <- candidata; break }
    padre <- dirname(base)
    if (padre == base) break
    base <- padre
  }
  read.csv(if (is.null(ruta)) paste0(url_base, nombre) else ruta,
           row.names = 1, check.names = FALSE, ...)
}
