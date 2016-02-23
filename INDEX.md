# Bagtainers Index

## 0001

Minimal Rnw file from https://github.com/yihui/knitr/blob/master/inst/examples/knitr-minimal.Rnw

Commands are run from the bag base directory `0001`.

### Create and save the analysis - the steps

* Directory structure was manually created
* Bag was created "in place" with Bagger
* Output was created using knitr in the script file `Bagtainer.R`
  * `Rscript -e "source('data/Bagtainer.R')"` (automatic directory resolving only works with source afaics)
  * if run outside of a container, the script will write to `output`, otherwise to a newly created directory `output_YYYYMMDDHHMMSS`
* Dockerfile was manually created
* Image was manually saved and removed using the following commands
```bash
ID=$(docker images -q bagtainer-0002)
docker save --output $ID.tar bagtainer-0001:latest
docker rmi 8d1075752e2e
```

### Reproduce the analysis

* Load the image with `docker load < data/container/bagtainerimage.tar`
  * image is listed in `docker images`
* Start the image and pass the data directory: `docker run --rm -v $(pwd)/data:/data 8d1075752e2e`
  * The data directory now contains the following files/directories: `Bagtainer0.R  Bagtainer.R  container  input  output  output_20160210170001`

### Compare the results

The following commands were used to manually create hashes of the output file and compare them:

**MD5**

```
daniel@gin-nuest:~/Documents/2016-ORR/Bagtainers/0001$ md5sum data/output/*
11bc6198afa20bc289ba4e378636a54e  data/output/paper.pdf
daniel@gin-nuest:~/Documents/2016-ORR/Bagtainers/0001$ md5sum data/output_20160210170001/*
e8a7c3dfff1b21f1516e81ffe1750424  data/output_20160210170001/paper.pdf
```

Even simpler, the file sizes of the two PDFs already differ:

```
$ ll data/output_20160210170001/
-rw-r--r-- 1 root   root   57125 Feb 10 18:00 paper.pdf
$ ll data/output
-rw-rw-r-- 1 daniel daniel 57152 Feb 10 17:40 paper.pdf
```


## 0002

* Directory structure manually created
* Bag was created "in place" with Bagger
* All configuration was put into file `Bagtainer.yml`
* The whole bag is mounted to `/bag` (as read-only - file deletion does not work from R nor from command line)
* Rscript uses `--vanilla`
* There is _no distinction between input and output directories_, just a working directory which is cloned in the container execution [EP]
  * This requires users to make sure, that their analysis overwrites existing files (not unlikely). In this example, the result can be distinguished
* Output was created using `rmarkdown` by sourcing the script file `Bagtainer.R` from RStudio
* Dockerfile was manually created
* The result comparison happens _in_ the container as part of executing the main script

TODO:
* Image was manually saved and removed using the following commands
```bash
ID=$(docker images -q bagtainer-0002)
docker save --output $ID.tar bagtainer-0001:latest
docker rmi 8d1075752e2e
```


### Reproduce the analysis

* Load the image with `docker load < data/container/bagtainerimage.tar`
  * image is listed in `docker images`
* Start the image (one off run) and pass the bag and output directory: `docker run --rm -v $(pwd)/../..:/bag:ro -v /tmp/o2r:/o2r_run:rw 01fc22`
  * The bag is mounted as read only (`:ro`)
  * The run directory is mounted as read-write (`:rw`) and contains a new directory after the run named `<bagtainerid>_YYYYMMDD_HHMMSS`


### Compare the results

* Comparison of the hashes of all files using the package `digest` picks up on the different PDFs
```
/usr/bin/pandoc +RTS -K512m -RTS lab02-solution.utf8.md --to latex --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash-implicit_figures --output lab02-solution.pdf --template /usr/local/lib/R/site-library/rmarkdown/rmd/latex/default-1.14.tex --highlight-style tango --latex-engine pdflatex --variable graphics=yes --variable 'geometry:margin=1in'

Output created: lab02-solution.pdf
[o2r] digests of original:
                                             /bag/data/wd/ifgi.jpg
"ab3287db74e321170944e8af7225828ed344065a125bef9fa215894009e960d2"
                                   /bag/data/wd/lab02-solution.pdf
"8af18372e53484882656b440d55dce1001d1b727457eb2edbded7c5c43b5631e"
                                   /bag/data/wd/lab02-solution.Rmd
"21b95e89093ca4f3685a81ecd860632d33bf34eabbb1e5c7830f28787c358a5c"
                                          /bag/data/wd/meteo.RData
"6edb27a8e60b2a48f7d95fe34d2169bc89d625b0b6cbea3fd4a02d689deaa31c"
[o2r] digests of run output:
                   /o2r_run/xyELNnSUvB_20160223_164908/wd/ifgi.jpg
"ab3287db74e321170944e8af7225828ed344065a125bef9fa215894009e960d2"
         /o2r_run/xyELNnSUvB_20160223_164908/wd/lab02-solution.pdf
"11aaa4a9c6bb8c26b974c3f27276d083be4d44f9959e8e2acef77e6fcfdd28ca"
         /o2r_run/xyELNnSUvB_20160223_164908/wd/lab02-solution.Rmd
"21b95e89093ca4f3685a81ecd860632d33bf34eabbb1e5c7830f28787c358a5c"
                /o2r_run/xyELNnSUvB_20160223_164908/wd/meteo.RData
"6edb27a8e60b2a48f7d95fe34d2169bc89d625b0b6cbea3fd4a02d689deaa31c"
[o2r] file sizes of original:
          /bag/data/wd/ifgi.jpg /bag/data/wd/lab02-solution.pdf
                          25864                         1348576
/bag/data/wd/lab02-solution.Rmd        /bag/data/wd/meteo.RData
                          13559                          236800
[o2r] file sizes of run output:
          /o2r_run/xyELNnSUvB_20160223_164908/wd/ifgi.jpg
                                                    25864
/o2r_run/xyELNnSUvB_20160223_164908/wd/lab02-solution.pdf
                                                  1348544
/o2r_run/xyELNnSUvB_20160223_164908/wd/lab02-solution.Rmd
                                                    13559
       /o2r_run/xyELNnSUvB_20160223_164908/wd/meteo.RData
                                                   236800
[o2r] comparing /bag/data/wd/ifgi.jpg with /o2r_run/xyELNnSUvB_20160223_164908/wd/ifgi.jpg
[o2r] comparing /bag/data/wd/lab02-solution.pdf with /o2r_run/xyELNnSUvB_20160223_164908/wd/lab02-solution.pdf
Error: identical(.orig, .run) is not TRUE
Execution halted
```
* Manual comparison of the sha1 of the files on command line also yields different hashes:
```
root@9f5c44fdf69b:/# sha1sum /bag/data/wd/lab02-solution.pdf
467355e2ee2a3ec8436f1805b05dd5f20daef8e8  /bag/data/wd/lab02-solution.pdf
root@9f5c44fdf69b:/# sha1sum /o2r_run/xyELNnSUvB_20160223_154630/wd/lab02-solution.pdf
69b1a010b974b39836fad6fc2ca54490818ee85a  /o2r_run/xyELNnSUvB_20160223_154630/wd/lab02-solution.pdf
```
