# =============================================================================
#  Carga las funciones del curso en R (equivalente a  `import mvdc`  en Python).
#
#  - Si trabajas con el repositorio clonado, usa los archivos de la carpeta r/mvdc/.
#  - Si no lo encuentra (por ejemplo, en Google Colab o Posit Cloud), los descarga
#    directamente de GitHub.
#
#  Uso:   cargar_mvdc()            # carga todos los módulos disponibles
# =============================================================================

cargar_mvdc <- function(modulos = c("payoffs.R", "binomial.R", "datos.R")) {
  url_base <- paste0("https://raw.githubusercontent.com/prof-rodolfo-medina/",
                     "modelizacion-derivados-carteras/main/r/mvdc/")

  # Busca la carpeta r/mvdc subiendo desde el directorio de trabajo
  # (Python: for base in [Path.cwd(), *Path.cwd().parents])
  carpeta <- NULL
  base <- normalizePath(getwd(), winslash = "/")
  repeat {
    candidata <- file.path(base, "r", "mvdc")
    if (file.exists(file.path(candidata, "payoffs.R"))) { carpeta <- candidata; break }
    padre <- dirname(base)
    if (padre == base) break
    base <- padre
  }

  for (m in modulos) {
    origen <- if (is.null(carpeta)) paste0(url_base, m) else file.path(carpeta, m)
    source(origen)
  }
  message("mvdc (R) cargado desde: ", if (is.null(carpeta)) "GitHub" else carpeta)
  invisible(carpeta)
}
