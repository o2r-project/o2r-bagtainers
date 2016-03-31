require(yaml)
require(digest)
require(compare)
require(pdftools)

bagtainer <- NA
run_directory <- NA
setwd("~")

##################
# helper functions
o2r_loadConfig <- function(directory = NA, filename = Sys.getenv("O2R_CONFIG_FILE", unset = "Bagtainer.yml")) {
  .file <- NA
  if(is.na(directory)) {
    .file <- normalizePath(filename)
  } else {
    .file <- normalizePath(file.path(directory, filename))
  }
  cat("[o2r] Loading configuration file", .file, "\n")
  .bagtainer <- yaml::yaml.load_file(.file)
  return(.bagtainer)
}

# via http://stackoverflow.com/questions/3452086/getting-path-of-an-r-script
o2r_pathFromCommandArgs <- function(args = commandArgs()) {
  cat("[o2r] Command: ", tail(commandArgs(trailingOnly = FALSE), n = 1), "\n")
  m <- regexpr("(?<=^--file=).+", args, perl=TRUE)
  scriptDir <- dirname(regmatches(args, m))
  cat("[o2r] Detected path:", scriptDir, "\n")
  return(scriptDir)
}

o2r_isRunningInBagtainer <- function(o2rVersionEnvironmentVariable = "O2R_VERSION") {
  return(!is.na(Sys.getenv(o2rVersionEnvironmentVariable, unset = NA)))
}


########################################################
# load configuration file and set the workding directory
if(o2r_isRunningInBagtainer()) {
  cat("[o2r] Running IN Bagtainer\n")
  # running in Bagtainer > load config from same path as this script
  bagtainer <- o2r_loadConfig(directory = o2r_pathFromCommandArgs());

  # create a clone of the working directory
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S", digits.secs = 1)
  run_directory <- file.path(bagtainer$run_mount, paste0(bagtainer$id, "_", timestamp))
  dir.create(run_directory)

  .from <- file.path(bagtainer$bag_mount, "data", bagtainer$data$working_directory)
  file.copy(from = .from, to = run_directory,
            recursive = TRUE, copy.date = TRUE, copy.mode = TRUE)
  setwd(file.path(run_directory, bagtainer$data$working_directory))
} else {
  # not running in Bagtainer, set wd relative to this file's directory and create the original analysis
  .fileDir <- getSrcDirectory(function(x) {x})
  bagtainer <- o2r_loadConfig(directory = .fileDir);
  setwd(file.path(.fileDir, bagtainer$data$working_directory))
}

run_directory <- getwd()


################################################
# set environment variables and dump environment
if(is.list(bagtainer$environment)) {
  do.call(Sys.setenv, bagtainer$environment)
}

cat("[o2r] Runtime environment:\n")
system("uname -a")
cat("\n")
system("cat /etc/debian_version")
cat("\n")
system("cat /etc/issue")

print(Sys.getenv())
print(sessionInfo())


##################################
# compare the package environments
if(o2r_isRunningInBagtainer()) {
  cat("[o2r] Comparing installed software...\n")
  apt_testfile <- "apt-installed-test.txt"
  system(paste0("apt --installed list > ", apt_testfile))

  apt_file <- file.path("/apt-installed.txt")
  comparison_apt <- compare::compare(
    readLines(apt_file),
    readLines(apt_testfile),
    allowAll = TRUE)
  cat("[o2r] Compared apt installed packages:\n")
  print(summary(comparison_apt))
  if(!comparison_apt$result) {
    cat("[o2r] apt packages diff:\n")
    system(paste("diff", apt_file, apt_testfile))
  }
  unlink(apt_testfile)
  stopifnot(comparison_apt$result)

  dpkg_file <- file.path("/dpkg-list.txt")
  dpkg_testfile <- "dpkg-list-test.txt"
  system(paste0("dpkg -l > ", dpkg_testfile))
  comparison_dpkg <- compare::compare(
    readLines(dpkg_file),
    readLines(dpkg_testfile),
    allowAll = TRUE)
  cat("[o2r] Compared DPKG list:\n")
  print(summary(comparison_dpkg))
  if(!comparison_dpkg$result) {
    cat("[o2r] DPKG packages diff:\n")
    system(paste("diff", dpkg_file, dpkg_testfile))
  }
  unlink(dpkg_testfile)
  stopifnot(comparison_dpkg$result)
}
# not comparing if running in development environment

