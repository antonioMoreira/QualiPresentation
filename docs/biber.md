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
| Fields inside each entry      | `scripts/tidy-bib.sh`: sorts alphabetically                              |

```sh
scripts/tidy-bib.sh                 # tidy presentation.bib in place
scripts/tidy-bib.sh other.bib       # tidy another file
```

Result:

```bibtex
@inproceedings{nguyen2023syntacc,
  author        = {Nguyen, Tuan-Nam and Pham, Ngoc-Quan and Waibel, Alex},
  booktitle     = {ICASSP 2023-2023 IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP)},
  doi           = {10.1109/ICASSP49357.2023.10096431},
  organization  = {IEEE},
  pages         = {1--5},
  title         = {SYNTACC: Synthesizing Multi-Accent Speech By Weight Factorization},
  year          = {2023}
}
```

- **Tool:** [bibtex-tidy](https://github.com/FlamingTempura/bibtex-tidy) v1.14.0, run with `npx` (needs Node.js; nothing to install).
- **Field order:** bibtex-tidy has no "alphabetical" option, so the script collects every field name in the file, sorts them, and passes that list.
- **`--no-escape`:** keeps accents as UTF-8 (`Aluísio`). Without it, bibtex-tidy rewrites them as `{\'\i}`.
- **Other changes it makes:** field names become lowercase (`DOI` → `doi`), page ranges become `1--5` (the correct en-dash), alignment becomes uniform, and comments stay with their entry.
- **Checked on 2026-10-09:**
  - Same entries before and after; the same text apart from the changes above.
  - Identical `.bbl` from biber.
  - Running it twice changes nothing.
  - The PDF builds.

## Current validation warnings (18, on cited entries only)

| Warning                                         | Entries                                                        | Affects output?                                       | Fix                                                        |
| ----------------------------------------------- | -------------------------------------------------------------- | ----------------------------------------------------- | ---------------------------------------------------------- |
| `Missing mandatory field 'journaltitle'`        | `Conv_Naturalness_Predictor`, `Responsible_Evaluation`, `nvidia_dataset_toolbox` | **Yes**: no venue shown                               | arXiv preprints: change `@article` to `@online` with `eprint`/`eprinttype = {arxiv}` |
| `Field 'place' invalid`                         | `SpeechActs_Searle1969_book`                                   | **Yes**: the city is dropped                          | rename `place` to `location`                               |
| `Field 'address' invalid`                       | `EyetrackingMOS`, `CoVoMix_2024`                               | No: biblatex renames `address` to `location` anyway   | optional: rename to `location`                             |
| `abstractnote`, `rights`, `articleno`, `numpages` | Zotero exports                                               | No: ignored                                           | optional: delete the fields                                |
| `Invalid field 'publisher'/'issn'`              | `@article` / `@inproceedings` entries                          | No: ignored                                           | none needed                                                |

To silence the warnings instead of fixing them, remove `--validate-datamodel` from `.latexmkrc`.
