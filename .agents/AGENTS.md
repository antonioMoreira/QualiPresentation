# Agent Instructions

- Always respond in `English`, regardless of the language of the source files or user prompts.

## Adding a useful macro to `docs/UsefulMacros.md`

When a LaTeX fix or macro solves a recurring problem, add an entry to `docs/UsefulMacros.md`:

1. Heading: `## <macro or problem name>` (e.g. ``## `\newline` in `\author` / `\title` ``).
2. **Problem:** one line. Include the exact warning or error in a `text` code block if there is one.
3. **Solution:** one line plus a `latex` code block with a working snippet taken from the project.
4. **Why:** two lines at most, explaining the cause and how the solution works.
5. Before adding the entry, build with `latexmk` and confirm the warning is gone and the output is correct.
6. Run `tex-fmt -c` on any `.tex` file you changed.
