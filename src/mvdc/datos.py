"""
Carga de los conjuntos de datos del repositorio (carpeta ``datos/``).

Funciona igual en local (repositorio clonado) y en Google Colab: si el archivo
no está en disco, se descarga desde GitHub.
"""

from __future__ import annotations

from pathlib import Path

REPO_RAW = "https://raw.githubusercontent.com/prof-rodolfo-medina/modelizacion-derivados-carteras/main/datos/"


def _buscar_local(nombre: str) -> Path | None:
    aqui = Path(__file__).resolve()
    for base in [Path.cwd(), *Path.cwd().parents, *aqui.parents]:
        cand = base / "datos" / nombre
        if cand.exists():
            return cand
    return None


def cargar(nombre: str, **kwargs):
    """
    Devuelve un ``pandas.DataFrame`` con el CSV ``datos/<nombre>``.

    Conjuntos disponibles:
    - ``tema6_ibex_28dias.csv``   cotizaciones del ejemplo del Tema 6
    - ``cartera_simulada.csv``    precios diarios simulados de 5 activos (2 años)
    - ``mercado_simulado.csv``    índice de mercado + 4 activos (para β y CAPM)
    """
    import pandas as pd

    kwargs.setdefault("index_col", 0)
    ruta = _buscar_local(nombre)
    origen = ruta if ruta is not None else REPO_RAW + nombre
    df = pd.read_csv(origen, **kwargs)
    if not pd.api.types.is_numeric_dtype(df.index):  # solo índices de texto (fechas)
        try:
            df.index = pd.to_datetime(df.index)
        except (ValueError, TypeError):
            pass
    return df
