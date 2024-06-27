
# e15 Embryo Registrations in Parallel for original images
# Authors: R.A. Roston & A.M. Maga
# Date: 2023-07-13

library(doParallel)
library(foreach)
library(ANTsR)

# SETUP

projectDirectory = "/SimMorph/"
wd = "/SimMorph/Data/original/"
setwd(wd)

file.subjects = "/SimMorph/ProjectDesign/subjects.csv"
images = paste0(wd, "CT/")
landmarks = paste0(wd, "LMs/")

save.TotalTransforms = TRUE
save.CT_transformed = TRUE
save.Jacobian = FALSE


# FUNCTIONS

source("/Scripts/doRegistration.R")


# Create vector of subjects

subjects = read.csv(file.subjects)
subjects = subjects[,2]

if( dir.exists(paste0(wd, "/Transforms/")) ){
  if( dir.exists(paste0(wd, "/Transforms/affine/")) ){
    done = dir(paste0(wd, "Transforms/affine/"))
    done = gsub("_Affine.mat", "", done)
    subjects = subjects[which( ! subjects %in% done)]
  }
}

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
                                                         ref.img.path = paste0(projectDirectory, "/Data/Reference/Embryo_Atlas.nii.gz"),
                                                         ref.lms.path = paste0(projectDirectory, "/Data/Reference/Embryo_Atlas.mrk.json"),
                                                         dir.imgs = images,
                                                         dir.lms = landmarks,
                                                         dir.out = wd,
                                                         save.TotalTransforms = TRUE,
                                                         save.CT_transformed = TRUE,
                                                         save.Jacobian = FALSE,
                                                         test = FALSE)
  }

stopCluster(cl)

# make sure you execute stopCluster(cl) line. Otherwise resources assigned to the job will not be released
# and you might get confused about how many jobs you are running. 
