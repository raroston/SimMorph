# Calculate & save labelStats from MEMOS segmentations
# Author: Rachel A. Roston, Ph.D.
# Date: 2024-03-15

remove(list = ls())
gc()

library(ANTsR)
library(ANTsRCore)
library(viridis)
library(stringr)
library(ggplot2)

experiments = c("Heart173",
                "Heart133",
                "Heart116",
                "Heart51",
                "Heart73",
                "Heart85",
                "Rostrum120")

wd = "/home2/rachel/P01/syntheticdata/Github/SimMorph/"
setwd(wd)

# save labelStats() output as csv & save organ vols for each exp as csv
labelNames = read.csv("/ProjectDesign/komp_label_conversion.csv")
subjects = read.csv("/SimMorph/Project_Design/subjects.csv")
subjects = subjects[,2]

for(j in 1:length(experiments)){

  experiment = experiments[j]
  addvols = c(19,20,50,51) # labels to combine into new column (e.g., TotalHeart is c(19,20,50,51))
  addvols.name = "TotalHeart" # name of new column (e.g. "TotalHeart")
  
  dir.exp = paste0("/Data/", experiment, "/")
  dir.vol.results = "/Results/OrganVolumes/labelVols/"
  if(!dir.exists(dir.vol.results)) dir.create(dir.vol.results)
  dir.seg.stats.results = paste0("/Results/OrganVolumes/labelStats/", experiment)
  dir.create(dir.seg.stats.results)
  atlas = antsImageRead("/Data/Atlas/Embryo_Atlas.nii.gz")
  
  setwd(dir.exp)
  
  imgs.exp = list()
  segments.exp = list()
  n = 0
  for(i in 1:length(subjects)){
    n = n + 1
    imgs.exp[[n]] = antsImageRead(paste0("CT/", subjects[i], "_", experiment, ".nrrd"))
    segments.exp[[n]] = antsImageRead(paste0("MEMOS/", subjects[i], "_", experiment, ".seg.nrrd"))
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
  
