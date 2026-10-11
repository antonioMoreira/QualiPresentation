# Bibliography (biblatex + biber)

## Setup

| Where                | What                                                                 |
| -------------------- | -------------------------------------------------------------------- |
| `presentation.tex`   | `\usepackage[backend=biber]{biblatex}` + `\addbibresource{presentation.bib}` |
| `.latexmkrc`         | `$bibtex_use = 2;` and `$biber = 'biber --validate-datamodel %O %S';` |
| Zed (texlab)         | builds with `latexmk` on save, so biber runs automatically           |

- Tested with biber 2.22 (TeX Live 2026).
- `$bibtex_use = 2`: biber runs whenever the `.bib` or the citations change. `latexmk -c` also deletes the generated `.bbl`.
- `--validate-datamodel`: biber warns about `.bib` fields and entries that biblatex doesn't understand. The warnings appear in the build log and in Zed as `Package biblatex Warning: Biber reported the following issues`. They never fail the build.
- Output goes to `.build/` (`presentation.bbl`, `presentation.blg`). The biber log is `.build/presentation.blg`.

## Commands

```sh
latexmk presentation.tex                 # build (runs biber when needed)
latexmk -g presentation.tex              # force a full rebuild, including biber
grep WARN .build/presentation.blg        # list biber warnings
rm -rf "$(biber --cache)"                # clear biber's cache (for "cache" errors after a TeX Live update)
```

## Sorting

| What                          | How                                                                      |
| ----------------------------- | ------------------------------------------------------------------------ |
| References slide (in the PDF) | Already alphabetical: biblatex's default `sorting=nty` (name, title, year). To change it: `\usepackage[backend=biber,sorting=ynt]{biblatex}` etc. |
| Entries in `presentation.bib` | `scripts/tidy-bib.sh`: sorts by citation key                             |
| Fields inside each entry      | `scripts/tidy-bib.sh`: bibtex-tidy's default order (title, author, year, ...) |

```sh
scripts/tidy-bib.sh                 # tidy presentation.bib in place
scripts/tidy-bib.sh other.bib       # tidy another file
```

Zed runs it on save for `.bib` files: `.zed/settings.json` sets the `BibTeX` language's external formatter to `bash scripts/tidy-bib.sh --stdin` (stdin → stdout, same flags). It needs `bibtex-tidy` in the `PATH` Zed sees.

Result:

```bibtex
@inproceedings{nguyen2023syntacc,
  title        = {SYNTACC: Synthesizing Multi-Accent Speech By Weight Factorization},
  author       = {Nguyen, Tuan-Nam and Pham, Ngoc-Quan and Waibel, Alex},
  year         = 2023,
  booktitle    = {ICASSP 2023-2023 IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP)},
  pages        = {1--5},
  organization = {IEEE},
  doi          = {10.1109/ICASSP49357.2023.10096431}
}
```

- **Tool:** [bibtex-tidy](https://github.com/FlamingTempura/bibtex-tidy) v1.15.1, installed globally with `mise use -g npm:bibtex-tidy`.
- **Options:** bibtex-tidy has no config file, so the flags are in `scripts/tidy-bib.sh`:

  ```sh
  bibtex-tidy --curly --numeric --space=2 --align=13 --blank-lines --sort=key --duplicates=key \
    --merge=combine --no-escape --sort-fields --remove-empty-fields --no-remove-dupe-fields
  ```

- **`--no-escape`:** keeps accents as UTF-8 (`Aluísio`). Without it, bibtex-tidy rewrites them as `{\'\i}`.
- **`--curly` / `--numeric`:** values are wrapped in braces, except numbers (`year = 2023`).
- **`--duplicates=key --merge=combine`:** entries with the same key are merged; fields missing from the first entry are filled in from the duplicates.
- **Other changes it makes:** field names become lowercase (`DOI` → `doi`), page ranges become `1--5` (the correct en-dash), alignment becomes uniform, and comments stay with their entry.
- Running it twice changes nothing.

## Current validation warnings (18, on cited entries only)

| Warning                                         | Entries                                                        | Affects output?                                       | Fix                                                        |
| ----------------------------------------------- | -------------------------------------------------------------- | ----------------------------------------------------- | ---------------------------------------------------------- |
| `Missing mandatory field 'journaltitle'`        | `Conv_Naturalness_Predictor`, `Responsible_Evaluation`, `nvidia_dataset_toolbox` | **Yes**: no venue shown                               | arXiv preprints: change `@article` to `@online` with `eprint`/`eprinttype = {arxiv}` |
| `Field 'place' invalid`                         | `SpeechActs_Searle1969_book`                                   | **Yes**: the city is dropped                          | rename `place` to `location`                               |
| `Field 'address' invalid`                       | `EyetrackingMOS`, `CoVoMix_2024`                               | No: biblatex renames `address` to `location` anyway   | optional: rename to `location`                             |
| `abstractnote`, `rights`, `articleno`, `numpages` | Zotero exports                                               | No: ignored                                           | optional: delete the fields                                |
| `Invalid field 'publisher'/'issn'`              | `@article` / `@inproceedings` entries                          | No: ignored                                           | none needed                                                |

To silence the warnings instead of fixing them, remove `--validate-datamodel` from `.latexmkrc`.
