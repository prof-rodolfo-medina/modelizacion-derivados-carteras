"""
Pruebas de regresión: cada test reproduce un ejemplo numérico de los apuntes
de la asignatura. Si alguien modifica la biblioteca y rompe un resultado del
temario, la integración continua (GitHub Actions) lo detecta.

Ejecutar:  pytest -q
"""

import numpy as np
import pytest

from mvdc import binomial as b
from mvdc import black_scholes as bs
from mvdc import lognormal as ln
from mvdc import payoffs as po
from mvdc import portfolio as pf


# --------------------------------------------------------------- Temas 1-2
def test_bp_basicos():
    ST = np.array([80.0, 100.0, 120.0])
    assert np.allclose(po.long_call(ST, 100, 5), [-5, -5, 15])
    assert np.allclose(po.long_put(ST, 100, 4), [16, -4, -4])
    assert np.allclose(po.short_call(ST, 100, 5) + po.long_call(ST, 100, 5), 0)


def test_tema1_ejercicio2_valor_intrinseco_extrinseco():
    # Tabla 7 del Tema 1 (S_t = 100)
    esperado = {90: ("ITM", 10, 2), 95: ("ITM", 5, 5), 100: ("ATM", 0, 8),
                105: ("OTM", 0, 6), 110: ("OTM", 0, 4)}
    primas = {90: 12, 95: 10, 100: 8, 105: 6, 110: 4}
    for K, (clase, vi, ve) in esperado.items():
        assert po.moneyness(100, K) == clase
        assert po.intrinsic_value(100, K) == vi
        assert po.extrinsic_value(primas[K], 100, K) == ve


@pytest.mark.parametrize("ST", np.linspace(1, 200, 25))
def test_tema2_relaciones_sinteticas(ST):
    K, C, P = 100, 7, 4
    # Futuro + (-Call) = -Put  (en pay-off, sin primas)
    assert po.long_future(ST, K) - po.call_payoff(ST, K) == pytest.approx(-po.put_payoff(ST, K))
    # Futuro + Put = Call
    assert po.long_future(ST, K) + po.put_payoff(ST, K) == pytest.approx(po.call_payoff(ST, K))
    # Opción de compra cubierta = -(B/P) put larga cuando C = P (forma de la Figura 2)
    cubierta = po.strategy(ST, [{"tipo": "future", "posicion": 1, "K": K},
                                {"tipo": "call", "posicion": -1, "K": K, "prima": C}])
    assert cubierta == pytest.approx(min(ST - K + C, C))


def test_breakeven_straddle_generico():
    ST = np.linspace(0, 200, 2001)
    bp = po.strategy(ST, [{"tipo": "call", "posicion": 1, "K": 50, "prima": 2},
                          {"tipo": "put", "posicion": 1, "K": 50, "prima": 3}])
    assert np.allclose(po.breakeven_points(ST, bp), [45, 55])


# --------------------------------------------------------------- Temas 3-4
def test_tema3_monoperiodo_metodos_I_y_II():
    r = b.one_period_price(S0=100, Su=120, Sd=90, K=105, r=0.04879)
    assert r["prima_metodo_I"] == pytest.approx(7.14, abs=5e-3)
    assert r["prima_metodo_II"] == pytest.approx(r["prima_metodo_I"])
    assert r["q"] == pytest.approx(0.5, abs=1e-5)


def test_tema3_cobertura_delta():
    r = b.one_period_price(60, 80, 50, 65, 0.048)
    assert r["delta"] == 0.5
    assert r["prima_metodo_I"] == pytest.approx(6.1717, abs=1e-4)
    # Cobrando la prima justa no hay ganancia ni pérdida en ningún escenario
    res = b.delta_hedge_pnl(60, 80, 50, 65, 0.048, 1, r["prima_metodo_I"], 100_000)
    assert res["ganancia_sube"] == pytest.approx(0, abs=1e-6)
    assert res["ganancia_baja"] == pytest.approx(0, abs=1e-6)
    # Cobrando 6.25 la ganancia es la misma en ambos escenarios
    res = b.delta_hedge_pnl(60, 80, 50, 65, 0.048, 1, 6.25, 100_000)
    assert res["ganancia_sube"] == pytest.approx(res["ganancia_baja"])


