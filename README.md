Quali Presentation
------------------

Fonts:

```bash
sudo apt install fonts-adobe-sourcesans3
fc-cache -fv
luaotfload-tool --update
```

```bash
latexmk -C presentation.tex && rm -rf .build/*

ps aux --sort=-%mem | grep -E '([l]atexmk|[l]ualatex|[b]iber|[t]exlab)'
```
