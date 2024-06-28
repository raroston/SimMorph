# Calculate heart volumes from labelStats tables
# Author: Rachel A. Roston, Ph.D.

# SETUP
library(ANTsR)
library(ANTsRCore)
library(viridis)
library(stringr)
library(ggplot2)

source("./Scripts/SimMorph_setup_variables.R")
dir.vol.results = "./Results/OrganVolumes"


# save heart volume tables

for(j in 1:length(simulations)){
  files = dir(paste0(dir.vol.results, "/labelStats/", simulations[j]), full.names = TRUE)
  seg.stats.exp = list()
  for(i in 1:length(files)) {seg.stats.exp[[i]] = read.csv(files[i])}
  subjects = lapply(str_split(files, "/"), "[", 12)
  subjects = gsub("_labelStats.csv", "", subjects)
  names(seg.stats.exp) <- subjects

  exp.vol.data = matrix(nrow = length(seg.stats.exp), ncol = length(seg.stats.exp[[1]]$Volume))

  for(i in 1:length(seg.stats.exp)){
    exp.vol.data[i,] = seg.stats.exp[[i]]$Volume
  }
  exp.vol.data = as.data.frame(exp.vol.data, row.names = names(seg.stats.exp))
  colnames(exp.vol.data) <- paste0("Label_", seg.stats.exp[[1]]$LabelValue)
  
  exp.vol.data[,addvols.name] <- exp.vol.data[addvols[1]]
  for(i in 2:length(addvols)){
    exp.vol.data[,addvols.name] = exp.vol.data[, addvols.name] + exp.vol.data[addvols[i]]
  }
  
  write.csv(exp.vol.data, paste0(dir.vol.results, "/", experiments[j], "_labelVols.csv"))
  
}