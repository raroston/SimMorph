# TBM minimum sample size and permutations
# Author: Rachel A. Roston
# Date: 2024-06-20

remove(list = ls())
gc()

library(ANTsR)
library(stringr)

wd = "/SimMorph/"
setwd(wd)

source("Scripts/Repository/jacobianStats.R")
source("Scripts/Repository/makePermutationSets.R")

eN = 21 #for sample size n=21

# Make permutations and save as a .csv
  # maxOverlap = 15 #maximum overlapping subjects between sets
  # sampleorder = makeSets(1:30,
  #                       nsamples = eN,
  #                       nsets = 5,
  #                       overlap = maxOverlap)
  # sampleorder = as.data.frame(sampleorder)
  # colnames(sampleorder) <- c(paste0("Trial0", 1:5))
  # write.csv(sampleorder, paste0(dir.out, "/N", eN, "_sampleorder.csv"))

# Run TBM analysis with multiple sets of subjects, 
ctrl = "baseline"
experiment = c("Heart173",
               "Heart133",
               "Heart116",
               "Heart51",
               "Heart73",
               "Heart85",
               "Rostrum120")
  
region = c("wholebody", "thorax")
maskfile = paste0("Masks/Embryo_Atlas_mask_", region, ".nrrd")
dir.data = "/SimMorph/Data/"
dir.out = paste0("Results/TBM/Permutation_N",eN, "/")
subjects = read.csv("/SimMorph/Project_Design/subjects.csv")[,2]

if(!dir.exists(dir.out)) dir.create(dir.out)

# Read jacs
sampleorder = paste0(dir.out, "/N", eN, "_sampleorder.csv")
ctrls = vector()
jacs.ctrls = list()

ctrls = paste0(dir.data, "/", ctrl, "/TBM/", subjects, "_", ctrl, "_Jacobian.nrrd")
file.exists(ctrls)
for(i in 1:length(ctrls)) jacs.ctrls[[i]] = antsImageRead(ctrls[i])


for(z in 1:length(experiment)){
  
  for(m in 1:length(maskfile)){
    
    print(paste("Maskfile exists:", file.exists(maskfile[m])))
    mask = antsImageRead(maskfile[m])
    
    for(k in 1:ncol(sampleorder)){
      muts = vector()
      jacs.muts = list()
      jacs = list()
      
      muts = paste0(dir.data, experiment[z], "/JacobianDeterminants/", subjects[sampleorder[,k]], "_", experiment[z], "_Jacobian.nrrd")
      file.exists(muts)
      for(n in 1:length(muts)) jacs.muts[[n]] = antsImageRead(muts[n])
      
      jacs = c(jacs.ctrls, jacs.muts)
      groupIDs = as.factor(c(rep(ctrl, length(ctrls)), rep(experiment[z], length(muts))))
      groupIDs = relevel(groupIDs, ctrl)
      
      jacobianStats(jacobians = jacs, 
                    groups = groupIDs, 
                    binaryLabel = mask, 
                    PadjustMethod = "fdr", 
                    outputFolder = dir.out, 
                    filePrefix = paste0(experiment[z], "_", ctrl, "_", 
                                        region[m],
                                        "_fdr_e",
                                        eN, 
                                        "-c30_", 
                                        colnames(sampleorder)[k]))
    }
  }
}
