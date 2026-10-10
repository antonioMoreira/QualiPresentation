#!/usr/bin/env bash
# Sort a .bib file: entries by citation key, fields alphabetically.
# Usage: scripts/tidy-bib.sh [file.bib]   (default: presentation.bib)
# See docs/biber.md.
set -euo pipefail

bib="${1:-presentation.bib}"

# bibtex-tidy has no "alphabetical" field order, so pass every field name found in the file, sorted.
fields=$(grep -oE '^[[:space:]]*[A-Za-z][A-Za-z0-9_-]*[[:space:]]*=' "$bib" \
  | tr -d ' \t=' | tr '[:upper:]' '[:lower:]' | sort -u | paste -sd,)

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

# Read from stdin: in v1.14.0, passing the file name with --no-modify prints only the first line.
npx -y bibtex-tidy@1.14.0 \
  --no-escape \
  --sort=key \
  --sort-fields="$fields" \
  --align=14 \
  --space=2 \
  - < "$bib" > "$tmp"

[ -s "$tmp" ] || { echo "bibtex-tidy produced no output; $bib left unchanged" >&2; exit 1; }
cat "$tmp" > "$bib"
echo "Tidied $bib"
