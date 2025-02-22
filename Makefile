# Make the latex engine selectable via Env Var
ifndef LATEX_ENGINE
	LATEX_ENGINE=xelatex
endif
# Some defaults
PANDOC=pandoc
PANDOC_STANDALONE=pandoc -s
CHAPTERS_CMD=`find chapters -iname "*.md" | sort -V` metadata.yaml
PANDOC_DEFAULT_ARGS=--lua-filter ./filters/filter_helper.lua --listings -N
PDF_TEMPLATE=--pdf-engine=$(LATEX_ENGINE) --template template/template.tex
EPUB_TEMPLATE=--css template/epub.css --highlight-style pygments --template template/template.xhtml
VERSION=-M version=`git describe --tags`
GLADTEX_PKG=gladtex -d "gladtex_imgs" --png -P -p "\usepackage{cancel}\usepackage{gensymb}" -
# Phony targets
.PHONY: clean all

all: pseudocode python cpp js lua epub_pseudocode epub_python epub_cpp epub_js epub_lua

pseudocode: Makefile | output
	$(PANDOC_STANDALONE) $(PANDOC_DEFAULT_ARGS) $(CHAPTERS_CMD) $(VERSION) $(PDF_TEMPLATE) -M proglang=pseudocode -o output/Pseudocode_Edition.pdf

python: Makefile | output
	$(PANDOC_STANDALONE) $(PANDOC_DEFAULT_ARGS) $(CHAPTERS_CMD) $(VERSION) $(PDF_TEMPLATE) -M proglang=python -o output/Python_Edition.pdf

cpp: Makefile | output
	$(PANDOC_STANDALONE) $(PANDOC_DEFAULT_ARGS) $(CHAPTERS_CMD) $(VERSION) $(PDF_TEMPLATE) -M proglang=C++ -o output/C++_Edition.pdf

js: Makefile | output
	$(PANDOC_STANDALONE) $(PANDOC_DEFAULT_ARGS) $(CHAPTERS_CMD) $(VERSION) $(PDF_TEMPLATE) -M proglang=javascript -o output/JS_Edition.pdf

lua: Makefile | output
	$(PANDOC_STANDALONE) $(PANDOC_DEFAULT_ARGS) $(CHAPTERS_CMD) $(VERSION) $(PDF_TEMPLATE) -M proglang=lua -o output/Lua_Edition.pdf

latex:
	$(PANDOC_STANDALONE) $(PANDOC_DEFAULT_ARGS) $(CHAPTERS_CMD) $(VERSION) $(PDF_TEMPLATE) -M proglang=pseudocode -o Book_LaTeX.latex

epub_pseudocode: Makefile | output
	$(PANDOC) $(PANDOC_DEFAULT_ARGS) template/epub_addons/front_matter.md template/epub_addons/dedication.md $(CHAPTERS_CMD) $(VERSION) -M proglang="pseudocode" -t json | $(GLADTEX_PKG) | $(PANDOC_STANDALONE) -f json $(EPUB_TEMPLATE) --to=epub -o output/Pseudocode_Edition.epub

epub_python: Makefile | output
	$(PANDOC) $(PANDOC_DEFAULT_ARGS) template/epub_addons/front_matter.md template/epub_addons/dedication.md $(CHAPTERS_CMD) $(VERSION) -M proglang="python" -t json | $(GLADTEX_PKG) | $(PANDOC_STANDALONE) -f json $(EPUB_TEMPLATE) --to=epub -o output/Python_Edition.epub

epub_cpp: Makefile | output
	$(PANDOC) $(PANDOC_DEFAULT_ARGS) template/epub_addons/front_matter.md template/epub_addons/dedication.md $(CHAPTERS_CMD) $(VERSION) -M proglang="C++" -t json | $(GLADTEX_PKG) | $(PANDOC_STANDALONE) -f json $(EPUB_TEMPLATE) --to=epub -o output/C++_Edition.epub

epub_js: Makefile | output
	$(PANDOC) $(PANDOC_DEFAULT_ARGS) template/epub_addons/front_matter.md template/epub_addons/dedication.md $(CHAPTERS_CMD) $(VERSION) -M proglang="javascript" -t json | $(GLADTEX_PKG) | $(PANDOC_STANDALONE) -f json $(EPUB_TEMPLATE) --to=epub -o output/JS_Edition.epub

epub_lua: Makefile | output
	$(PANDOC) $(PANDOC_DEFAULT_ARGS) template/epub_addons/front_matter.md template/epub_addons/dedication.md $(CHAPTERS_CMD) $(VERSION) -M proglang="lua" -t json | $(GLADTEX_PKG) | $(PANDOC_STANDALONE) -f json $(EPUB_TEMPLATE) --to=epub -o output/Lua_Edition.epub

clean:
	rm -f *.aux *.toc *.lol *.lot *.log *.out *.latex outsourced_descriptions.html gladtex_imgs/* output/*.pdf output/*.epub
	echo "Cleanup finished"
