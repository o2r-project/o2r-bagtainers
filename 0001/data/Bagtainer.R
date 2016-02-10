require(knitr)
# knit the input document
if(is.na(Sys.getenv("O2R_VERSION", unset = NA))) {
  setwd(paste0(dirname(sys.frame(1)$ofile), "/output"))
} else {
  timestamp <- format(Sys.time(), "%Y%m%d%H%M%S", digits.secs = 1)
  path <- paste0("/data/output_", timestamp)
  dir.create(path)
  setwd(path)
}
cat("[o2r] Running in ", getwd(), "\n")
knitr::knit(input = "../input/paper.Rnw")
system("pdflatex paper.tex")
# clean up other files
allfiles = list.files(ignore.case = TRUE, include.dirs = TRUE, recursive = TRUE)
pdfs = list.files(pattern = "\\.pdf$")
unlink(allfiles[!allfiles %in% pdfs], recursive = TRUE)
unlink(".Rhistory")