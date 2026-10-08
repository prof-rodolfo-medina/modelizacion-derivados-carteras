"""
Temas 8, 9 y 10 — Carteras de mínimo riesgo, Markowitz y CAPM.

Notación (vectores fila, como en el temario):
  m  = vector de rendimientos esperados (1 x n)
  C  = matriz de varianzas-covarianzas (n x n)
  1  = vector de unos
  w  = vector de pesos, con 1·wᵀ = 1 (se admiten ventas en corto: w_i < 0)
"""

from __future__ import annotations

import numpy as np


# ---------------------------------------------------------------------------
# Datos: de precios a rendimientos y estadísticos
# ---------------------------------------------------------------------------
def log_returns(prices):
    """
    Log-retornos R = ln(S_t / S_{t-1}) (Tema 8). Acepta un DataFrame de
    pandas (columnas = activos) o un array 2D (filas = fechas).
    """
    try:
        import pandas as pd
        if isinstance(prices, pd.DataFrame):
            return np.log(prices / prices.shift(1)).dropna()
    except ImportError:  # pragma: no cover
        pass
    P = np.asarray(prices, dtype=float)
    return np.log(P[1:] / P[:-1])


def mean_cov(returns, periods_per_year=1):
    """
    Devuelve (m, C) a partir de una matriz de rendimientos.
    ``periods_per_year`` permite anualizar (252 para datos diarios).
    """
    R = np.asarray(returns, dtype=float)
    m = R.mean(axis=0) * periods_per_year
    C = np.cov(R, rowvar=False, ddof=1) * periods_per_year
    return m, C


def cov_from_corr(sigmas, corr):
    """C_ij = ρ_ij σ_i σ_j (Ejemplo 1 del Tema 9)."""
    s = np.asarray(sigmas, dtype=float)
    return np.asarray(corr, dtype=float) * np.outer(s, s)


def portfolio_stats(w, m, C):
    """Rendimiento esperado μ = m·wᵀ y riesgo (desviación típica) σ = sqrt(w C wᵀ)."""
    w = np.asarray(w, dtype=float)
    return float(np.asarray(m) @ w), float(np.sqrt(w @ C @ w))


# ---------------------------------------------------------------------------
# Tema 8 — Lagrange para formas cuadráticas con restricciones lineales
# ---------------------------------------------------------------------------
def lagrange_quadratic(A, B, b):
    """
    Resuelve  mín x A xᵀ  s.a.  B xᵀ = b  (Ejemplo 1 del Tema 8).
    λ* = 2 bᵀ (B A⁻¹ Bᵀ)⁻¹,   x* = ½ λ* B A⁻¹.
    Los multiplicadores miden la sensibilidad del riesgo mínimo a cada
    término independiente: ∂R*/∂b_i = λ*_i.
    """
    A = np.asarray(A, float)
    B = np.atleast_2d(np.asarray(B, float))
    b = np.asarray(b, float)
    Ainv = np.linalg.inv(A)
    lam = 2 * b @ np.linalg.inv(B @ Ainv @ B.T)
    x = 0.5 * lam @ B @ Ainv
    return x, lam


# ---------------------------------------------------------------------------
# Tema 9 — Cartera pura en riesgo
# ---------------------------------------------------------------------------
def min_variance_weights(C):
    """Teorema 2 (Tema 9):  w* = 1 C⁻¹ / (1 C⁻¹ 1ᵀ)."""
    C = np.asarray(C, float)
    ones = np.ones(C.shape[0])
    x = np.linalg.solve(C, ones)  # C⁻¹ 1ᵀ (C es simétrica)
    return x / x.sum()


def target_return_weights(m, C, mu):
    """
    Teorema 3 (Tema 9): pesos de mínimo riesgo con rendimiento esperado μ.
    Se usa la forma matricial  w* = bᵀ (B C⁻¹ Bᵀ)⁻¹ B C⁻¹,  B = [m; 1], b = (μ, 1).
    """
    B = np.vstack([np.asarray(m, float), np.ones(len(m))])
    w, _ = lagrange_quadratic(C, B, [mu, 1.0])
    return w


def efficient_frontier(m, C, mus):
    """
    Frontera de mínima varianza (curva de Markowitz) para una malla de μ.
    Devuelve (sigmas, mus, pesos). La rama eficiente es μ >= μ_mín.
    """
    W = np.array([target_return_weights(m, C, mu) for mu in mus])
    sig = np.sqrt(np.einsum("ij,jk,ik->i", W, C, W))
    return sig, np.asarray(mus), W


def random_portfolios(m, C, n=5000, seed=0, allow_short=False):
    """Carteras aleatorias para ilustrar la «bala de Markowitz»."""
    rng = np.random.default_rng(seed)
    k = len(m)
    W = rng.dirichlet(np.ones(k), n) if not allow_short else rng.normal(size=(n, k))
    W = W / W.sum(axis=1, keepdims=True)
    mus = W @ np.asarray(m)
    sig = np.sqrt(np.einsum("ij,jk,ik->i", W, C, W))
    return sig, mus, W


