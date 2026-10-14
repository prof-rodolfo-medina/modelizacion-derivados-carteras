# Guía para estudiantes con poca experiencia en programación

Esta asignatura usa Python como **herramienta para comprobar y aplicar las matemáticas**, no como fin en sí mismo.
No necesitas ser programador: basta con un subconjunto pequeño del lenguaje, siempre el mismo, que puedes
aprender en unas horas antes de que empiece el curso.

> Las dudas se plantean en la **sesión síncrona** o en el foro **«Pregúntale a tu profesor»** del aula virtual.

---

## 1. Ruta recomendada antes del 02/11/2026

| Paso | Qué hacer | Tiempo aproximado |
|---|---|---|
| 1 | Abrir Google Colab con tu cuenta de Google (sección 2 de esta guía) | 10 min |
| 2 | Hacer el cuaderno [**Semana 0 · Python esencial**](../sesiones/semana-00/) con sus 7 ejercicios autocorregibles | 60–90 min |
| 3 | Tener a mano la [**chuleta de Python**](chuleta-python.md) | — |
| 4 | Abrir el [cuaderno de la Clase 1](../sesiones/semana-01/) y ejecutarlo completo, sin intentar entenderlo todo | 20 min |

Con esto llegas a la primera sesión sabiendo ejecutar, modificar y leer el código que se usará en clase.

## 2. Google Colab paso a paso

Colab ejecuta Python en los servidores de Google: **no hay que instalar nada**.

1. Abre el cuaderno en GitHub y pulsa el botón **Open in Colab**.
2. Inicia sesión con tu cuenta de Google si te lo pide.
3. Si aparece *«Advertencia: Este cuaderno no lo creó Google»*, pulsa **Ejecutar de todos modos**: es el cuaderno del curso.
4. Ejecuta las celdas en orden con **Shift + Enter**. La primera vez tarda unos segundos en conectarse.
5. Para **guardar tus cambios**: *Archivo → Guardar una copia en Drive*. Si no lo haces, tus cambios se pierden al cerrar.

**Dos cosas que conviene saber:**

- Si dejas Colab inactivo un rato, **se desconecta** y olvida las variables. Al volver, usa
  *Entorno de ejecución → Ejecutar todas* (o *Ejecutar anteriores*).
- Si una celda tarda demasiado o se queda colgada: *Entorno de ejecución → Interrumpir ejecución*.

¿Prefieres trabajar en tu ordenador? Las opciones B (local) y C (VS Code) están en la [guía del entorno](guia-entorno.md);
para empezar, Colab es lo más sencillo.

## 3. El Python que realmente necesitas

| Para… | Necesitas | Temas | Dónde se practica |
|---|---|---|---|
| Calcular pagos y beneficios de opciones | Arrays de NumPy, `np.maximum`, funciones | 1–2 | Semana 0 §2–3, Clase 1 |
| Graficar estrategias | `plt.plot`, `plt.axhline`, `plt.annotate` | 1–2 | Semana 0 §4, Clase 1 |
| Valorar con árboles binomiales | Fórmulas con `np.exp`, bucles sencillos | 3–4 | Clases 2–3 |
| Simular el modelo log-normal | Números aleatorios, `np.cumsum` | 5 | Semana 0 §7, Clase 4 |
| Estimar parámetros con datos | pandas: `read_csv`, `shift`, `mean`, `std` | 6 | Semana 0 §5, Clase 5 |
| Black-Scholes | `scipy.stats.norm.cdf` | 7 | Clase 5 |
| Carteras de mínimo riesgo | Matrices: `@`, `np.linalg.solve`, `np.cov` | 8–10 | Semana 0 §6, Clases 6–7 |

Lo que **no** necesitas: clases y objetos, programación web, bases de datos, ni optimizar la velocidad del código.

## 4. Cómo leer un cuaderno del curso

Todos los cuadernos de `sesiones/` siguen la misma estructura:

1. **Celda de configuración** (la primera de código): instala o carga la biblioteca del curso `mvdc` y las librerías.
   Ejecútala siempre primero.
2. **Teoría breve** con las fórmulas de los apuntes, seguida de código que las **comprueba con números**.
3. **Ejercicio en clase**: una celda casi vacía (`# Tu código aquí`) para practicar.

La biblioteca `mvdc` implementa los métodos del temario en una línea, por ejemplo `bs.bs_call(...)`. Úsala para
**entender y comprobar**; en las actividades evaluables tu código debe implementar las fórmulas por sí mismo
(ver [requisitos de las actividades](../actividades/README.md)).

## 5. Cuando algo falla

1. **No te asustes por el texto rojo.** Lee la **última línea** del error: dice el tipo (`NameError`, `TypeError`…)
   y una pista.
2. Busca la flecha `---->`: señala la línea de **tu** código donde ocurrió.
3. Consulta la tabla de errores frecuentes en la [Semana 0, sección 8](../sesiones/semana-00/).
4. Si sigue sin funcionar, **reinicia y ejecuta todo** desde el principio. Muchos problemas vienen de haber
   ejecutado celdas en otro orden.
5. Si aun así no lo resuelves, plantéalo en el foro «Pregúntale a tu profesor» indicando:
   qué celda, qué esperabas que pasara y **el mensaje de error completo** (copiado como texto, no como foto).

## 6. Método de trabajo para las actividades

Programar un modelo financiero es más fácil si sigues siempre el mismo orden:

1. **Escribe la fórmula en papel** con la notación de los apuntes.
2. **Calcula a mano un caso pequeño** (por ejemplo, el B/P para $S_T = 80$ y $S_T = 120$). Ese será tu control.
3. **Traduce la fórmula a una función** de Python, una línea por cada término.
4. **Comprueba** que la función da tu resultado a mano. Si existe, compara también con `mvdc`.
5. **Grafica** y pregúntate si la forma tiene sentido financiero (pendientes, tramos, puntos de equilibrio).
6. **Comenta el código** explicando el *porqué*, no el *qué*:

   ```python
   # Mal:   resta la prima
   # Bien:  la prima se paga al inicio, así que reduce el beneficio en todos los escenarios
   bp = pago - C
   ```

7. Antes de entregar: **Reiniciar y ejecutar todo** en un entorno limpio. Si falla ahí, fallará al corregirlo.

Sobre el uso de herramientas de inteligencia artificial, consulta la normativa de la asignatura en el aula
virtual. En cualquier caso, debes poder **explicar cada línea** del código que entregas.

## 7. Recursos gratuitos para ampliar

| Recurso | Para qué | Idioma |
|---|---|---|
| [Tutorial oficial de Python](https://docs.python.org/es/3/tutorial/) (capítulos 3–5) | Fundamentos del lenguaje | Español |
| [NumPy: the absolute basics for beginners](https://numpy.org/doc/stable/user/absolute_beginners.html) | Arrays y operaciones | Inglés |
| [10 minutes to pandas](https://pandas.pydata.org/docs/user_guide/10min.html) | Tablas de datos | Inglés |
| [Pyplot tutorial](https://matplotlib.org/stable/tutorials/pyplot.html) | Gráficas | Inglés |

No hace falta leerlos completos: úsalos como consulta cuando un concepto de la Semana 0 se te quede corto.
