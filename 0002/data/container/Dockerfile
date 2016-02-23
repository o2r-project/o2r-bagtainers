FROM rocker/r-base:latest
MAINTAINER Daniel Nüst <daniel.nuest@uni-muenster.de>

ENV O2R_VERSION 0.2

# install latex
RUN apt-get update -qq \
	&& apt-get install -y --no-install-recommends \
	texinfo \
    texlive-base \
	texlive-extra-utils \
	texlive-fonts-extra \
	texlive-fonts-recommended \
	texlive-generic-recommended \
	texlive-latex-base \
	texlive-latex-extra \
	texlive-latex-recommended \
	# required by rmarkdown:
	lmodern \
	pandoc \
	# required by PDFcrop, see https://github.com/yihui/knitr/issues/954
	ghostscript

RUN install2.r -r "http://cran.rstudio.com" \
	  rmarkdown \
	  digest \
	  && rm -rf /tmp/downloaded_packages/

ENV O2R_RUN_FILE=/bag/data/Bagtainer.R

# id from https://www.random.org/strings/?num=10&len=10&digits=on&upperalpha=on&loweralpha=on&unique=on&format=html&rnd=new
LABEL Description="This is the second Bagtainer image, manually created." \
	info.o2r.bag.id="xyELNnSUvB"

ENTRYPOINT ["sh", "-c"]
CMD ["Rscript --vanilla ${O2R_RUN_FILE}"]
# works as expected using command docker run --rm -v $(pwd)/../..:/bag:ro -v /tmp/o2r_run:/o2r_run:rw <id>
# testing with docker run --rm -it -v $(pwd)/../..:/bag:ro -v /tmp/o2r_run:/o2r_run:rw 01fc22 /bin/bash
