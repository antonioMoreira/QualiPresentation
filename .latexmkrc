# Ensure TeX Live 2026 binaries take priority
$ENV{'PATH'} = '/usr/local/texlive/2026/bin/x86_64-linux:' . $ENV{'PATH'};

# Set a writable cache path for luaotfload
$ENV{'TEXMFVAR'} = '/tmp/texmf-var';

$pdf_mode = 4;  # lualatex
$postscript_mode = 0;
$dvi_mode = 0;
$aux_dir  = '.build';
$out_dir  = '.';

# Disable redundant bibliography checking if not citing references
$bibtex_use = 0;

# Bilingual build: resume.tex -> resume_en.pdf and resume_pt.pdf
# CV_LANG selects the language (default: en). After a successful English build,
# we link resume.pdf to resume_en.pdf for TexLab/Zathura %p compatibility,
# and then run latexmk with CV_LANG=pt to build the Portuguese PDF.
my %babel = (en => 'english', pt => 'brazilian');
my $lang  = $ENV{CV_LANG} // 'en';
$jobname  = "resume_$lang";
$lualatex = "lualatex -interaction=nonstopmode -synctex=1 %O "
          . "\"\\def\\cvlang{$lang}\\def\\cvlangbabel{$babel{$lang}}\\input{%S}\"";

if ($lang eq 'en') {
    $success_cmd = 'ln -sf resume_en.pdf resume.pdf && ln -sf resume_en.synctex.gz resume.synctex.gz && CV_LANG=pt latexmk resume.tex';
}
