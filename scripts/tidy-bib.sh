#!/usr/bin/env bash
# Tidy a .bib file with bibtex-tidy: entries sorted by citation key, fields in bibtex-tidy's default order.
# Usage: scripts/tidy-bib.sh [file.bib]   (default: presentation.bib)
#        scripts/tidy-bib.sh --stdin      (filter: stdin -> stdout, used by Zed's format on save)
# See docs/biber.md.
set -euo pipefail

flags=(
  --curly
  --numeric
  --space=2
  --align=13
  --blank-lines
  --sort=key
  --duplicates=key
  --merge=combine
  --no-escape
  --sort-fields
  --remove-empty-fields
  --no-remove-dupe-fields
  --wrap=80
  --quiet
)

if [ "${1:-}" = "--stdin" ]; then
  exec bibtex-tidy "${flags[@]}"
fi

bib="${1:-presentation.bib}"

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

# Read from stdin and write to stdout so the file is only replaced when the run succeeds.
bibtex-tidy "${flags[@]}" - < "$bib" > "$tmp"

[ -s "$tmp" ] || { echo "bibtex-tidy produced no output; $bib left unchanged" >&2; exit 1; }
cat "$tmp" > "$bib"
echo "Tidied $bib"
