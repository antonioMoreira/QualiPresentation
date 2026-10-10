# Useful Macros

## `\newline` in `\author` / `\title`

**Problem:** `\newline` in `\author` (or `\title`) causes:

```text
Package hyperref Warning: Token not allowed in a PDF string (Unicode): removing `\newline'
```

**Solution:** use `\newline` on the slide and a comma in the PDF metadata:

```latex
\author[Antonio Moreira]{Antonio Moreira\texorpdfstring{\newline}{,} Orientadora: Sandra M. Aluísio}
```

**Why:** hyperref copies `\author` and `\title` into the PDF metadata, which accepts plain text only.
`\texorpdfstring{<TeX>}{<PDF>}` keeps the line break on the slide and writes a comma to the metadata. Put no space before it, or the metadata reads "Moreira , Orientadora".
