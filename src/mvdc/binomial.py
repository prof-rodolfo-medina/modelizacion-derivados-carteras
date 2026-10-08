"""
Temas 3 y 4 — Valoración de opciones europeas con árboles binomiales.

Convenciones (las del temario):
- Interés compuesto continuo: actualizar un periodo multiplica por e^{-r·dt}.
- Probabilidad neutral al riesgo  q* = (e^{r·dt}·S0 - Sd) / (Su - Sd),
  que en un árbol recombinante con factores u, d queda q* = (e^{r·dt} - d)/(u - d).
"""

from __future__ import annotations

from math import comb, exp

import numpy as np

from .payoffs import call_payoff, put_payoff


# ---------------------------------------------------------------------------
# Tema 3 — árbol monoperiodo
# ---------------------------------------------------------------------------
def one_period_price(S0, Su, Sd, K, r, tau=1.0, kind="call"):
    """
    Prima de una opción europea en un árbol monoperiodo.

    Devuelve un dict con la prima por el Método I (cartera acciones+opciones),
    por el Método II (réplica con acciones+bonos), la Delta a* y q*.
    Ambos métodos deben coincidir; se devuelven los dos con fines docentes.
    """
    if not Su > Sd:
        raise ValueError("Se requiere Su > Sd.")
    pay = call_payoff if kind == "call" else put_payoff
    U, D = float(pay(Su, K)), float(pay(Sd, K))
    disc = exp(-r * tau)

    # Método I: b* = -1 (se vende una opción), a* = (U - D)/(Su - Sd)
    a_star = (U - D) / (Su - Sd)
    V_metodo1 = a_star * S0 + (U - a_star * Su) * disc

    # Método II: réplica; b* = (U - a* Su) e^{-r tau} bonos de valor 1
    b_star = (U - a_star * Su) * disc
    q_star = (exp(r * tau) * S0 - Sd) / (Su - Sd)
    V_metodo2 = disc * (q_star * U + (1 - q_star) * D)

    return {
        "U": U, "D": D,
        "delta": a_star,           # a* = ΔV/ΔS (Método I)
        "bonos": b_star,           # b* (Método II)
        "q": q_star,
        "prima_metodo_I": V_metodo1,
        "prima_metodo_II": V_metodo2,
    }


def delta_hedge_pnl(S0, Su, Sd, K, r, tau, premium_charged, n_options=1):
    """
    Resultado del corredor que vende ``n_options`` calls cobrando
    ``premium_charged`` y se cubre comprando a*·n acciones financiadas al tipo
    libre de riesgo (Sección 3.3). Devuelve la ganancia en ambos escenarios:
    deben coincidir (cobertura perfecta).
    """
    res = one_period_price(S0, Su, Sd, K, r, tau, "call")
    a = res["delta"] * n_options
    deuda = (a * S0 - premium_charged * n_options) * exp(r * tau)
    g_up = a * Su - deuda - res["U"] * n_options
    g_down = a * Sd - deuda - res["D"] * n_options
    return {"acciones": a, "deuda_final": deuda, "ganancia_sube": g_up, "ganancia_baja": g_down}


# ---------------------------------------------------------------------------
# Tema 4 — árbol multiperiodo recombinante
# ---------------------------------------------------------------------------
def risk_neutral_q(u, d, r, dt=1.0):
    q = (exp(r * dt) - d) / (u - d)
    if not 0 < q < 1:
        raise ValueError(f"q* = {q:.4f} fuera de (0,1): existe arbitraje con estos u, d, r.")
    return q


def stock_tree(S0, u, d, n):
    """
    Árbol del subyacente como matriz triangular superior (n+1)x(n+1):
    tree[j, t] = S0 · u^(t-j) · d^j  para j <= t  (j = número de bajadas).
    """
    tree = np.full((n + 1, n + 1), np.nan)
    for t in range(n + 1):
        for j in range(t + 1):
            tree[j, t] = S0 * u ** (t - j) * d ** j
    return tree


def option_tree(S0, K, u, d, r, n, dt=1.0, kind="call"):
    """
    Árbol de valores de la opción europea por inducción hacia atrás
    (se resuelve un árbol monoperiodo en cada nodo, de derecha a izquierda).
    Devuelve ``(arbol_opcion, q)``; la prima es ``arbol_opcion[0, 0]``.
    """
    q = risk_neutral_q(u, d, r, dt)
    disc = exp(-r * dt)
    S = stock_tree(S0, u, d, n)
    pay = call_payoff if kind == "call" else put_payoff
    V = np.full_like(S, np.nan)
    V[: n + 1, n] = pay(S[: n + 1, n], K)
    for t in range(n - 1, -1, -1):
        for j in range(t + 1):
            V[j, t] = disc * (q * V[j, t + 1] + (1 - q) * V[j + 1, t + 1])
    return V, q


def binomial_price(S0, K, u, d, r, n, dt=1.0, kind="call"):
    """
    Fórmula cerrada del Tema 4:
    V0 = e^{-r n dt} Σ_j C(n,j) q^{n-j} (1-q)^j · payoff(u^{n-j} d^j S0).
    """
    q = risk_neutral_q(u, d, r, dt)
    pay = call_payoff if kind == "call" else put_payoff
    j = np.arange(n + 1)
    ST = S0 * u ** (n - j) * d ** j
    if n <= 60:  # fórmula literal del temario
        w = np.array([comb(n, k) * q ** (n - k) * (1 - q) ** k for k in j])
    else:        # misma fórmula, evaluada en escala logarítmica para n grande
        from scipy.stats import binom
        w = binom.pmf(j, n, 1 - q)
    return exp(-r * n * dt) * float(np.sum(w * pay(ST, K)))


def print_tree(tree, decimals=2):
    """Impresión legible de un árbol triangular (filas = nº de bajadas)."""
    n = tree.shape[1] - 1
    lines = []
    for j in range(n + 1):
        row = []
        for t in range(n + 1):
            row.append(f"{tree[j, t]:>9.{decimals}f}" if j <= t else " " * 9)
        lines.append("".join(row))
    print("\n".join(lines))


# ---------------------------------------------------------------------------
# Sección 4.4 — Calibración de Hull-White (p = 1/2)
# ---------------------------------------------------------------------------
def hull_white_ud(prices):
    """
    Estima u y d a partir de un histórico {S_0, ..., S_n}:
    U_i = S_i/S_{i-1} - 1,  u = 1 + Ū + s_U,  d = 1 + Ū - s_U
    (s_U con divisor n-1). Devuelve dict con u, d, media y desviación.
    """
    S = np.asarray(prices, dtype=float)
    U = S[1:] / S[:-1] - 1.0
    m, s = U.mean(), U.std(ddof=1)
    return {"u": 1 + m + s, "d": 1 + m - s, "media": m, "desv": s}