########################
# validate the input bag
validate_cmd <- paste("python3 /validate.py", bagtainer$bag_mount)
cat("[o2r] Validating bag with system command '", validate_cmd, "'\n", sep = "")
validate_result <- system(validate_cmd, wait = TRUE)
cat("[o2r] Validation returned result '", validate_result, "' (",
  capture.output(str(validate_result)), ")\n", sep = "")
stopifnot(0 == validate_result)

###############
# load packages
cat("[o2r] Loading packages from configuration file...\n")
sapply(X = bagtainer$packages, FUN = require, character.only = TRUE)


############################
# check the version settings
cat("[o2r] o2r version", Sys.getenv("O2R_VERSION"), ",",
  bagtainer$version, "(ENV,yml)\n")
stopifnot(identical(Sys.getenv("O2R_VERSION"), as.character(bagtainer$version)))


##################
# run the analysis
cat("[o2r] Running in", getwd(), "using configuration:\n");
print(bagtainer)

if(is.atomic(bagtainer$precommand) || is.list(bagtainer$precommand)) {
  lapply(X = as.list(bagtainer$precommand), FUN = function(x) {
    expr <- parse(text = x)
    if(is.expression(expr)) {
      cat("[o2r] Evaluating precommand '", toString(x), "'\n", sep = "")
      eval(expr)
    } else {
      stop("[o2r] The supplied precommand is not an expression: ", x)
    }
  })
} else {
  cat("[o2r] No precommand(s)\n")
}

command <- parse(text = bagtainer$command)
if(is.expression(command)) {
  cat("[o2r] Evaluating command '", toString(command), "'\n", sep = "")
  eval(command)
} else {
  stop("[o2r] The supplied command is not an expression: ", command)
}

if(is.atomic(bagtainer$postcommand) || is.list(bagtainer$postcommand)) {
  lapply(X = as.list(bagtainer$postcommand), FUN = function(x) {
    expr <- parse(text = x)
    if(is.expression(expr)) {
      cat("[o2r] Evaluating postcommand '", toString(x), "'\n", sep = "")
      eval(expr)
    } else {
      stop("[o2r] The supplied postcommand is not an expression: ", x)
    }
  })
} else {
  cat("[o2r] No precommand(s)\n")
}

##########
# clean up
unlink(".Rhistory")


##########################
# compare input and output
file.size_directory <- function(dir, recursive = TRUE) {
  .files <- list.files(dir, recursive = recursive, full.names = TRUE)
  if(!recursive) {
    .files <- .files[!file.info(.files)$isdir] # remove directories
  }
  allDigests <- sapply(X = .files, FUN = file.size)
  names(allDigests) <- normalizePath(.files)
  return(allDigests)
}

digest_directory <- function(dir, recursive = TRUE) {
  .files <- list.files(dir, recursive = recursive, full.names = TRUE)
  if(!recursive) {
    .files <- .files[!file.info(.files)$isdir] # remove directories
  }
  allDigests <- sapply(X = .files, FUN = digest, file = TRUE, algo = "sha256")
  names(allDigests) <- .files
  return(allDigests)
}

# file hashes
if(o2r_isRunningInBagtainer()) {
  hashes_original <- digest_directory(
    dir = file.path(bagtainer$bag_mount, "data/wd"), recursive = FALSE)
} else {
  hashes_original <- digest_directory(dir = getwd(), recursive = FALSE)
}
cat("[o2r] digests of original:\n")
print(hashes_original)

hashes_run_output <- digest_directory(
  dir = file.path(run_directory), recursive = FALSE)
