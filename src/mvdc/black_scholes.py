"""
Tema 7 — Fórmula de Black-Scholes para opciones europeas y paridad put-call.

C = S0 N(d1) - K e^{-rT} N(d2)
P = K e^{-rT} N(-d2) - S0 N(-d1)
d1 = [ln(S0/K) + (r + σ²/2) T] / (σ √T),   d2 = d1 - σ √T
"""

from __future__ import annotations

from math import exp, log, sqrt

import numpy as np
from scipy.stats import norm


def d1_d2(S0, K, T, r, sigma):
    d1 = (log(S0 / K) + (r + 0.5 * sigma**2) * T) / (sigma * sqrt(T))
    return d1, d1 - sigma * sqrt(T)


def bs_call(S0, K, T, r, sigma):
    d1, d2 = d1_d2(S0, K, T, r, sigma)
    return S0 * norm.cdf(d1) - K * exp(-r * T) * norm.cdf(d2)


def bs_put(S0, K, T, r, sigma):
    d1, d2 = d1_d2(S0, K, T, r, sigma)
    return K * exp(-r * T) * norm.cdf(-d2) - S0 * norm.cdf(-d1)


def bs_price(S0, K, T, r, sigma, kind="call"):
    return bs_call(S0, K, T, r, sigma) if kind == "call" else bs_put(S0, K, T, r, sigma)


def put_call_parity_gap(C, P, S0, K, T, r, d0=0.0):
    """
    Residuo de la paridad  P - C = K e^{-rT} + d0 - S0  (d0 = dividendo
    actualizado; 0 si no hay). Debe ser ~0 para precios libres de arbitraje.
    """
    return (P - C) - (K * exp(-r * T) + d0 - S0)


def mc_price(S0, K, T, r, sigma, kind="call", n=200_000, seed=0):
    """
    Precio por Monte Carlo bajo la medida neutral al riesgo (μ = r):
    e^{-rT} E[payoff(S_T)]. Útil para comparar con la fórmula cerrada.
    Devuelve (precio, error_estándar).
    """
    rng = np.random.default_rng(seed)
    Z = rng.standard_normal(n)
    ST = S0 * np.exp((r - 0.5 * sigma**2) * T + sigma * sqrt(T) * Z)
    pay = np.maximum(ST - K, 0) if kind == "call" else np.maximum(K - ST, 0)
    disc = exp(-r * T) * pay
    return disc.mean(), disc.std(ddof=1) / sqrt(n)


def binomial_to_bs(S0, K, T, r, sigma, n, kind="call"):
    """
    Árbol CRR (u = e^{σ√Δt}, d = 1/u) con n pasos: converge a Black-Scholes
    cuando n → ∞. Puente entre los Temas 4 y 7.
    """
    from .binomial import binomial_price

    dt = T / n
    u = exp(sigma * sqrt(dt))
    return binomial_price(S0, K, u, 1 / u, r, n, dt, kind)
