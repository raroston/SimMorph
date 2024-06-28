
# e15 Embryo Registrations in Parallel for simulated morphology images
# Authors: R.A. Roston & A.M. Maga

library(doParallel)
library(foreach)
library(ANTsR)

# SETUP
source("./Scripts/SimMorph_setup_variables.R")

save.TotalTransforms = TRUE
save.CT_transformed = TRUE
save.Jacobian = TRUE

# FUNCTIONS
source("/Scripts/doRegistration.R")

# Generate list of subjects to be registered
done = vector()
for(i in 1:length(simulations)){
  if( dir.exists(paste0(dir.data, "/", simulations[i], "/Transforms/"))){
    if( dir.exists(paste0(dir.data, "/", simulations[i], "/Transforms/affine/"))){
      tmp = dir(paste0(dir.data, "/", simulations[i], "/Transforms/affine/"))
      tmp = gsub("_Affine.mat", "", tmp)
      done = c(done,tmp)
    }
  }
}
allsubs = paste0(rep(subjects,each=length(simulations)),"_", simulations)
toDo = allsubs[which(!allsubs %in% done)]

# Check files exist for all subjects
if(!all(file.exists(paste0(images, subjects, ".nrrd")))){
  print("Missing images!")
  stop()
}

if(!all(file.exists(paste0(landmarks, subjects, ".mrk.json")))){
  print("Missing LMs!")
  stop()
}


# DO PARALLEL REGISTRATIONS
# This will the registration 8 times (1:8) in batches of 4 (PSOCK cluster setting.)
# Set up how many jobs are going to run in parallel & working directory

Sys.setenv(ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS = 48)
ncluster <- 4 # set up how many jobs run in parallel
nthreads <- 12 # limit number of cores for each task

cl <- makePSOCKcluster(ncluster)
Sys.setenv(ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS = nthreads)
registerDoParallel(cl)

foreach (i = 1:length(subjects)) %dopar% {doRegistration(subject = subjects[i],
                                                         ref.img.path = ref,
                                                         ref.lms.path = reflms,
                                                         dir.imgs = images,
                                                         dir.lms = landmarks,
                                                         dir.out = dir.original,
                                                         save.TotalTransforms = TRUE,
                                                         save.CT_transformed = TRUE,
                                                         save.Jacobian = FALSE,
                                                         test = FALSE)
}

stopCluster(cl)

# make sure you execute stopCluster(cl) line. Otherwise resources assigned to the job will not be released
# and you might get confused about how many jobs you are running. 
