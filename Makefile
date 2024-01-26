.PHONY: all clean compressed bibexport figures tables

all: paper.pdf

clean:
	latexmk -CA
	true || rm unicode-abstract.*

supplement-marker:
	echo "" > supplement-marker.txt
	echo "" >> supplement-marker.txt
	echo "" >> supplement-marker.txt
	echo "" >> supplement-marker.txt
	echo "**********************************" >> supplement-marker.txt
	echo "* On-line supplement starts here *" >> supplement-marker.txt
	echo "**********************************" >> supplement-marker.txt
	cupsfilter supplement-marker.txt > supplement-marker.pdf

unicode-abstract:
	cp _unicode-abstract.tex unicode-abstract.tex
	htlatex unicode-abstract.tex "html,uni-html4" " -cunihtf -utf8"
	cp unicode-abstract.html abstract.html

compressed:
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dBATCH -sOutputFile=paper-compressed.pdf paper.pdf
	ls -lh paper*.pdf

# Use bibexport to make a smaller .bib file with only
# the references used in the paper.
bibexport:
	bibexport -o extracted.bib paper.aux

paper.pdf:paper.tex paper-body.tex abstract.tex appendices.tex bibliography.bib Makefile figures tables

bibliography.bib: ${FULL_BIB_FILE}
	rsync -u ${FULL_BIB_FILE} .

%.pdf: %.tex
	latexmk -synctex=1 -interaction=nonstopmode -file-line-error -f -pdf -bibtex $<

# Phony target for all tables.
tables: $(wildcard tables/*.tex)

# Phony target for all figures.
figures: $(wildcard figures/*.tex)

