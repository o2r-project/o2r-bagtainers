FROM rocker/r-base:latest
MAINTAINER Daniel Nüst <daniel.nuest@uni-muenster.de>

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
	texlive-latex-recommended

# install more packages required by R extension packages
RUN apt-get install -y --no-install-recommends \
	# required by rmarkdown:
	lmodern \
	pandoc \
	# required by PDFcrop, see https://github.com/yihui/knitr/issues/954
	ghostscript \
	# for pdftools
	pkg-config \
	libpoppler-cpp-dev

# install R extension packages
RUN install2.r -r "http://cran.rstudio.com" \
	  rmarkdown \
	  digest \
	  compare \
	  pdftools \
	  && rm -rf /tmp/downloaded_packages/

RUN apt --installed list > /apt-installed.txt \
	&& dpkg -l > /dpkg-list.txt

ENV O2R_VERSION="0.5"
ENV O2R_RUN_FILE="/bag/data/Bagtainer.R"
ENV O2R_RUN_LOG_PRE="/o2r_run/o2r_"
ENV O2R_RUN_LOG_POST=".log"

# id from https://www.random.org/strings/?num=10&len=10&digits=on&upperalpha=on&loweralpha=on&unique=on&format=html&rnd=new
LABEL Description="This is the second Bagtainer image, manually created." \
	info.o2r.bag.id="85C6CkRzuR"

ENTRYPOINT ["sh", "-c"]
CMD ["Rscript --vanilla ${O2R_RUN_FILE} 2>&1 | tee ${O2R_RUN_LOG_PRE}$(date +%Y%m%d-%H%M%S)${O2R_RUN_LOG_PRE}"]
# works as expected using command docker run --rm -v $(pwd)/../..:/bag:ro -v /tmp/o2r_run:/o2r_run:rw <id>
# testing with docker run --rm -it -v $(pwd)/../..:/bag:ro -v /tmp/o2r_run:/o2r_run:rw <id> /bin/bash
