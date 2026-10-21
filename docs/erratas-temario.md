# Notas y erratas detectadas en el temario

Al reproducir con código los ejemplos de las *Ideas clave* se detectaron las siguientes discrepancias. 
Todas están verificadas en [`tests/test_temario.py`](../tests/test_temario.py) o en los cuadernos de cada sesión. 
Si encuentras otra, coméntala en el foro «Pregúntale a tu profesor» del aula virtual o en la sesión síncrona.

| Tema | Ubicación | En los apuntes | Valor correcto / comentario |
|---|---|---|---|
| 1 | Ejercicio 2, criterio de clasificación bajo la Tabla 7 | ITM si $S_t-K<0$, OTM si $S_t-K>0$ | Para una **call** es al revés: ITM si $S_t>K$, OTM si $S_t<K$. La tabla de la solución sí es correcta. |
| 1 | Tabla 5 | OTM = *on the money* | OTM = *out of the money*. |
| 1 | Ejemplo 7 (apalancamiento) | Beneficio de 2500 € y rendimiento del 500 % | 2500 € es el **pago** de las 250 calls; descontando la prima (500 €), el beneficio neto es 2000 € (**+400 %**). |
| 3 | Sección 3.3, cobertura delta con prima 6.25 | Deuda final 2 493 750 y ganancia 6 250 | Se redondeó $e^{0.048}\approx 1.05$. Con el factor exacto: deuda 2 491 780.31 y ganancia **8 219.69** en ambos escenarios (lo esencial —que coincidan— se mantiene). |
| 3 | Ejercicio 2 | $2\,383\,000\,e^{0.048}=2\,500\,000$ | Mismo redondeo; con la prima justa 6.171655 la ganancia es exactamente 0. |
| 4 | Sección 4.3, fórmula general de la call y de la put | $(1-q^*)^{n-j}(q^*)^j$ junto a $u^{n-j}d^jS_0$ | Exponentes intercambiados: con $j$ = número de bajadas debe ser $(q^*)^{n-j}(1-q^*)^j$. Con la fórmula impresa saldrían 0.80 (call) y 14.02 (put) en lugar de 11.87 y 1.601; el ejemplo resuelto (expresión (1)) sí es correcto. |
| 4 | Sección 4.3, último paso de la inducción hacia atrás | $e^{-0.05}(0.7564\cdot 15.85+0.2436\cdot 2.05)$ | El nodo inferior en $t=1$ vale **2.02**; con 2.05 saldría 11.88. La prima 11.87 es correcta. |
| 6 | Tabla 1 y texto | Fechas de julio–agosto 2019 que incluyen fines de semana; el texto habla de 25/08–21/09 | Las fechas no son coherentes, pero los **precios** sí reproducen todos los resultados (μ, σ, ECM, EPAM). En el repo se usa el índice $t=0,\dots,27$. |
| 7 | Ejemplo 1 | $e^{-0.05\cdot 1.646}$ | El vencimiento es $T=1.6$; con 1.6 se obtiene $C=8.3164$ (con 1.646 saldría 8.566). |
| 7 | Cuaderno, ejercicio 6 ($S_0=K=40$, $T=2$) | $d_1=-0.5374$ | $d_1=+0.5374$, $d_2=-0.3111$ (precios $C$ y $P$ correctos). |
| 7 | Cuaderno, ejercicio 3 | $d_1=-0.44$, $d_2=-0.69$ | Más precisamente $d_1=-0.4443$, $d_2=-0.6943$; precios correctos. |
| 9 | Ejemplo 1, conclusión | «rendimiento del 19.33 % y riesgo del 0.038 %» | Rendimiento **19.99 %**. El 0.038 % es la **varianza** $\sigma^2=0.0003766$; la desviación típica es $\sigma=1.94\,\%$. |
| 10 | Ejemplo 2, activo $a_5$ ($\beta=-0.60$) | $\mu_5=-6.9\,\%$ | $0.09\cdot(-0.6)+0.03=$ **−2.4 %**. |
| 10 | Ejemplo 2, enunciado | «riesgo de la Cartera del Mercado establecido en el 12 %» | El 12 % se usa como **rendimiento esperado** $\mu_M$, no como riesgo. |
| — | Actividad 2, tabla de criterios | Encabezado «Análisis de una estrategia sintética con opciones» | Copiado de la Actividad 1; corresponde a «Construcción de una cartera de mínimo riesgo». |
| — | Actividad 2, nombre de archivo | `Grupo.apellido1 nombre1.extensión` | Difiere del de la Actividad 1 (`apellido1 nombre1`). Confirmar en el aula si la Actividad 2 es grupal. |
