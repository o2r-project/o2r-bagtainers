FROM rocker/r-base:latest
MAINTAINER Daniel Nüst <daniel.nuest@wwu.de>

ENV O2R_VERSION 0.1

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

RUN install2.r -r "http://cran.rstudio.com" \
	  knitr \
	  && rm -rf /tmp/downloaded_packages/

ENV O2R_RUN_FILE=Bagtainer.R
ENV O2R_DATA=/data/

LABEL Description="This is the first Bagtainer image, manually created." \
	info.o2r.bag.id="Ut5m7n1hdu"

ENTRYPOINT ["sh", "-c"]
CMD ["Rscript ${O2R_DATA}${O2R_RUN_FILE}"]
# works as expected using command docker run --rm -v $(pwd)/data:/data 8d1075752e2e
# alternative scripts can be run with docker run -v $(pwd)/data:/data 8d1075752e2e "Rscript /data/Bagtainer0.R"
