# Ensure TeX Live 2026 binaries take priority
$ENV{'PATH'} = '/usr/local/texlive/2026/bin/x86_64-linux:' . $ENV{'PATH'};

# Set a writable cache path for luaotfload
$ENV{'TEXMFVAR'} = '/tmp/texmf-var';

# Let \input{...} find the slide sections in sections/
$ENV{'TEXINPUTS'} = './sections//:' . ($ENV{'TEXINPUTS'} // '');

$pdf_mode = 4;  # lualatex
$postscript_mode = 0;
$dvi_mode = 0;
$aux_dir  = '.build';
$out_dir  = '.';

# Bibliography: BibLaTeX with backend=biber (see docs/biber.md)
# 2 = run biber whenever the .bib changes, and delete the generated .bbl on `latexmk -c`
$bibtex_use = 2;
# --validate-datamodel: warn about .bib fields/entries biblatex does not understand
$biber = 'biber --validate-datamodel %O %S';
