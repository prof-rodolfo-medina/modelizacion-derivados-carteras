# Formato Básico para Documentos Universitarios Evaluables

Resumen del anexo incluido en los enunciados de las actividades. Aplica al informe (PDF o notebook).

## Estructura

1. **Portada** — institución (y facultad/departamento), título claro, autoría (nombre y matrícula), 
   persona destinataria (docente), asignatura y fecha de entrega.
2. **Índice** — general con números de página; de tablas y figuras si corresponde.
3. **Introducción** — objetivo, justificación y metodología.
4. **Desarrollo** — secciones coherentes; análisis y discusión; tablas y figuras **numeradas, tituladas y referenciadas en el texto**.
5. **Conclusiones** — resumen de hallazgos y recomendaciones.
6. **Referencias** — todas las fuentes, en un estilo reconocido (APA, MLA, Chicago...) y citas coherentes con él.
7. **Anexos** (si corresponde) — material adicional, datos, gráficos detallados.

## Formato de texto

| Elemento | Requisito |
|---|---|
| Fuente | Times New Roman, Arial o similar, **12 pt** |
| Interlineado | 1.5 o 2 |
| Márgenes | **2.5 cm** en todos los lados |
| Alineación | Justificada |
| Numeración | Inferior o superior derecha |
| Extensión | **≤ 6 páginas de cuerpo** (sin portada, resumen, índices, referencias ni anexos) |

## Recomendaciones

Revisión ortográfica y gramatical, claridad y coherencia, consistencia de estilo en todo el documento.

## Consejos prácticos para estas actividades

- Las ecuaciones se escriben mejor en LaTeX (Overleaf, Word con editor de ecuaciones o celdas Markdown del notebook).
- Exportar un notebook a PDF: *File → Download as → PDF via LaTeX*, o `jupyter nbconvert --to pdf archivo.ipynb` 
  (o `--to webpdf` si no tienes LaTeX instalado). Revisa márgenes y fuente: el formato por defecto **no** cumple los requisitos.
- Las figuras exportadas con `plt.savefig("figura1.png", dpi=200, bbox_inches="tight")` se ven nítidas en el PDF.
