require(yaml)

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


###############
# load packages
sapply(X = bagtainer$packages, FUN = require, character.only = TRUE)


##################
# run the analysis
cat("[o2r] Running in", getwd(), "using configuration:\n");
print(bagtainer)


command <- parse(text = bagtainer$command)
if(is.expression(command)) {
  cat("[o2r] Evaluating command '", toString(command), "'\n", sep = "")
  eval(command)
}

##########
# clean up
unlink(".Rhistory")


##########################
# compare input and output
digest_directory <- function(dir) {
  .files <-  list.files(dir, recursive = TRUE, full.names = TRUE)
  allDigests <- sapply(X = .files, FUN = digest, file = TRUE, algo = "sha256")
  names(allDigests) <- .files
  return(allDigests)
}

file.size_directory <- function(dir) {
  .files <- list.files(dir, recursive = TRUE, full.names = TRUE)
  allDigests <- sapply(X = .files, FUN = file.size)
  names(allDigests) <- normalizePath(.files)
  return(allDigests)
}

# file hashes
if(o2r_isRunningInBagtainer()) {
  hashes_original <- digest_directory(dir = file.path(bagtainer$bag_mount, "data/wd"))
} else {
  hashes_original <- digest_directory(dir = getwd())
}
cat("[o2r] digests of original:\n")
print(hashes_original)

hashes_run_output <- digest_directory(dir = file.path(run_directory))
cat("[o2r] digests of run output:\n")
print(hashes_run_output)

# file sizes
cat("[o2r] file sizes of original:\n")
if(o2r_isRunningInBagtainer()) {
  print(file.size_directory(dir = file.path(bagtainer$bag_mount, "data/wd")))
} else {
  print(file.size_directory(dir = getwd()))
}
cat("[o2r] file sizes of run output:\n")
print(file.size_directory(dir = run_directory))

# cmp


# actual comparison
for (i in seq(along=hashes_original)) {
  cat("[o2r] comparing", names(hashes_original[i]), "with", names(hashes_run_output[i]), "\n")
  # identical even compares names - they are useful for debugging, so strip them before comparison
  .orig <- hashes_original[i]
  names(.orig) <- NULL
  .run <- hashes_run_output[i]
  names(.run) <- NULL
  stopifnot(identical(.orig, .run))
}
cat("[o2r] reproduction successful using container", Sys.getenv("HOSTNAME", unset = "not_in_bagtainer!"), "\n")

