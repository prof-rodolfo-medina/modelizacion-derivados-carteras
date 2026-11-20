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
| 5 | Sección 5.3, Condición 2 (incrementos estacionarios) y Conclusión 2 | $W(s)-W(t)=W(s+h)-W(t+h)$; $W(t-s)=W(t)-W(s)$ | La igualdad es **en distribución**: $W(t+h)-W(s+h)\overset{d}{=}W(t)-W(s)$. Los incrementos no son la misma variable aleatoria; tienen la misma ley $N(0,|t-s|)$. |
| 5 | Sección 5.3, demostración de la Proposición 1 | Los dos casos empiezan «si $t_1=t_m$» | El segundo caso es «si $t_2=t_m$» (es decir, $t_2<t_1$); el resultado $\operatorname{Cov}=\min\{t_1,t_2\}$ es correcto. |
| 6 | Tabla 1 y texto | Fechas de julio–agosto 2019 que incluyen fines de semana; el texto habla de 25/08–21/09 | Las fechas no son coherentes, pero los **precios** sí reproducen todos los resultados (μ, σ, ECM, EPAM). En el repo se usa el índice $t=0,\dots,27$. |
| 6 | Sección 6.6, estimaciones del MMNP | $\mu_{\text{MMNP}}=0.00284$ | Con la fórmula (6) se obtiene $\mu_{\text{MMNP}}=$ **0.00278** ($\sigma_{\text{MMNP}}=0.01419$ es correcto). Los errores del tema para el MMNP (ECM 0.518, EPAM 1.617 %) y su columna de la Tabla 2 corresponden a 0.00278. |
| 6 | Sección 6.6, Tabla 2 (predicción a 5 días) | Filas rotuladas $t=27,\dots,31$ | Las cifras son las de $t=28,\dots,32$, los 5 días posteriores al último dato ($t=27$); p. ej., MME: $\mu_S(28)=26.40$, mientras que $\mu_S(27)=26.32$. El cuaderno de la Clase 5 predice $t=28,\dots,32$. |
| 7 | Ejemplo 1 | $e^{-0.05\cdot 1.646}$ | El vencimiento es $T=1.6$; con 1.6 se obtiene $C=8.3164$ (con 1.646 saldría 8.566). |
| 7 | Cuaderno, ejercicio 6 ($S_0=K=40$, $T=2$) | $d_1=-0.5374$ | $d_1=+0.5374$, $d_2=-0.3111$ (precios $C$ y $P$ correctos). |
| 7 | Cuaderno, ejercicio 3 | $d_1=-0.44$, $d_2=-0.69$ | Más precisamente $d_1=-0.4443$, $d_2=-0.6943$; precios correctos. |
| 8 | Ejemplo 1(b), cálculo de $BA^{-1}B^\top$ | Elemento $(1,1)$ de $BA^{-1}B^\top$ igual a $5/6$; inversa con filas $(-5/4,\ 7/60)$ y $(7/60,\ -1/180)$ | El elemento $(1,1)$ es $\tfrac12+1+\tfrac13=$ **11/6**, y la inversa tiene filas $(5,\ -7/15)$ y $(-7/15,\ 11/225)$ (la impresa no es definida positiva: determinante $-150$). Como $\lambda_1^*=0$, ese elemento no influye: $\lambda^*=(0,\,8/5)$ y $x^*=(2,8,4)$ son correctos. |
| 8 | Ejemplo 1(c), interpretación de $\lambda^*$ | «No hay una variación importante en el riesgo por invertir una unidad más»; con $\mu=145$ el riesgo «disminuye aproximadamente en 8» | $\lambda^*\Delta b$ es solo la variación de **primer orden**. El riesgo mínimo real pasa de 120 a **125** (+4.2 %) tanto con $M=15$ como con $M=13$ ($M=14$ es el presupuesto de menor riesgo para $\mu=150$), y a **113.22** ($-6.78$) con $\mu=145$. La conclusión (menos rentabilidad, menos riesgo) se mantiene. |
| 9 | §9.4, fórmulas de $\lambda_1^*$ y $\lambda_2^*$ (regla de Cramer) | El determinante del denominador tiene $\mathbf 1C^{-1}\mathbf 1^\top$ en la esquina superior derecha (fila 1: $mC^{-1}m^\top$, $\mathbf 1C^{-1}\mathbf 1^\top$) | La esquina superior derecha es $\mathbf 1C^{-1}m^\top$, como en el Teorema 3 (que está bien). Con el Ejemplo 1 el determinante correcto vale 3830.2; el impreso, $-1.12\cdot 10^6$, y con él los pesos sumarían $-0.0034$. |
| 9 | Ejemplo 1, conclusión | «rendimiento del 19.33 % y riesgo del 0.038 %» | Rendimiento **19.99 %**. El 0.038 % es la **varianza** $\sigma^2=0.0003766$; la desviación típica es $\sigma=1.94\,\%$. |
| 10 | Ejemplo 2, activo $a_5$ ($\beta=-0.60$) | $\mu_5=-6.9\,\%$ | $0.09\cdot(-0.6)+0.03=$ **−2.4 %**. |
| 10 | Ejemplo 2, enunciado | «riesgo de la Cartera del Mercado establecido en el 12 %» | El 12 % se usa como **rendimiento esperado** $\mu_M$, no como riesgo. |
| — | Actividad 2, tabla de criterios | Encabezado «Análisis de una estrategia sintética con opciones» | Copiado de la Actividad 1; corresponde a «Construcción de una cartera de mínimo riesgo». |
| — | Actividad 2, nombre de archivo | `Grupo.apellido1 nombre1.extensión` | Difiere del de la Actividad 1 (`apellido1 nombre1`). **Confirmado por el docente (19/11/2026): la Actividad 2 es grupal**; se usa el formato del enunciado. |
