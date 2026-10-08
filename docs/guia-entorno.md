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

## 4. Mantenerte al día

Cada semana se añade o ajusta material. Para no perder tus cambios:

```bash
# trabaja en una copia del cuaderno (p. ej. clase-03-mis-notas.ipynb) y luego:
git pull
```

Si `git pull` se queja de conflictos en un cuaderno que modificaste, guarda tu versión con otro nombre y ejecuta 
`git checkout -- <archivo>` antes de volver a hacer `git pull`.

## 5. Datos reales del IBEX-35 (opcional)

```bash
pip install yfinance
python herramientas/descargar_ibex.py --lista
python herramientas/descargar_ibex.py SAN.MC ITX.MC IBE.MC --inicio 2024-01-01
```

## 6. Problemas frecuentes

| Síntoma | Solución |
|---|---|
| `ModuleNotFoundError: mvdc` en local | Activa el entorno y ejecuta `pip install -e .` desde la raíz del repo. |
| Las gráficas no aparecen | Asegúrate de ejecutar la celda de configuración; en scripts `.py` añade `plt.show()`. |
| `FileNotFoundError` con un CSV | Usa `mvdc.datos.cargar("nombre.csv")`, que busca en `datos/` o descarga desde GitHub. |
| Exportar a PDF falla | Usa `jupyter nbconvert --to webpdf archivo.ipynb` (requiere `pip install "nbconvert[webpdf]"`). |
