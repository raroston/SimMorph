
# e15 Embryo Registrations in Parallel for original images
# Authors: R.A. Roston & A.M. Maga

library(doParallel)
library(foreach)
library(ANTsR)

# SETUP
source("./Scripts/SimMorph_setup_variables.R")

save.TotalTransforms = TRUE
save.CT_transformed = TRUE
save.Jacobian = FALSE

# FUNCTIONS
source("./Scripts/doRegistration.R")

# Generate list of subjects to be registered
if( dir.exists(paste0(dir.original, "/Transforms/"))){
  if( dir.exists(paste0(dir.original, "/Transforms/affine/"))){
    done = dir(paste0(dir.original, "/Transforms/affine/"))
    done = gsub("_Affine.mat", "", done)
    subjects = subjects[which(! subjects %in% done)]
  }
}

# Check files exist for all subjects
if(!all(file.exists(paste0("./Data/", original, "/", images, "/", subjects, "_baseline.nrrd")))){
  print("Missing images!")
  stop()
}

if(!all(file.exists(paste0("./Data/", original, "/", landmarks, "/", subjects, "_baseline.mrk.json")))){
  print("Missing LMs!")
  stop()
}


# DO PARALLEL REGISTRATIONS
# This will the registration 8 times (1:8) in batches of 4 (PSOCK cluster setting.)
# Set up how many jobs are going to run in parallel & working directory

Sys.setenv(ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS = 16)
ncluster <- 2 # set up how many jobs run in parallel
nthreads <- 8 # limit number of cores for each task

cl <- makePSOCKcluster(ncluster)
Sys.setenv(ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS = nthreads)
registerDoParallel(cl)

foreach (i = 1:length(subjects)) %dopar% {doRegistration(subject = subjects[i],
                                                         ref.img.path = ref,
                                                         ref.lms.path = reflms,
                                                         dir.img = paste0(dir.original, "/", images),
                                                         dir.lms = paste0(dir.original, "/", landmarks),
                                                         dir.out = dir.original,
                                                         save.TotalTransforms = TRUE,
                                                         save.CT_transformed = TRUE,
                                                         save.Jacobian = FALSE,
                                                         test = FALSE)
  }

stopCluster(cl)

# make sure you execute stopCluster(cl) line. Otherwise resources assigned to the job will not be released
# and you might get confused about how many jobs you are running. 
