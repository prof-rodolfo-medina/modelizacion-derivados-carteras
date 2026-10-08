"""
Descarga cotizaciones reales de empresas del IBEX-35 con ``yfinance``
(opcional; útil para la Actividad 2).

Instalación:  pip install yfinance
Uso:
    python herramientas/descargar_ibex.py SAN.MC ITX.MC IBE.MC --inicio 2024-01-01
    python herramientas/descargar_ibex.py --lista      # muestra tickers sugeridos

Guarda los precios de cierre ajustados en ``datos/ibex_<tickers>.csv``.
Recuerda: si usas datos importados en una actividad, debes adjuntar el CSV
en tu entrega para que el código pueda verificarse.
"""

import argparse
from pathlib import Path

SUGERIDOS = {
    "SAN.MC": "Banco Santander", "BBVA.MC": "BBVA", "ITX.MC": "Inditex",
    "IBE.MC": "Iberdrola", "TEF.MC": "Telefónica", "REP.MC": "Repsol",
    "FER.MC": "Ferrovial", "AENA.MC": "Aena", "CABK.MC": "CaixaBank",
    "AMS.MC": "Amadeus", "ELE.MC": "Endesa", "GRF.MC": "Grifols",
}


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("tickers", nargs="*")
    p.add_argument("--inicio", default="2024-01-01")
    p.add_argument("--fin", default=None)
    p.add_argument("--lista", action="store_true")
    a = p.parse_args()

    if a.lista or not a.tickers:
        for t, n in SUGERIDOS.items():
            print(f"{t:10s} {n}")
        return

    import yfinance as yf

    df = yf.download(a.tickers, start=a.inicio, end=a.fin, auto_adjust=True, progress=False)["Close"]
    if hasattr(df, "to_frame") and df.ndim == 1:
        df = df.to_frame(a.tickers[0])
    df = df.dropna(how="any").round(4)
    df.index.name = "fecha"
    out = Path(__file__).resolve().parents[1] / "datos" / f"ibex_{'_'.join(t.split('.')[0] for t in a.tickers)}.csv"
    df.to_csv(out)
    print(f"{len(df)} filas guardadas en {out}")


if __name__ == "__main__":
    main()
