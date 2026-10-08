"""
mvdc — Modelización y Valoración de Derivados y Carteras en Finanzas
=====================================================================

Biblioteca docente de la asignatura (Maestría en Ciencias Computacionales y
Matemáticas Aplicadas, UNIR). Cada módulo corresponde a un bloque del temario:

- ``payoffs``       Temas 1-2: pagos y beneficios/pérdidas de opciones, futuros
                    y estrategias sintéticas.
- ``binomial``      Temas 3-4: árboles binomiales mono y multiperiodo,
                    cobertura delta y calibración de Hull-White.
- ``lognormal``     Temas 5-6: movimiento browniano, modelo log-normal,
                    estimación de parámetros (MME, MMV, MMNP) y predicción.
- ``black_scholes`` Tema 7: fórmula de Black-Scholes y paridad put-call.
- ``portfolio``     Temas 8-10: Lagrange, cartera de mínimo riesgo,
                    frontera eficiente de Markowitz, CML/CAPM y SML.
- ``datos``         Carga de los CSV de la carpeta ``datos/`` (local o Colab).

La notación sigue la de los apuntes de la asignatura: K = precio de ejercicio,
C y P = primas de call y put, S_T = subyacente a vencimiento, etc.
"""

from . import payoffs, binomial, lognormal, black_scholes, portfolio, datos

__all__ = ["payoffs", "binomial", "lognormal", "black_scholes", "portfolio", "datos"]
__version__ = "2026.11"
