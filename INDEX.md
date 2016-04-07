# Bagtainers Index
## 0001
Minimal Rnw file from [https://github.com/yihui/knitr/blob/master/inst/examples/knitr-minimal.Rnw](https://github.com/yihui/knitr/blob/master/inst/examples/knitr-minimal.Rnw)

Commands are run from the bag base directory `0001`.

### Create and save the analysis - the steps
- Directory structure was manually created
- Bag was created "in place" with Bagger
- Output was created using knitr in the script file `Bagtainer.R`
  - `Rscript -e "source('data/Bagtainer.R')"` (automatic directory resolving only works with source afaics)
  - if run outside of a container, the script will write to `output`, otherwise to a newly created directory `output_YYYYMMDDHHMMSS`
- Dockerfile was manually created
- Image was manually saved and removed using the following commands
- ID=$(docker images -q bagtainer-0002)
docker save --output $ID.tar bagtainer-0001:latest
docker rmi 8d1075752e2e

### Reproduce the analysis
- Load the image with `docker load < data/container/bagtainerimage.tar`
  - image is listed in `docker images`

- Start the image and pass the data directory: `docker run --rm -v $(pwd)/data:/data 8d1075752e2e`
  - The data directory now contains the following files/directories: `Bagtainer0.R  Bagtainer.R  container  input  output  output_20160210170001`

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
- Directory structure manually created
- Bag was created "in place" with Bagger
- All configuration was put into file `Bagtainer.yml`
- The whole bag is mounted to `/bag` (as read-only - file deletion does not work from R nor from command line)
- Rscript uses `--vanilla`
- There is _no distinction between input and output directories_, just a working directory which is cloned in the container execution [EP]
  - This requires users to make sure, that their analysis overwrites existing files (not unlikely). In this example, the result can be distinguished

- Output was created using `rmarkdown` by sourcing the script file `Bagtainer.R` from RStudio
- Dockerfile was manually created with `docker build -t bagtainers/0002 .`
- The result comparison happens _in_ the container as part of executing the main script
- Manually created files listing all the installed packages in the container directory by creating them with an external command
  - `user@host:.../0002/data/container$ docker exec <container_name> apt --installed list > apt-installed.txt`
  - `user@host:.../0002/data/container$ docker exec <container_name> dpkg -l > dpkg-list.txt`

- The analysis is executed as the non-root user "docker" having the UID/GID 1000
  - The directories mounted from the host must be owned by a user with the same id!

### Reproduce the analysis
- Load the image with `docker load < data/container/bagtainerimage.tar`
  - image is listed in `docker images`

- Start the image (one off run in the directory `../0002`) and pass the bag and output directory: `docker run --rm --user 1000 -v $(pwd):/bag:ro -v /tmp/o2r_run:/o2r_run:rw -e TZ=CET bagtainers/0002`
  - The bag is mounted as read only (`:ro`)
  - The run directory is mounted as read-write (`:rw`) and contains a new directory after the run named `<bagtainerid>_YYYYMMDD_HHMMSS` (the mounted directory on the host must be owned by the user with the GID `1000`)

### Compare the results
- Comparison of the hashes of all files using the package `digest` picks up on the different PDFs
- ```
- /usr/bin/pandoc +RTS -K512m -RTS lab02-solution.utf8.md --to latex --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash-implicit_figures --output lab02-solution.pdf --template /usr/local/lib/R/site-library/rmarkdown/rmd/latex/default-1.14.tex --highlight-style tango --latex-engine pdflatex --variable graphics=yes --variable 'geometry:margin=1in'

Output created: lab02-solution.pdf [o2r] digests of original:                                              /bag/data/wd/ifgi.jpg "ab3287db74e321170944e8af7225828ed344065a125bef9fa215894009e960d2"                                    /bag/data/wd/lab02-solution.pdf "8af18372e53484882656b440d55dce1001d1b727457eb2edbded7c5c43b5631e"                                    /bag/data/wd/lab02-solution.Rmd "21b95e89093ca4f3685a81ecd860632d33bf34eabbb1e5c7830f28787c358a5c"                                           /bag/data/wd/meteo.RData "6edb27a8e60b2a48f7d95fe34d2169bc89d625b0b6cbea3fd4a02d689deaa31c" [o2r] digests of run output:                    /o2r_run/xyELNnSUvB_20160223_164908/wd/ifgi.jpg "ab3287db74e321170944e8af7225828ed344065a125bef9fa215894009e960d2"          /o2r_run/xyELNnSUvB_20160223_164908/wd/lab02-solution.pdf "11aaa4a9c6bb8c26b974c3f27276d083be4d44f9959e8e2acef77e6fcfdd28ca"          /o2r_run/xyELNnSUvB_20160223_164908/wd/lab02-solution.Rmd "21b95e89093ca4f3685a81ecd860632d33bf34eabbb1e5c7830f28787c358a5c"                 /o2r_run/xyELNnSUvB_20160223_164908/wd/meteo.RData "6edb27a8e60b2a48f7d95fe34d2169bc89d625b0b6cbea3fd4a02d689deaa31c" [o2r] file sizes of original:           /bag/data/wd/ifgi.jpg /bag/data/wd/lab02-solution.pdf                           25864                         1348576 /bag/data/wd/lab02-solution.Rmd        /bag/data/wd/meteo.RData                           13559                          236800 [o2r] file sizes of run output:           /o2r_run/xyELNnSUvB_20160223_164908/wd/ifgi.jpg                                                     25864 /o2r_run/xyELNnSUvB_20160223_164908/wd/lab02-solution.pdf                                                   1348544 /o2r_run/xyELNnSUvB_20160223_164908/wd/lab02-solution.Rmd                                                     13559        /o2r_run/xyELNnSUvB_20160223_164908/wd/meteo.RData                                                    236800 [o2r] comparing /bag/data/wd/ifgi.jpg with /o2r_run/xyELNnSUvB_20160223_164908/wd/ifgi.jpg [o2r] comparing /bag/data/wd/lab02-solution.pdf with /o2r_run/xyELNnSUvB_20160223_164908/wd/lab02-solution.pdf Error: identical(.orig, .run) is not TRUE Execution halted

```
* Manual comparison of the sha1 of the files on command line also yields different hashes:
```

root@9f5c44fdf69b:/# sha1sum /bag/data/wd/lab02-solution.pdf 467355e2ee2a3ec8436f1805b05dd5f20daef8e8  /bag/data/wd/lab02-solution.pdf root@9f5c44fdf69b:/# sha1sum /o2r_run/xyELNnSUvB_20160223_154630/wd/lab02-solution.pdf 69b1a010b974b39836fad6fc2ca54490818ee85a  /o2r_run/xyELNnSUvB_20160223_154630/wd/lab02-solution.pdf

```

## 0003

A clone of `0002`, but with the following changes:

- The output is a plain Markdown output document based on `rmarkdown`.
- The volume is started with an explicit timezone, i.e. the one used during creation of the original documents. The following two commands result in same file hash for the created document `lab02-solution.md`:
  - `docker run -it -v $(pwd)/0003:/bag:ro -v /tmp/o2r_run:/o2r_run:rw -v /etc/localtime:/etc/localtime:ro bagtainers/0003` > use the host system time zone
  - `docker run -it -v $(pwd)/0003:/bag:ro -v /tmp/o2r_run:/o2r_run:rw -e TZ=CET bagtainers/0003`
- The output check function uses **only the root working directory**, so that this analysis actually succeeds. It does not compare the output images in `<wd>/lab02-solution_files`!

### Reproduce the analysis

- See above (but set environment variable with `-e TZ=CET`)

### Compare the results

* Comparison result as run on Travis: https://travis-ci.org/nuest/bagtainers/jobs/111497998

```
/usr/bin/pandoc +RTS -K512m -RTS lab02-solution.utf8.md --to markdown_strict --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash --output lab02-solution.md --standalone

Output created: lab02-solution.md [o2r] file sizes of original:             /bag/data/wd/ifgi.jpg /bag/data/wd/lab02-solution_files                             25864                              4096    /bag/data/wd/lab02-solution.md   /bag/data/wd/lab02-solution.Rmd                             21473                             13559          /bag/data/wd/meteo.RData                            236800 [o2r] file sizes of run output:             /o2r_run/xyELNnSUvB_20160224_151600/wd/ifgi.jpg                                                       25864 /o2r_run/xyELNnSUvB_20160224_151600/wd/lab02-solution_files                                                        4096    /o2r_run/xyELNnSUvB_20160224_151600/wd/lab02-solution.md                                                       21473   /o2r_run/xyELNnSUvB_20160224_151600/wd/lab02-solution.Rmd                                                       13559          /o2r_run/xyELNnSUvB_20160224_151600/wd/meteo.RData                                                      236800 [o2r] comparing /bag/data/wd/ifgi.jpg with /o2r_run/xyELNnSUvB_20160224_151600/wd/ifgi.jpg [o2r] comparing /bag/data/wd/lab02-solution_files with /o2r_run/xyELNnSUvB_20160224_151600/wd/lab02-solution_files [o2r] comparing /bag/data/wd/lab02-solution.md with /o2r_run/xyELNnSUvB_20160224_151600/wd/lab02-solution.md [o2r] comparing /bag/data/wd/lab02-solution.Rmd with /o2r_run/xyELNnSUvB_20160224_151600/wd/lab02-solution.Rmd [o2r] comparing /bag/data/wd/meteo.RData with /o2r_run/xyELNnSUvB_20160224_151600/wd/meteo.RData [o2r] reproduction successful using container ee14a4fcd91b

The command "docker run -v $(pwd)/$BAGTAINER_ID:/bag:ro -v ~/o2r/run:/o2r_run:rw bagtainers/$BAGTAINER_ID" exited with 0.

Done. Your build exited with 0.
```

## 0004
An extension of `0003` with the following changes:
- The timezone is set via `Sys.setenv()` from within the R script
  - Setting the variable `TZ` in the container has no effect anymore
  - Old issues are back when commenting out the environment setting in the configuration file
  - If two file hashes differ, a `diff` is printed to the console

- The lists of installed packages (via `apt` and `dpkg`) are created within the Dockerfile and are compared during validation
  - If a new package is installed when running the container interactively, this fails. So the validation of the original state works.

- `docker build -t bagtainers/0004 0004/data/container/.`
- `docker run --rm -it -v $(pwd)/0004:/bag:ro -v /tmp/o2r_run:/o2r_run:rw bagtainers/0004`

## 0005
An adaption of `0004`, with the change that the generated output is not plain markdown, but a PDF which is compared with the R package `pdftools` by extracting the text from the PDF.
- See [http://ropensci.org/blog/2016/03/01/pdftools-and-jeroen](http://ropensci.org/blog/2016/03/01/pdftools-and-jeroen)
  - output format was changed to `pdf_document` and other output files were removed
  - install additional packages in Dockerfile
  - extension of `Bagtainer.R` script
  - local testing snippets
    - `compare(pdf_text(pdf = "lab02-solution.pdf"), pdf_text("/tmp/o2r_run/85C6CkRzuR_20160322_161239/wd/lab02-solution.pdf"), allowAll = TRUE)`
    - `diffpdf /home/daniel/git/bagtainers/0005/data/wd/lab02-solution.pdf /tmp/o2r_run/85C6CkRzuR_20160322_161239/wd/lab02-solution.pdf`
      - **Comparison issue**: Because of different page margins, it is not always the same text on all pages, pages 1 to 4 differ.
      - Multiple pages with collapse works (for some page ranges, namely those without any changes of text at beginning or end): `compare(paste(pdf_text(pdf = "lab02-solution.pdf")[14:17], collapse = ""), paste(pdf_text("/tmp/o2r_run/85C6CkRzuR_20160322_161239/wd/lab02-solution.pdf")[14:17], collapse = ""), allowAll = TRUE)`
      - `cat(paste(pdf_text(pdf = "lab02-solution.pdf")[13:14], collapse = ""), "#########\n", paste(pdf_text("/tmp/o2r_run/85C6CkRzuR_20160322_161239/wd/lab02-solution.pdf")[13:14], collapse = ""))`
      - `paste0` or `unlist` also do not change anything - take a break!
      - **Intermediate solution**: copy the PDF generated by the container to the wd in the container, then also `identical` works on the PDF contents
      - Test if it catches the change in timezone (disable the `TZ` environment variable in the configuration file): _yes, but_ only if `compare(..., allowAll = FALSE)`, so there seems to be some test that removes the time zone difference.

- Move all packages that deal with comparison to the R script (out of the "user" configuration file)
- The output of the run is `tee`d to a file `/o2r_run/o2r_<YYYYMMDD-HHMMSS>.log` using two environment variables, because variables within variables did not work
- Changed the code to follow the linter... probably should have disabled the linter instead.

## 0007
With respect to content, it contains the source code of the dtwSat R package originally from [GitHub](https://github.com/vwmaus/dtwSat). Not to clutter this repo with the nested repository, we clone the original repo and check out the respective tag as a precommand. The repo *should* of couse be there already, but is not in this case to have the nested repo in the bagtainer repository. Instead, we only have the files of interest there.

On execution, the downloaded checked out package is installed, and the README document, which is R-markdown (`.Rmd`), contained in that repository is knitted. The output overwrites the already existing (because they are in the repo) output files `README.md` with graphics in `figures`. For comparison, we limit this example to the created markdown file and all other files are then deleted with a postcommand.

- `Bagtainer.R` and `Bagtainer.yml` are based on `0005`. The changes are...
  - `precommand`s added to clone a repo and check out the required branch
    - install also the suggested packages and add `rgdal` as suggested packages to `dtwSat`, to fix the transitive suggest-dependency to `rgdal` via `raster`
    - https://github.com/vwmaus/dtwSat/issues/1
  - `postcommand` to move the file to be compared out of the downloaded repo, which is deleted.
- **Challenge**: When installing the package from source, it requires quite a few dependencies, some of which have system dependencies, which cannot be installed automatically.
  - Could solve these by trial and error, though databases with system requirements will help in the future
  - Fix issue with Debian mirrors when running apt-get install in different cached layers of a Dockerfile, see http://stackoverflow.com/questions/35923576/debian-httpredir-mirror-system-unreliable-unusable-in-docker
- **Issues** during re-run of the analysis
  - "pandoc: Filter pandoc-citeproc not found \n Error: pandoc document conversion failed with error 85"
    - Install system dependency `pandoc-citeproc` > fixed
  - `rgdal` is not a dependecy in the package, but is needed, see https://github.com/vwmaus/dtwSat/issues/1 - add as suggested package
    - can install suggested packages, but dependencies = TRUE does NOT install suggested packages of dependencies.
  - `ggplot2` is not properly loaded by the RMarkdown document, see https://github.com/vwmaus/dtwSat/issues/1 - load the package in the document
- Validation of the input bag with `bagit-python` from within the `Bagtainer.R` file
  - https://github.com/LibraryOfCongress/bagit-python
  - Using a script copied to the container at `/validate.py`
  - Alternatively could just use `bagit.py --validate /bag` but would not be able to exit with 1 then
  - As argued in `0006`, the container might actually not be the best place to do this.

- Build and run with the `Makefile` in the project root, or go to bash:
  - `make bagtainer=0007`
  - `make bagtainer=0007 cmd=/bin/bash`

## 0007-1

A variant of `0007` with intentional changes to file `data/wd/README.md` to check the diff functionality.

- `make bagtainer=0007-1`

## 0009
Content of this bag is based on the JStatSoft paper "spacetime: Spatio-Temporal Data in R" by Edzer Pebesma.

- https://www.jstatsoft.org/article/view/v051i07
- https://github.com/edzer/spacetime