def test_tema4_multiperiodo():
    assert b.binomial_price(100, 105, 1.1, 0.9, 0.05, 3) == pytest.approx(11.87, abs=5e-3)
    V, q = b.option_tree(100, 105, 1.1, 0.9, 0.05, 3)
    assert q == pytest.approx(0.7564, abs=1e-4)
    assert V[0, 0] == pytest.approx(b.binomial_price(100, 105, 1.1, 0.9, 0.05, 3))
    assert V[0, 2] == pytest.approx(21.12, abs=1e-2)
    assert b.binomial_price(100, 100, 1.1, 0.9, 0.05, 3, kind="put") == pytest.approx(1.601, abs=1e-3)


def test_tema4_q_fuera_de_rango():
    with pytest.raises(ValueError):
        b.risk_neutral_q(u=1.02, d=0.99, r=0.10)


# --------------------------------------------------------------- Temas 5-6
IBEX_T6 = [24.38, 24.23, 24.26, 24.32, 24.89, 23.55, 23.79, 23.95, 23.75, 23.98,
           24.59, 24.86, 24.80, 24.95, 25.20, 25.07, 25.33, 25.42, 25.32, 25.61,
           25.48, 25.48, 25.56, 25.86, 25.91, 26.08, 25.87, 26.25]


def test_tema6_estimadores():
    mu, s = ln.estimate_mme(IBEX_T6)
    assert (round(mu, 5), round(s, 5)) == (0.00284, 0.01446)
    mu, s = ln.estimate_mmv(IBEX_T6)
    assert (round(mu, 5), round(s, 4)) == (0.00284, 0.0140)
    _, s = ln.estimate_mmnp(IBEX_T6)
    assert round(s, 5) == 0.01419


def test_tema6_errores_validacion():
    tab = ln.fit_and_validate(IBEX_T6)
    assert tab.loc["MME", "ECM"] == pytest.approx(0.531, abs=1e-3)
    assert tab.loc["MMNP", "EPAM_%"] == pytest.approx(1.617, abs=1e-3)


def test_tema5_media_varianza_por_simulacion():
    S0, mu, sigma, T = 100, 0.08, 0.25, 1.0
    _, S = ln.gbm_paths(S0, mu, sigma, T, n_steps=10, n_paths=200_000, seed=1)
    assert S[:, -1].mean() == pytest.approx(ln.lognormal_mean(S0, mu, T), rel=5e-3)
    assert S[:, -1].std() == pytest.approx(ln.lognormal_std(S0, mu, sigma, T), rel=1e-2)


# --------------------------------------------------------------- Tema 7
def test_tema7_ejemplos_1_y_2():
    assert bs.bs_call(74.625, 100, 1.6, 0.05, 0.375) == pytest.approx(8.3164, abs=1e-4)
    assert bs.bs_put(74.625, 100, 1.6, 0.05, 0.375) == pytest.approx(26.0030, abs=1e-4)


@pytest.mark.parametrize("S0,K,T,r,sig,C,P", [
    (80, 70, 3 / 12, 0.05, 0.30, 11.84, 0.9754),
    (60, 66, 2 / 12, 0.06, 0.40, 1.949, 7.292),
    (50, 60, 1.0, 0.04, 0.25, 2.369, 10.016),
    (100, 100, 4 / 12, 0.055, 0.50, 12.3034, 10.4868),
    (120, 130, 6 / 12, 0.059, 0.22, 4.9206, 11.1416),
    (40, 40, 2.0, 0.048, 0.60, 14.4496, 10.7882),
    (12, 10, 4 / 12, 0.045, 0.33, 2.3096, 0.1607),
])
def test_tema7_cuaderno_ejercicios(S0, K, T, r, sig, C, P):
    assert bs.bs_call(S0, K, T, r, sig) == pytest.approx(C, abs=6e-3)
    assert bs.bs_put(S0, K, T, r, sig) == pytest.approx(P, abs=6e-3)
    gap = bs.put_call_parity_gap(bs.bs_call(S0, K, T, r, sig), bs.bs_put(S0, K, T, r, sig), S0, K, T, r)
    assert gap == pytest.approx(0, abs=1e-10)


