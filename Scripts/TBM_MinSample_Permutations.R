# TBM minimum sample size and permutations
# Author: Rachel A. Roston

# Setup
library(ANTsR)
library(stringr)

source("./Scripts/SimMorph_setup_variables.R")
source("./Scripts/jacobianStats.R")

ctrl = original
experiments = simulations
region = c("wholebody", "thorax")
maskfiles = paste0("./Masks/Embryo_Atlas_mask_", region, ".nrrd")


# Run TBM analysis with multiple sets of subjects

for(i in 1:length(samplesizes)){
  eN = str_pad(samplesizes[i], 2, "left", "0")
  sampleorder = paste0(dir.out, "/N", eN, "_sampleorder.csv")

  dir.out = paste0("./Results/TBM/Permutation_N",eN, "/")
  if(!dir.exists(dir.out)) dir.create(dir.out)
  
  # Read jacs
  ctrls = vector()
  jacs.ctrls = list()
  
  ctrls = paste0(dir.data, "/", ctrl, "/TBM/", subjects, "_", ctrl, "_Jacobian.nrrd")
  file.exists(ctrls)
  for(j in 1:length(ctrls)) jacs.ctrls[[j]] = antsImageRead(ctrls[j])
  
  for(z in 1:length(experiments)){
    for(m in 1:length(maskfiles)){
      
      print(paste("Maskfile exists:", file.exists(maskfiles[m])))
      mask = antsImageRead(maskfiles[m])
      
      for(k in 1:ncol(sampleorder)){
        muts = vector()
        jacs.muts = list()
        jacs = list()
        
        muts = paste0(dir.data, "/", experiments[z], "/JacobianDeterminants/", subjects[sampleorder[,k]], "_", experiments[z], "_Jacobian.nrrd")
        file.exists(muts)
        for(n in 1:length(muts)) jacs.muts[[n]] = antsImageRead(muts[n])
        
        jacs = c(jacs.ctrls, jacs.muts)
        groupIDs = as.factor(c(rep(ctrl, length(ctrls)), rep(experiments[z], length(muts))))
        groupIDs = relevel(groupIDs, ctrl)
        
        jacobianStats(jacobians = jacs, 
                      groups = groupIDs, 
                      binaryLabel = mask, 
                      PadjustMethod = "fdr", 
                      outputFolder = dir.out, 
                      filePrefix = paste0(experiments[z], "_", ctrl, "_", 
                                          region[m],
                                          "_fdr_e",
                                          eN, 
                                          "-c30_", 
                                          colnames(sampleorder)[k]))
      }
    }
  }
}