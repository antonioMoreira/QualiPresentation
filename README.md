Quali Presentation
------------------

# Third-party tools

Mostly tools are already included in `TeX Live`, these are the ones that need to be installed separately.

Required third-party tools:
- [`tex-fmt`](https://github.com/tex-lsp/tex-fmt)
- [`bibtex-tidy`](https://github.com/nektos/bibtex-tidy)


```bash
cargo install tex-fmt

mise use -g npm:bibtex-tidy
```

Fonts:

```bash
sudo apt install fonts-adobe-sourcesans3
fc-cache -fv
luaotfload-tool --update
```

# Workarounds

```bash
latexmk -C presentation.tex && rm -rf .build/*

ps aux --sort=-%mem | grep -E '([l]atexmk|[l]ualatex|[b]iber|[t]exlab)'
```