cat("[o2r] digests of run output:\n")
print(hashes_run_output)

# file sizes
cat("[o2r] file sizes of original:\n")
if(o2r_isRunningInBagtainer()) {
  sizes_orig <- file.size_directory(
    dir = file.path(bagtainer$bag_mount, "data/wd"), recursive = FALSE)
} else {
  sizes_orig <- file.size_directory(dir = getwd(), recursive = FALSE)
}
print(sizes_orig)
cat("[o2r] file sizes of run output:\n")
sizes_run <- file.size_directory(dir = run_directory, recursive = FALSE)
print(sizes_run)

# actual comparison of file sizes
for (i in seq(along=sizes_orig)) {
  if(regexpr(pattern = "\\.pdf$", text = names(sizes_orig[i])) > 0) {
    # skip pdf file
    next;
  }

  cat("[o2r] comparing file size of", names(sizes_orig[i]),
    "with", names(sizes_run[i]), "\n")
  # identical even compares names - they are useful for debugging, so strip them before comparison
  .orig <- sizes_orig[i]
  names(.orig) <- NULL
  .run <- sizes_run[i]
  names(.run) <- NULL
  .identical <- identical(.orig, .run)
  if(!.identical) {
    cat("[o2r] files differ:\n")
    system(paste("diff", names(sizes_orig[i]), names(sizes_run[i])))
  }

  stopifnot(identical(.orig, .run))
}

# actual comparison of hashes
for (i in seq(along=hashes_original)) {
  if(regexpr(pattern = "\\.pdf$", text = names(sizes_orig[i])) > 0) {
    # skip pdf file
    next;
  }

  cat("[o2r] comparing hashes of", names(hashes_original[i]),
    "with", names(hashes_run_output[i]), "\n")
  # identical even compares names - they are useful for debugging, so strip them before comparison
  .orig <- hashes_original[i]
  names(.orig) <- NULL
  .run <- hashes_run_output[i]
  names(.run) <- NULL
  .identical <- identical(.orig, .run)
  if(!.identical) {
    cat("[o2r] files differ:\n")
    system(paste("diff", names(hashes_original[i]), names(hashes_run_output[i])))
  }

  stopifnot(identical(.orig, .run))
}

# compare PDFs
for (i in seq(along=hashes_original)) {
  if(regexpr(pattern = "\\.pdf$", text = names(sizes_orig[i])) < 0) {
    # skip pdf file
    next;
  }

  cat("[o2r] Comparing PDF contents of", names(hashes_original[i]),
    "with", names(hashes_run_output[i]), "\n")
  #pdf_info(pdf = "lab02-solution.pdf")
  #.toc <- pdf_toc(pdf = "lab02-solution.pdf") # complex list
  .orig <- pdf_text(pdf = names(hashes_original[i])) # one character string per page
  .run <- pdf_text(pdf = names(hashes_run_output[i])) # one character string per page

  .comparison <- compare::compare(.orig, .run, allowAll = FALSE)
  cat("[o2r] Compared PDF contents:\n")
  print(summary(.comparison))
  print(.comparison$partialTransform)

  stopifnot(.comparison$result)

  cat("[o2r] Compared PDF contents with identical:\n")
  stopifnot(identical(.orig, .run))
}


# some Travis CI logging
if(!is.na(Sys.getenv("TRAVIS", unset = NA))) {
  cat("[o2r] Ran on Travis (http://travis-ci.org - thanks!) as ",
      "build #", Sys.getenv("TRAVIS_BUILD_NUMBER"),
      " (id:", Sys.getenv("TRAVIS_BUILD_ID"), ") ",
      "with job #", Sys.getenv("TRAVIS_JOB_NUMBER"),
      "(id:", Sys.getenv("TRAVIS_JOB_ID"), ")",
      "\n", sep="")
}
cat("[o2r] reproduction successful using container",
  Sys.getenv("HOSTNAME", unset = "not_in_bagtainer!"), "\n")
