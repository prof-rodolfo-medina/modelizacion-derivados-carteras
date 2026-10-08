"""
Temas 5 y 6 — Movimiento browniano, modelo log-normal, estimación y predicción.

Modelo:  dS = μ S dt + σ S dW,   S(0) = S0
Solución: S(t) = S0 · exp((μ - σ²/2) t + σ W(t))
Media:    E[S(t)] = S0 e^{μ t}
Varianza: V[S(t)] = S0² e^{2 μ t} (e^{σ² t} - 1)
"""

from __future__ import annotations

import numpy as np


# ---------------------------------------------------------------------------
# Tema 5 — simulación
# ---------------------------------------------------------------------------
def wiener_paths(T=1.0, n_steps=250, n_paths=100, seed=None):
    """
    Trayectorias del proceso de Wiener por recurrencia
    W(t_i) = W(t_{i-1}) + sqrt(Δt)·Z,  Z ~ N(0,1).
    Devuelve ``(t, W)`` con W de forma (n_paths, n_steps+1).
    """
    rng = np.random.default_rng(seed)
    dt = T / n_steps
    dW = np.sqrt(dt) * rng.standard_normal((n_paths, n_steps))
    W = np.concatenate([np.zeros((n_paths, 1)), np.cumsum(dW, axis=1)], axis=1)
    t = np.linspace(0.0, T, n_steps + 1)
    return t, W


def gbm_paths(S0, mu, sigma, T=1.0, n_steps=250, n_paths=100, seed=None):
    """Trayectorias exactas del movimiento browniano geométrico (solución de Itô)."""
    t, W = wiener_paths(T, n_steps, n_paths, seed)
    S = S0 * np.exp((mu - 0.5 * sigma**2) * t + sigma * W)
    return t, S


def euler_maruyama(S0, mu, sigma, T=1.0, n_steps=250, n_paths=100, seed=None):
    """Aproximación de Euler-Maruyama: S_{i+1} = S_i + μ S_i Δt + σ S_i ΔW_i."""
    rng = np.random.default_rng(seed)
    dt = T / n_steps
    S = np.empty((n_paths, n_steps + 1))
    S[:, 0] = S0
    for i in range(n_steps):
        dW = np.sqrt(dt) * rng.standard_normal(n_paths)
        S[:, i + 1] = S[:, i] * (1 + mu * dt + sigma * dW)
    return np.linspace(0.0, T, n_steps + 1), S


def lognormal_mean(S0, mu, t):
    return S0 * np.exp(mu * np.asarray(t, dtype=float))


def lognormal_std(S0, mu, sigma, t):
    t = np.asarray(t, dtype=float)
    return S0 * np.exp(mu * t) * np.sqrt(np.exp(sigma**2 * t) - 1.0)


# ---------------------------------------------------------------------------
# Tema 6 — estimación de parámetros
# ---------------------------------------------------------------------------
def estimate_mme(prices, dt=1.0):
    """
    Método de momentos estadísticos, ecuación (1) del Tema 6.
    U_i = ln(S_i/S_{i-1});  μ = (Ū + s²/2)/Δt;  σ = s/√Δt.
    """
    S = np.asarray(prices, dtype=float)
    U = np.log(S[1:] / S[:-1])
    m, s = U.mean(), U.std(ddof=1)
    return (m + s**2 / 2) / dt, s / np.sqrt(dt)


def estimate_mmv(prices, dt=1.0):
    """
    Máxima verosimilitud (vía Euler-Maruyama), ecuación (3) del Tema 6.
    U_i = S_i/S_{i-1} - 1;  μ = Ū/Δt;  σ = sqrt((n-1)/(n Δt)) · s.
    """
    S = np.asarray(prices, dtype=float)
    U = S[1:] / S[:-1] - 1.0
    n = len(U)
    return U.mean() / dt, np.sqrt((n - 1) / (n * dt)) * U.std(ddof=1)


def estimate_mmnp(prices, dt=1.0):
    """Método de momentos no paramétrico, ecuación (6) del Tema 6."""
    S = np.asarray(prices, dtype=float)
    dS = S[1:] - S[:-1]
    Sp = S[:-1]
    mu = dS.sum() / (dt * Sp.sum())
    sigma = np.sqrt((dS**2).sum() / (dt * (Sp**2).sum()))
    return mu, sigma


ESTIMATORS = {"MME": estimate_mme, "MMV": estimate_mmv, "MMNP": estimate_mmnp}


# ---------------------------------------------------------------------------
# Validación y predicción
# ---------------------------------------------------------------------------
def rmse(data, model):
    """Error cuadrático medio (raíz), ecuación (7)."""
    d, m = np.asarray(data, float), np.asarray(model, float)
    return float(np.sqrt(np.mean((d - m) ** 2)))


def mape(data, model):
    """Error porcentual absoluto medio (%), ecuación (8)."""
    d, m = np.asarray(data, float), np.asarray(model, float)
    return float(100 * np.mean(np.abs((d - m) / d)))


def confidence_band(S0, mu, sigma, t, z=1.96):
    """Banda μ_S(t) ± z·σ_S(t) usada en el Tema 6 para la predicción al 95 %."""
    m = lognormal_mean(S0, mu, t)
    s = lognormal_std(S0, mu, sigma, t)
    return m, m - z * s, m + z * s


def fit_and_validate(prices, dt=1.0, methods=("MME", "MMV", "MMNP")):
    """
    Ajusta los estimadores pedidos, evalúa la media del modelo en t = 1..n
    (t_i = i·Δt, S0 = primer dato) y devuelve una tabla (pandas.DataFrame)
    con μ, σ, ECM y EPAM.
    """
    import pandas as pd

    S = np.asarray(prices, dtype=float)
    t = np.arange(len(S)) * dt
    rows = []
    for name in methods:
        mu, sigma = ESTIMATORS[name](S, dt)
        fitted = lognormal_mean(S[0], mu, t)
        rows.append({"método": name, "mu": mu, "sigma": sigma,
                     "ECM": rmse(S[1:], fitted[1:]), "EPAM_%": mape(S[1:], fitted[1:])})
    return pd.DataFrame(rows).set_index("método")
