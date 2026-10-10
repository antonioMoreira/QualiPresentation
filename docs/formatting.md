# LaTeX formatting

This project formats `.tex` files with [tex-fmt](https://github.com/WGUNDERWOOD/tex-fmt).
It previously used [dprint](https://dprint.dev) with the [badness](https://github.com/jolars/badness) plugin, which was dropped because it breaks Beamer overlay specifications.

## Setup

- Install: `cargo install tex-fmt` (tested with v0.5.7).
- Config: `tex-fmt.toml` in the repository root (`wraplen = 100`, `tabsize = 2`). tex-fmt finds it from the current directory or the git root, including in `--stdin` mode.
- Zed: `.zed/settings.json` runs `tex-fmt --stdin` as the external LaTeX formatter, with `format_on_save` enabled.
- Command line:
  - `tex-fmt presentation.tex`: format in place.
  - `tex-fmt -c presentation.tex`: check only, without changing the file.

## Why badness was dropped

The badness parser (dprint plugin v1.2.1 and standalone CLI v0.27.0, both tested on 2026-10-09) does not recognise Beamer's `<...>` overlay specifications. It treats the command before the overlay as complete and moves the overlay away from it.

Sectioning commands broke the build:

```latex
% before saving
\section<presentation>*{\appendixname}

% after badness
\section

<presentation>*{\appendixname}
```

The blank line is a paragraph break, so `\section` took `\par` as its argument. Compilation failed, and the runaway build triggered by texlab's build-on-save used about 15 GB of memory.

Environments were also changed, though the result still compiles:

```latex
\begin{block}{Definição de Prosódia}<1->   % original
\begin{block}{Definição de Prosódia}        % after badness
    <1-> ...

\begin{frame}<beamer>{Sumário}              % original
\begin{frame}                               % after badness
    <beamer>{Sumário} ...                   % title can get merged into the body
```

These compile only because a single line break counts as a space, and Beamer skips spaces before reading an overlay. Any layout that adds a blank line in between breaks them.

badness's own `% badness-format off` / `% badness-format on` directives would protect these regions, but the dprint plugin ignores them.

## Why tex-fmt works with Beamer

tex-fmt does not build a full syntax tree. It only re-indents lines (by environment and bracket depth) and wraps lines longer than `wraplen`. It never joins lines and never inserts blank lines, so overlay specifications such as `\section<presentation>*{...}`, `\begin{frame}<beamer>{...}`, `\begin{block}{...}<1->` and `\item<2->` stay exactly as written.

When `presentation.tex` was switched over, the formatted output had the same non-whitespace
content as the source (verified by checksum), formatting was idempotent (`tex-fmt -c` passed),
and `latexmk` built the 94-page PDF.

Trade-off: tex-fmt only breaks long lines and does not re-join short ones into paragraphs, so the
`"wrap": "reflow"` behaviour of badness is lost.

## Beamer-specific changes made in `presentation.tex`

1. **Removed no-op overlays from the appendix sectioning commands.** Because the document uses
   `\documentclass{beamer}` (not `beamerarticle`), `<presentation>` matches every mode and does
   nothing:

   ```latex
   \section<presentation>*{\appendixname}   →   \section*{\appendixname}
   \subsection<presentation>*{References}   →   \subsection*{References}
   ```

   This was needed while badness was in use; tex-fmt would have kept the original form. If the
   project ever adds an article version with `beamerarticle`, restore the mode restriction as
   `\mode<presentation>{\section*{\appendixname}\subsection*{References}}`.

2. **Fixed an unclosed parenthesis** in the "Objetivos Específicos" frame:
   `(dados do \textit{PECEGE}` became `(dados do \textit{PECEGE})`. tex-fmt indents by bracket
   depth, so the missing `)` made every following line drift right. Its warning
   `Indent does not return to zero` is a useful sign of an unbalanced `(`, `[` or `{`.

3. **Not reverted:** the block and frame overlays that badness had already moved onto the next
   line (for example `\begin{block}{Definição de Prosódia}` followed by `<1->`, and
   `\begin{frame}` followed by `<beamer>{Sumário}` in `\AtBeginSubsection`). They compile as they
   are, and tex-fmt leaves them alone. The original same-line forms are in commit `167445b`.

## Guidelines for Beamer files

- Keep an overlay on the same line as its command: `\item<2->`, `\section<…>`,
  `\begin{frame}<…>{…}`, `\begin{block}{…}<…>`.
- If tex-fmt warns `Indent does not return to zero`, look for an unbalanced bracket near the
  reported line before saving again. See [formatting_caveats.md](formatting_caveats.md).
- Table alignment is left untouched unless `--format-tables` is passed. It is off in this project.