# ---------------------------------------------------------------------------
# Tema 10 — Cartera mixta, CML y CAPM
# ---------------------------------------------------------------------------
def tangency_weights(m, C, mu_rf):
    """
    Teorema 1 (Tema 10), Cartera del Mercado Capital:
    w* = (m - μ_rf 1) C⁻¹ / ((m - μ_rf 1) C⁻¹ 1ᵀ).
    """
    excess = np.asarray(m, float) - mu_rf
    x = np.linalg.solve(np.asarray(C, float), excess)
    return x / x.sum()


def sharpe_ratio(w, m, C, mu_rf):
    mu, sigma = portfolio_stats(w, m, C)
    return (mu - mu_rf) / sigma


def capital_market_line(sigma, mu_rf, mu_M, sigma_M):
    """CML: μ = μ_rf + (μ_M - μ_rf)/σ_M · σ."""
    return mu_rf + (mu_M - mu_rf) / sigma_M * np.asarray(sigma, float)


def mixed_portfolio(w_risky_total, mu_rf, mu_der, sigma_der):
    """Ecuación (1) del Tema 10: punto (σ, μ) de una cartera mixta."""
    return w_risky_total * sigma_der, mu_rf + w_risky_total * (mu_der - mu_rf)


def beta(asset_returns, market_returns):
    """β_K = Cov(R_K, R_M) / σ²_M (recta de regresión del Tema 10)."""
    a = np.asarray(asset_returns, float)
    mk = np.asarray(market_returns, float)
    return float(np.cov(a, mk, ddof=1)[0, 1] / np.var(mk, ddof=1))


def security_market_line(beta_k, mu_M, mu_rf):
    """SML: μ_K = μ_rf + β_K (μ_M - μ_rf)."""
    return mu_rf + np.asarray(beta_k, float) * (mu_M - mu_rf)


# ---------------------------------------------------------------------------
# Gráfica estándar
# ---------------------------------------------------------------------------
def plot_frontier(m, C, mu_range=None, n_points=200, ax=None, mu_rf=None,
                  asset_labels=None, cloud=True):
    """
    Dibuja: carteras aleatorias (sin cortos), frontera de mínima varianza,
    rama eficiente, cartera de mínimo riesgo, activos individuales y, si se
    da ``mu_rf``, la CML y la cartera tangente.
    """
    import matplotlib.pyplot as plt

    m = np.asarray(m, float)
    if ax is None:
        _, ax = plt.subplots(figsize=(8, 5.5))
    w_min = min_variance_weights(C)
    mu_min, s_min = portfolio_stats(w_min, m, C)
    if mu_range is None:
        span = m.max() - m.min()
        mu_range = (m.min() - 0.5 * span, m.max() + 0.5 * span)
    mus = np.linspace(*mu_range, n_points)
    sig, mus, _ = efficient_frontier(m, C, mus)

    if cloud:
        s_r, m_r, _ = random_portfolios(m, C, 4000)
        ax.scatter(s_r, m_r, s=4, alpha=0.25, color="grey", label="Carteras aleatorias (sin cortos)")
    ax.plot(sig[mus < mu_min], mus[mus < mu_min], "--", color="C0", lw=1.2)
    ax.plot(sig[mus >= mu_min], mus[mus >= mu_min], color="C0", lw=2.4, label="Frontera eficiente")
    ax.plot(s_min, mu_min, "*", ms=16, color="C3",
            label=f"Mínimo riesgo (σ={s_min:.4f}, μ={mu_min:.4f})")
    sd = np.sqrt(np.diag(C))
    ax.scatter(sd, m, color="black", zorder=5)
    labels = asset_labels or [f"a{i+1}" for i in range(len(m))]
    for x, y, lab in zip(sd, m, labels):
        ax.annotate(lab, (x, y), textcoords="offset points", xytext=(6, 4))
    if mu_rf is not None:
        wt = tangency_weights(m, C, mu_rf)
        mu_t, s_t = portfolio_stats(wt, m, C)
        slope = (mu_t - mu_rf) / s_t
        x_max = min(sig.max(), max(s_t * 1.6, (mus.max() - mu_rf) / slope))
        xs = np.linspace(0, x_max, 50)
        ax.plot(xs, capital_market_line(xs, mu_rf, mu_t, s_t), color="C2", label="CML")
        ax.plot(s_t, mu_t, "D", color="C2", ms=9, label="Cartera de mercado")
    ax.set_xlabel(r"Riesgo $\sigma$")
    ax.set_ylabel(r"Rendimiento esperado $\mu$")
    ax.grid(alpha=0.3)
    ax.legend(loc="best", fontsize=9)
    return ax