def test_tema7_convergencia_binomial_y_montecarlo():
    exacto = bs.bs_call(100, 100, 1, 0.05, 0.2)
    assert bs.binomial_to_bs(100, 100, 1, 0.05, 0.2, 2000) == pytest.approx(exacto, abs=2e-3)
    mc, se = bs.mc_price(100, 100, 1, 0.05, 0.2)
    assert abs(mc - exacto) < 4 * se


# --------------------------------------------------------------- Temas 8-10
def test_tema8_lagrange():
    x, lam = pf.lagrange_quadratic(np.diag([2, 1, 3]), [[1, 1, 1], [5, 10, 15]], [14, 150])
    assert np.allclose(x, [2, 8, 4])
    assert np.allclose(lam, [0, 1.6], atol=1e-10)


M9 = [0.3, 0.2, 0.5]
C9 = pf.cov_from_corr([0.15, 0.02, 0.3], [[1, -0.07, 0.02], [-0.07, 1, 0.2], [0.02, 0.2, 1]])


def test_tema9_minimo_riesgo():
    w = pf.min_variance_weights(C9)
    assert np.allclose(w, [0.0262799, 0.982904, -0.00918349], atol=1e-6)
    mu, sigma = pf.portfolio_stats(w, M9, C9)
    assert mu == pytest.approx(0.199873, abs=1e-6)
    assert sigma**2 == pytest.approx(0.0003766, abs=1e-7)


def test_tema9_frontera_contiene_minimo():
    w_min = pf.min_variance_weights(C9)
    mu_min, s_min = pf.portfolio_stats(w_min, M9, C9)
    w = pf.target_return_weights(M9, C9, mu_min)
    assert np.allclose(w, w_min, atol=1e-8)
    sig, _, W = pf.efficient_frontier(M9, C9, np.linspace(0.1, 0.5, 41))
    assert sig.min() >= s_min - 1e-12
    assert np.allclose(W.sum(axis=1), 1)
    assert np.allclose(W @ M9, np.linspace(0.1, 0.5, 41))


def test_tema10_cartera_de_mercado():
    w = pf.tangency_weights(M9, C9, 0.01)
    assert np.allclose(w, [0.0346962, 0.967755, -0.00245103], atol=1e-6)
    mu, s = pf.portfolio_stats(w, M9, C9)
    assert (round(mu, 4), round(s, 4)) == (0.2027, 0.0196)
    # La tangente maximiza el ratio de Sharpe frente a cualquier punto de la frontera
    sr_t = pf.sharpe_ratio(w, M9, C9, 0.01)
    for mu_k in np.linspace(0.15, 0.45, 31):
        wk = pf.target_return_weights(M9, C9, mu_k)
        assert pf.sharpe_ratio(wk, M9, C9, 0.01) <= sr_t + 1e-10


def test_tema10_sml():
    mu = pf.security_market_line([0.65, 1.0, 1.2, -0.2], 0.12, 0.03)
    assert np.allclose(mu, [0.0885, 0.12, 0.138, 0.012])


def test_beta_regresion():
    rng = np.random.default_rng(3)
    rm = rng.normal(0, 0.02, 5000)
    ra = 0.001 + 1.3 * rm + rng.normal(0, 0.005, 5000)
    assert pf.beta(ra, rm) == pytest.approx(1.3, abs=0.03)
