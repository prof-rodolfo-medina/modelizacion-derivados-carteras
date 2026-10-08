"""
Comprobación previa de una entrega (no sustituye la revisión del enunciado oficial).

Uso:
    python herramientas/verificar_entrega.py --actividad 1 "perez juan.pdf" "perez juan.ipynb"
    python herramientas/verificar_entrega.py --actividad 2 "G3.perez juan.pdf" "G3.perez juan.py" "G3.perez juan.zip"

Comprueba:
  1. Que los nombres siguen el formato exigido.
  2. Que hay un informe (.pdf o .ipynb) y un archivo de código (.py o .ipynb).
  3. Que el código se ejecuta de principio a fin sin errores (kernel limpio).
  4. Que los CSV que el código lee existen junto al código o dentro del .zip.
  5. (Opcional, con pypdf) el número total de páginas del PDF, como recordatorio del límite de 6 de cuerpo.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

PATRONES = {
    1: re.compile(r"^[^\s.]+ [^\s.]+\.(pdf|ipynb|py|zip|7z)$", re.IGNORECASE),
    2: re.compile(r"^[^\s.]+\.[^\s.]+ [^\s.]+\.(pdf|ipynb|py|zip|7z)$", re.IGNORECASE),
}
FORMATO = {1: "apellido1 nombre1.extensión", 2: "Grupo.apellido1 nombre1.extensión"}

ok_total = True


def informe(ok: bool, msg: str):
    global ok_total
    ok_total &= ok
    print(("  ✔ " if ok else "  ✘ ") + msg)


def ejecutar(codigo: Path) -> tuple[bool, str]:
    with tempfile.TemporaryDirectory() as tmp:
        if codigo.suffix == ".ipynb":
            cmd = [sys.executable, "-m", "jupyter", "nbconvert", "--to", "notebook", "--execute",
                   "--output-dir", tmp, "--ExecutePreprocessor.timeout=600", str(codigo)]
        else:
            cmd = [sys.executable, str(codigo)]
        r = subprocess.run(cmd, cwd=codigo.parent, capture_output=True, text=True,
                           env={**__import__("os").environ, "MPLBACKEND": "Agg"})
        log = re.sub(r"\x1b\[[0-9;]*m", "", r.stderr or r.stdout)
        errores = [l for l in log.splitlines() if re.search(r"(Error|Exception):", l)]
        return r.returncode == 0, (errores[-1] if errores else log[-800:])


def csv_referenciados(codigo: Path) -> set[str]:
    texto = codigo.read_text(encoding="utf-8", errors="ignore")
    return set(re.findall(r"[\"']([^\"'\s]+\.(?:csv|xlsx?))[\"']", texto))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--actividad", type=int, choices=[1, 2], required=True)
    p.add_argument("archivos", nargs="+", type=Path)
    a = p.parse_args()

    print(f"\n1) Nombres de archivo (formato: {FORMATO[a.actividad]})")
    for f in a.archivos:
        informe(f.exists(), f"{f.name} existe")
        informe(bool(PATRONES[a.actividad].match(f.name)), f"{f.name} cumple el formato")

    print("\n2) Archivos requeridos")
    exts = {f.suffix.lower() for f in a.archivos}
    informe(bool(exts & {".pdf", ".ipynb"}), "hay informe (.pdf o notebook con formato básico)")
    codigo = [f for f in a.archivos if f.suffix.lower() in {".py", ".ipynb"}]
    informe(bool(codigo), "hay código (.py o .ipynb)")

    print("\n3) Ejecución del código en limpio")
    for c in codigo:
        ok, log = ejecutar(c)
        informe(ok, f"{c.name} se ejecuta sin errores")
        if not ok:
            print("     ↳ " + log.replace("\n", "\n       "))

    print("\n4) Datos adjuntos")
    zips = [f for f in a.archivos if f.suffix.lower() == ".zip" and f.exists()]
    en_zip = {Path(n).name for z in zips for n in zipfile.ZipFile(z).namelist()}
    for c in codigo:
        for ref in csv_referenciados(c):
            if ref.startswith("http") or ref in {"cartera_simulada.csv", "mercado_simulado.csv", "tema6_ibex_28dias.csv"}:
                continue
            informe((c.parent / ref).exists() or Path(ref).name in en_zip, f"datos '{ref}' adjuntos")

    pdfs = [f for f in a.archivos if f.suffix.lower() == ".pdf" and f.exists()]
    if pdfs:
        print("\n5) Extensión del PDF")
        try:
            from pypdf import PdfReader
            for f in pdfs:
                try:
                    n = len(PdfReader(f).pages)
                    print(f"  ℹ {f.name}: {n} páginas en total — el cuerpo (sin portada, índices, referencias ni anexos) debe ser ≤ 6.")
                except Exception as e:  # PDF dañado o no válido
                    informe(False, f"{f.name} no se puede abrir como PDF ({e.__class__.__name__})")
        except ImportError:
            print("  ℹ Instala pypdf para contar páginas (pip install pypdf).")

    print("\nResultado:", "LISTO PARA ENTREGAR ✔" if ok_total else "REVISA LOS PUNTOS MARCADOS ✘")
    sys.exit(0 if ok_total else 1)


if __name__ == "__main__":
    main()
