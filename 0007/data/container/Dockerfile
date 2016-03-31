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
	texlive-latex-recommended \
	# see http://stackoverflow.com/questions/35923576/debian-httpredir-mirror-system-unreliable-unusable-in-docker for apt-get clean
	&& apt-get clean
	# cannot do the next, which seems to be common in Dockerfiles, because I want to save the package lists
	#&& rm -rf /var/lib/apt/lists/*

# install more packages required by R extension packages
RUN apt-get update -qq \
	&& apt-get install -y --no-install-recommends --fix-missing \
	# required by rmarkdown:
	lmodern \
	pandoc \
	# required by PDFcrop, see https://github.com/yihui/knitr/issues/954:
	ghostscript \
	# for pdftools:
	pkg-config \
	libpoppler-cpp-dev \
	# for git2r:
	libssl-dev \
	# for devtools:
	libcurl4-openssl-dev \
	# for rgdal:
	gdal-bin \
    libgdal-dev \
    libproj-dev \
	# to set the global user name, used by git2r
	git \
	# required when knitting the document
	pandoc-citeproc \
	&& apt-get clean

# install R extension packages needed by the validation process
RUN install2.r -r "http://cran.rstudio.com" \
	  rmarkdown \
	  digest \
	  compare \
	  pdftools \
	  git2r \
	  ggplot2 \
	  devtools \
	  # unclear why rgdal is not a dependency in the package
	  rgdal \
	  && rm -rf /tmp/downloaded_packages/

RUN apt --installed list > /apt-installed.txt \
	&& dpkg -l > /dpkg-list.txt

ENV O2R_VERSION="0.7"
ENV O2R_RUN_FILE="/bag/data/Bagtainer.R"
ENV O2R_RUN_LOG_PRE="/o2r_run/o2r_"
ENV O2R_RUN_LOG_POST=".log"

# id from https://www.random.org/strings/?num=10&len=10&digits=on&upperalpha=on&loweralpha=on&unique=on&format=html&rnd=new
LABEL Description="This is the 7th Bagtainer image, manually created." \
	info.o2r.bag.id="sEKdX3PjvD"

ENTRYPOINT ["sh", "-c"]
CMD ["Rscript --vanilla ${O2R_RUN_FILE} 2>&1 | tee ${O2R_RUN_LOG_PRE}$(date +%Y%m%d-%H%M%S)${O2R_RUN_LOG_POST}"]
