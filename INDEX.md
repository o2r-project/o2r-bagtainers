## 0001

Minimal Rnw file from https://github.com/yihui/knitr/blob/master/inst/examples/knitr-minimal.Rnw

Commands are run from the bag base directory `0001`.

### Create and save the analysis - the steps

* Directory structure was manually created
* Output was created using knitr in the script file `Bagtainer.R`
  * ` Rscript -e "source('data/Bagtainer.R')"` (automatic directory resolving only works with source afaics)
  * if run outside of a container, the script will write to `output`, otherwise to a newly created directory `output_YYYYMMDDHHMMSS`
* Dockerfile was manually created
* Image was manually saved using the following commands
```bash
ID=$(docker images -q bagtainer-0001)
docker save --output $ID.tar bagtainer-0001:latest
```
* Remove the image with `docker rmi 8d1075752e2e`
* Bag was created "in place" with Bagger

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
