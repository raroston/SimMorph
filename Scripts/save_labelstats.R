# Calculate & save labelStats from MEMOS segmentations
# Author: Rachel A. Roston, Ph.D.

# SETUP
library(ANTsR)
library(ANTsRCore)
library(viridis)
library(stringr)
library(ggplot2)

source("./Scripts/SimMorph_setup_variables.R")

# save labelStats() output tables
for(j in 1:length(simulations)){

  experiment = simulations[j]
  addvols = c(19,20,50,51) # labels to combine into new column (e.g., TotalHeart is c(19,20,50,51))
  addvols.name = "TotalHeart" # name of new column (e.g. "TotalHeart")
  
  dir.exp.data = paste0(dir.data, "/", experiment, "/")
  dir.vol.results = "./Results/OrganVolumes/labelVols/"
  if(!dir.exists(dir.vol.results)) dir.create(dir.vol.results)
  dir.seg.stats.results = paste0("./Results/OrganVolumes/labelStats/", experiment)
  dir.create(dir.seg.stats.results)
  
  imgs.exp = list()
  segments.exp = list()
  n = 0
  for(i in 1:length(subjects)){
    n = n + 1
    imgs.exp[[n]] = antsImageRead(paste0(dir.exp.data, "/", images, "/", subjects[i], "_", experiment, ".nrrd"))
    segments.exp[[n]] = antsImageRead(paste0(dir.exp.data, "/MEMOS/", subjects[i], "_", experiment, ".seg.nrrd"))
    segments.exp[[n]] = resampleImageToTarget(image = segments.exp[[n]], target = imgs.exp[[n]], interpType = "genericLabel")
  }
  
  seg.stats.exp = list()
  for(i in 1:length(subjects)){
    seg.stats.exp[[i]] = labelStats(imgs.exp[[i]], segments.exp[[i]])
  }
  names(seg.stats.exp) <- paste0(subjects, "_", experiment)

  for(i in 1:length(seg.stats.exp)){
    seg.stats.exp[[i]] <- data.frame(labelNames, seg.stats.exp[[i]])
    write.csv(seg.stats.exp[[i]], paste0(dir.seg.stats.results, "/", names(seg.stats.exp[i]), "_labelStats.csv" ))
  }
}