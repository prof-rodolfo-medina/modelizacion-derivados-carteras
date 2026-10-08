"""
Temas 1 y 2 — Pagos (pay-off) y beneficios/pérdidas (B/P) a vencimiento.

Todas las funciones aceptan ``ST`` escalar o ``numpy.ndarray`` y devuelven el
mismo tipo, de modo que pueden graficarse directamente:

>>> import numpy as np
>>> ST = np.linspace(0, 200, 401)
>>> bp = long_call(ST, K=100, C=5)
"""

from __future__ import annotations

import numpy as np


# ---------------------------------------------------------------------------
# Pay-off bruto (sin prima) — Tabla 4 del Tema 1
# ---------------------------------------------------------------------------
def call_payoff(ST, K):
    """Beneficio bruto de una call: (S_T - K)^+ ."""
    return np.maximum(np.asarray(ST, dtype=float) - K, 0.0)


def put_payoff(ST, K):
    """Beneficio bruto de una put: (K - S_T)^+ ."""
    return np.maximum(K - np.asarray(ST, dtype=float), 0.0)


# ---------------------------------------------------------------------------
# Beneficios/pérdidas con prima — expresión (1) del Tema 1
# ---------------------------------------------------------------------------
def long_call(ST, K, C):
    """(B/P)_CL = (S_T - K)^+ - C."""
    return call_payoff(ST, K) - C


def short_call(ST, K, C):
    """(B/P)_CC = C - (S_T - K)^+."""
    return C - call_payoff(ST, K)


def long_put(ST, K, P):
    """(B/P)_PL = (K - S_T)^+ - P."""
    return put_payoff(ST, K) - P


def short_put(ST, K, P):
    """(B/P)_PC = P - (K - S_T)^+."""
    return P - put_payoff(ST, K)


# ---------------------------------------------------------------------------
# Futuros — expresión (1) del Tema 2
# ---------------------------------------------------------------------------
def long_future(ST, K):
    """(B/P)_FL = S_T - K."""
    return np.asarray(ST, dtype=float) - K


def short_future(ST, K):
    """(B/P)_FC = K - S_T."""
    return K - np.asarray(ST, dtype=float)


# ---------------------------------------------------------------------------
# Terminología (Tabla 5 del Tema 1) y valor intrínseco/extrínseco
# ---------------------------------------------------------------------------
def moneyness(St, K, kind="call"):
    """Devuelve 'ITM', 'ATM' u 'OTM' para una call o una put."""
    diff = (St - K) if kind == "call" else (K - St)
    if np.isclose(diff, 0.0):
        return "ATM"
    return "ITM" if diff > 0 else "OTM"


def intrinsic_value(St, K, kind="call"):
    """Valor intrínseco VI (Definición 6 del Tema 1)."""
    return float(call_payoff(St, K) if kind == "call" else put_payoff(St, K))


def extrinsic_value(premium, St, K, kind="call"):
    """Valor extrínseco VE = prima - VI (Definición 7 del Tema 1)."""
    return premium - intrinsic_value(St, K, kind)


# ---------------------------------------------------------------------------
# Estrategias compuestas
# ---------------------------------------------------------------------------
_LEG_FUNCS = {
    ("call", +1): lambda ST, K, prem: long_call(ST, K, prem),
    ("call", -1): lambda ST, K, prem: short_call(ST, K, prem),
    ("put", +1): lambda ST, K, prem: long_put(ST, K, prem),
    ("put", -1): lambda ST, K, prem: short_put(ST, K, prem),
    ("future", +1): lambda ST, K, prem: long_future(ST, K),
    ("future", -1): lambda ST, K, prem: short_future(ST, K),
}


def strategy(ST, legs):
    """
    B/P total de una estrategia formada por varias patas.

    Parameters
    ----------
    ST : array_like
        Precios del subyacente a vencimiento.
    legs : list of dict
        Cada pata es ``{"tipo": "call"|"put"|"future", "posicion": +1|-1,
        "K": float, "prima": float, "cantidad": float (opcional)}``.

    Ejemplo — opción de compra cubierta (Tema 2): futuro largo + call corta

    >>> legs = [{"tipo": "future", "posicion": +1, "K": 100},
    ...         {"tipo": "call", "posicion": -1, "K": 100, "prima": 5}]
    """
    ST = np.asarray(ST, dtype=float)
    total = np.zeros_like(ST)
    for leg in legs:
        f = _LEG_FUNCS[(leg["tipo"], leg["posicion"])]
        total = total + leg.get("cantidad", 1.0) * f(ST, leg["K"], leg.get("prima", 0.0))
    return total


def breakeven_points(ST, values):
    """
    Puntos de equilibrio (B/P = 0) estimados por interpolación lineal
    entre los nodos de la malla ``ST``.
    """
    ST = np.asarray(ST, dtype=float)
    v = np.asarray(values, dtype=float)
    pts = []
    for i in range(len(ST) - 1):
        if v[i] == 0:
            pts.append(ST[i])
        elif v[i] * v[i + 1] < 0:
            pts.append(ST[i] - v[i] * (ST[i + 1] - ST[i]) / (v[i + 1] - v[i]))
    if v[-1] == 0:
        pts.append(ST[-1])
    return np.unique(np.round(pts, 10))


def plot_strategy(ST, values, ax=None, title=None, label="B/P total", components=None,
                  mark_breakeven=True):
    """
    Gráfica estándar de B/P a vencimiento.

    ``components`` es un dict opcional ``{etiqueta: array}`` para dibujar las
    patas individuales con línea discontinua.
    """
    import matplotlib.pyplot as plt

    if ax is None:
        _, ax = plt.subplots(figsize=(8, 4.5))
    if components:
        for lab, comp in components.items():
            ax.plot(ST, comp, "--", lw=1, alpha=0.7, label=lab)
    ax.plot(ST, values, lw=2.2, label=label)
    ax.axhline(0, color="black", lw=0.8)
    if mark_breakeven:
        for be in breakeven_points(ST, values):
            ax.plot(be, 0, "o", color="black")
            ax.annotate(f"{be:.2f}", (be, 0), textcoords="offset points",
                        xytext=(0, 8), ha="center")
    ax.set_xlabel(r"$S_T$")
    ax.set_ylabel("Beneficio / pérdida")
    if title:
        ax.set_title(title)
    ax.grid(alpha=0.3)
    ax.legend()
    return ax
