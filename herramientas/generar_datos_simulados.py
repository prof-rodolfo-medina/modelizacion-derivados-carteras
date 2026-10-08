"""
Genera los CSV de la carpeta ``datos/`` de forma reproducible.

Uso (desde la raíz del repositorio):
    python herramientas/generar_datos_simulados.py

- tema6_ibex_28dias.csv : datos de la Tabla 1 del Tema 6 (copiados del temario).
- cartera_simulada.csv  : 5 activos ficticios, 2 años de días hábiles,
                          movimiento browniano geométrico correlacionado.
- mercado_simulado.csv  : un índice de mercado y 4 activos con betas conocidas
                          (modelo de mercado R_K = α + β R_M + ε).
"""

from pathlib import Path

import numpy as np
import pandas as pd

RAIZ = Path(__file__).resolve().parents[1]
DATOS = RAIZ / "datos"
DATOS.mkdir(exist_ok=True)

# ----------------------------------------------------------------- Tema 6
IBEX_T6 = [24.38, 24.23, 24.26, 24.32, 24.89, 23.55, 23.79, 23.95, 23.75, 23.98,
           24.59, 24.86, 24.80, 24.95, 25.20, 25.07, 25.33, 25.42, 25.32, 25.61,
           25.48, 25.48, 25.56, 25.86, 25.91, 26.08, 25.87, 26.25]
pd.DataFrame({"t": range(len(IBEX_T6)), "S": IBEX_T6}).to_csv(
    DATOS / "tema6_ibex_28dias.csv", index=False)

# ----------------------------------------------------------------- Cartera
rng = np.random.default_rng(2259)
fechas = pd.bdate_range("2024-11-01", periods=504)
activos = ["ALFA", "BETA", "GAMMA", "DELTA", "OMEGA"]
mu = np.array([0.10, 0.07, 0.14, 0.05, 0.12])        # anual
sig = np.array([0.25, 0.18, 0.35, 0.12, 0.28])       # anual
corr = np.array([[1.00, 0.45, 0.30, 0.10, 0.35],
                 [0.45, 1.00, 0.25, 0.20, 0.30],
                 [0.30, 0.25, 1.00, -0.05, 0.40],
                 [0.10, 0.20, -0.05, 1.00, 0.05],
                 [0.35, 0.30, 0.40, 0.05, 1.00]])
dt = 1 / 252
L = np.linalg.cholesky(corr)
Z = rng.standard_normal((len(fechas) - 1, len(activos))) @ L.T
logret = (mu - 0.5 * sig**2) * dt + sig * np.sqrt(dt) * Z
S0 = np.array([25.0, 48.0, 12.5, 80.0, 33.0])
precios = S0 * np.exp(np.vstack([np.zeros(len(activos)), np.cumsum(logret, axis=0)]))
pd.DataFrame(precios.round(2), index=fechas.strftime("%Y-%m-%d"), columns=activos).rename_axis(
    "fecha").to_csv(DATOS / "cartera_simulada.csv")

# ----------------------------------------------------------------- Mercado
rng = np.random.default_rng(1010)
rm = 0.08 * dt + 0.18 * np.sqrt(dt) * rng.standard_normal(len(fechas) - 1)
betas = {"AK1": 0.6, "AK2": 1.0, "AK3": 1.4, "AK4": -0.3}
cols = {"MERCADO": rm}
for k, b in betas.items():
    cols[k] = 0.00005 + b * rm + 0.012 * rng.standard_normal(len(rm))
R = pd.DataFrame(cols)
niveles = 100 * np.exp(np.vstack([np.zeros(R.shape[1]), np.cumsum(R.values, axis=0)]))
pd.DataFrame(niveles.round(3), index=fechas.strftime("%Y-%m-%d"), columns=R.columns).rename_axis(
    "fecha").to_csv(DATOS / "mercado_simulado.csv")

print("Datos generados en", DATOS)
