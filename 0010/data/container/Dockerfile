FROM rocker/r-base:latest
MAINTAINER Daniel Nüst <daniel.nuest@uni-muenster.de>

RUN apt-get update -qq \
	&& apt-get install -y --no-install-recommends \
	# LaTeX
	texinfo \
    texlive-base \
	texlive-extra-utils \
	texlive-fonts-extra \
	texlive-fonts-recommended \
	texlive-generic-recommended \
	texlive-latex-base \
	texlive-latex-extra \
	texlive-latex-recommended \
	# Python
	python3 \
	python3-pip \
	# Packages required by R extension packages
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
	&& apt-get clean \
	# when removing these, we cannot save the installed software via apt
	&& rm -rf /var/lib/apt/lists/*

# install R extension packages needed by the validation process
RUN install2.r -r "http://cran.rstudio.com" \
	  rmarkdown \
	  digest \
	  compare \
	  pdftools \
	  git2r \
	  #ggplot2 \
	  devtools \
	  rticles \
	  dtwSat \
	  # manually added to render the vignette:
	  Hmisc \
	  xtable \
	  # unclear why rgdal is not a dependency in the package
	  rgdal \
	  && rm -rf /tmp/downloaded_packages/

# Install bagit-python
RUN python3 -m pip install bagit
COPY validate.py /validate.py

# Save installed packages to file
RUN dpkg -l > /dpkg-list.txt
#RUN RUN apt --installed list > /apt-installed.txt

ENV O2R_VERSION="0.10"
ENV O2R_RUN_FILE="/bag/data/Bagtainer.R"
ENV O2R_RUN_LOG_PRE="/o2r_run/o2r_"
ENV O2R_RUN_LOG_POST=".log"

# id from https://www.random.org/strings/?num=10&len=10&digits=on&upperalpha=on&loweralpha=on&unique=on&format=html&rnd=new
LABEL Description="This is the 10th Bagtainer image, manually created." \
	info.o2r.bag.id="Pd2O2b2aaH"

ENTRYPOINT ["sh", "-c"]
CMD ["Rscript --vanilla ${O2R_RUN_FILE} 2>&1 | tee ${O2R_RUN_LOG_PRE}$(date +%Y%m%d-%H%M%S)${O2R_RUN_LOG_POST}"]
