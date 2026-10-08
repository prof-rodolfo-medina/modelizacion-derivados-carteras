# Guía del entorno de trabajo

## 1. Google Colab (recomendado si no quieres instalar nada)

1. Abre el cuaderno en GitHub y pulsa **Open in Colab**.
2. Ejecuta la primera celda: instala `mvdc` desde este repositorio (tarda unos segundos).
3. Para guardar tus cambios: *Archivo → Guardar una copia en Drive*.

## 2. Instalación local con `venv`

Requisitos: Python ≥ 3.10 y Git.

```bash
git clone https://github.com/prof-rodolfo-medina/modelizacion-derivados-carteras.git
cd modelizacion-derivados-carteras
python -m venv .venv
source .venv/bin/activate          # Windows (PowerShell): .venv\Scripts\Activate.ps1
pip install -e ".[dev]"            # instala mvdc en modo editable + Jupyter y pytest
pytest -q                          # debe terminar con "passed"
jupyter lab
```

## 3. Instalación con Conda / Anaconda

```bash
conda env create -f environment.yml
conda activate mvdc
jupyter lab
```

## 4. Visual Studio Code con GitHub

Requisitos: [VS Code](https://code.visualstudio.com/), [Git](https://git-scm.com/downloads), Python ≥ 3.10 
y una cuenta de GitHub (gratuita).

### 4.1 Clonar el repositorio desde VS Code

1. Abre VS Code y pulsa `Ctrl+Shift+P` (macOS: `Cmd+Shift+P`) para abrir la paleta de comandos.
2. Escribe **Git: Clone** y elige **Clone from GitHub**.
3. La primera vez, VS Code abre el navegador para **iniciar sesión en GitHub**; autoriza y vuelve a VS Code.
4. Busca `prof-rodolfo-medina/modelizacion-derivados-carteras`, elige una carpeta de tu ordenador y pulsa **Open**.
5. Si VS Code pregunta *«Do you trust the authors of the files in this folder?»*, responde **Yes, I trust the authors**.

### 4.2 Extensiones

El repositorio incluye `.vscode/extensions.json`, así que VS Code muestra el aviso 
*«Do you want to install the recommended extensions?»*: pulsa **Install**. Se instalan:

| Extensión | Para qué |
|---|---|
| **Python** (Microsoft) | Intérprete, entornos virtuales, ejecución de scripts y pruebas |
| **Jupyter** (Microsoft) | Abrir y ejecutar los cuadernos `.ipynb` dentro de VS Code |
| **GitHub Pull Requests** (GitHub) | Sesión de GitHub integrada, *issues* y propuestas de cambios |

Si no ves el aviso: panel **Extensions** (`Ctrl+Shift+X`) → escribe `@recommended` → instala las tres.

### 4.3 Entorno de Python

1. `Ctrl+Shift+P` → **Python: Create Environment** → **Venv** → elige tu Python (3.10 o superior).
2. Marca **`requirements.txt`** cuando pregunte qué dependencias instalar. Se instalan `numpy`, `scipy`, `pandas`, 
   `matplotlib`, Jupyter, `pytest` y la biblioteca del curso `mvdc`.
3. Comprueba la instalación: panel **Testing** (icono del matraz) → **Run Tests**. Las pruebas deben salir en verde.

### 4.4 Trabajar con los cuadernos

1. Abre un cuaderno de `sesiones/` (por ejemplo `semana-01/clase-01-…ipynb`).
2. Pulsa **Select Kernel** (esquina superior derecha) → **Python Environments** → `.venv`.
3. Ejecuta las celdas con `Shift+Enter` o **Run All**.

> 💡 Guarda tus anotaciones en una **copia** del cuaderno (clic derecho → *Duplicate*, y renómbrala terminando en 
> `-mis-notas.ipynb`). Esos archivos están excluidos de git, así que nunca chocan con las actualizaciones.

### 4.5 Recibir el material de cada semana

Panel **Source Control** (`Ctrl+Shift+G`) → botón **Sync Changes** (o `…` → **Pull**). 
Si VS Code avisa de cambios locales en un cuaderno del curso, clic derecho sobre el archivo → **Discard Changes** 
(tus notas deben estar en la copia `-mis-notas`).

> No necesitas (ni puedes) subir cambios a este repositorio. Si quieres tu propia versión en GitHub, haz un 
> **Fork** desde la página del repositorio y clona tu fork en lugar del original.

### 4.6 Variante sin instalar nada: GitHub Codespaces

[![Abrir en GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/prof-rodolfo-medina/modelizacion-derivados-carteras)

Codespaces abre el repositorio en **VS Code dentro del navegador**, con Python, las extensiones y las 
dependencias ya instaladas (configuración en `.devcontainer/`). La primera vez tarda unos minutos en prepararse.

- Las cuentas personales de GitHub incluyen una **cuota mensual gratuita** de uso; con 
  [GitHub Education](https://education.github.com/) los estudiantes obtienen beneficios adicionales.
- Para no gastar cuota, **detén el codespace** al terminar: menú ☰ → *Codespaces: Stop Current Codespace*, 
  o desde [github.com/codespaces](https://github.com/codespaces).

> Nota: pulsar la tecla `.` en la página del repositorio abre `github.dev`, un VS Code en el navegador **solo para 
> leer y editar archivos**; no ejecuta Python. Para ejecutar, usa Codespaces.

## 5. Mantenerte al día (terminal)

Cada semana se añade o ajusta material. Para no perder tus cambios:

```bash
# trabaja en una copia del cuaderno (p. ej. clase-03-mis-notas.ipynb) y luego:
git pull
```

Si `git pull` se queja de conflictos en un cuaderno que modificaste, guarda tu versión con otro nombre y ejecuta 
`git checkout -- <archivo>` antes de volver a hacer `git pull`.

## 6. Datos reales del IBEX-35 (opcional)

```bash
pip install yfinance
python herramientas/descargar_ibex.py --lista
python herramientas/descargar_ibex.py SAN.MC ITX.MC IBE.MC --inicio 2024-01-01
```

## 7. Problemas frecuentes

| Síntoma | Solución |
|---|---|
| `ModuleNotFoundError: mvdc` en local | Activa el entorno y ejecuta `pip install -e .` desde la raíz del repo. |
| Las gráficas no aparecen | Asegúrate de ejecutar la celda de configuración; en scripts `.py` añade `plt.show()`. |
| `FileNotFoundError` con un CSV | Usa `mvdc.datos.cargar("nombre.csv")`, que busca en `datos/` o descarga desde GitHub. |
| VS Code no muestra `.venv` al elegir kernel | `Ctrl+Shift+P` → **Python: Select Interpreter** → `.venv`; luego **Developer: Reload Window**. |
| VS Code pide instalar `ipykernel` | Acepta (*Install*); se instala en el entorno `.venv`. |
| **Git: Clone** no aparece en VS Code | Instala Git y reinicia VS Code. |
| Exportar a PDF falla | Usa `jupyter nbconvert --to webpdf archivo.ipynb` (requiere `pip install "nbconvert[webpdf]"`). |
