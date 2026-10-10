# Formatting caveats (tex-fmt)

Quick reference. Setup and background: [formatting.md](formatting.md). Tested with tex-fmt v0.5.7.

## Unbalanced brackets shift the indentation of everything after them

tex-fmt counts `(`, `[`, `{` and `\{` like `\begin{...}`. A lone bracket in text throws off the indentation from that line to the end of the file. The PDF still compiles, so the indentation is the only sign.

| Breaks                                  | Safe                                    |
| --------------------------------------- | --------------------------------------- |
| `(dados do \textit{PECEGE} à` (no `)`)  | balanced on one line: `$[0, 1)$`        |
| `Passo 1)`, `a)`, `:)`                  | balanced across lines (any types)       |
| `\left( x \right.`                      | brackets in comments or `verbatim`      |
| `\{` without a matching `\}`            | `\[ ... \]`                             |

**Symptom:** `\end{...}` doesn't line up with its `\begin{...}`, or `\end{document}` isn't at column 0.

**Fix:**

- Close the bracket.
- Or end the line with `% tex-fmt: skip`, or wrap several lines in `% tex-fmt: off` / `% tex-fmt: on`.
- Balancing the bracket in a comment (`% (`) doesn't work, because comments are ignored.
- For numbered items, use `enumerate` instead of typing `1)`.

## Zed hides the warnings

On save, tex-fmt still exits with code `0`, so Zed applies the wrong indentation silently. To find the cause:

```sh
tex-fmt -c presentation.tex
```

| Warning                                      | Look for                               |
| -------------------------------------------- | -------------------------------------- |
| `Indent does not return to zero ... line N`  | unclosed `(` `[` `{` just after line N |
| `Negative indents ... line N`                | extra `)` `]` `}` before or on line N  |

## Beamer overlays on `\section` (why badness was dropped)

`\section<presentation>*{\appendixname}` is valid Beamer. badness split it into `\section`, a blank line, then `<presentation>*{...}`. A blank line is `\par`, so `\section` took it as its argument. The build failed and used about 15 GB of memory.

- **Now:** tex-fmt leaves overlays as written (tested).
- **In this file:** `<presentation>` was removed (`\section*{\appendixname}`). With `\documentclass{beamer}` it does nothing, and the PDF is the same.
- **If you add a `beamerarticle` version:** use `\mode<presentation>{\section*{\appendixname}\subsection*{References}}`.

Details: [formatting.md](formatting.md#why-badness-was-dropped).

## Other caveats

- **Closing line drops back:** in a wrapped `\caption{...}`, the line with the final `}` is indented at the outer level. This is normal.
- **Old buffers:** after editing the file outside Zed, reload it in Zed before saving. Saving an old buffer loses the edit.
- **No reflow:** tex-fmt only breaks lines over 100 characters. It never joins short lines.
