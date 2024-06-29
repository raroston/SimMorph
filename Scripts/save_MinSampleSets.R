# Script for creating sets of subjects for TBM min sample tests
# Author: Rachel A. Roston, Ph.D.

# Setup
library(stringr)

source("./Scripts/makeSets.R")
minsamplesets = read.csv("./ProjectDesign/TBM_minsample_sets.csv")

dir.out = "./Results/TBM"

for(i in 1:nrow(minsamplesets)){
  eN = minsamplesets[i,"samplesize"]
  sampleorder = makeSets(V=1:30, 
                nsamples = minsamplesets[i, "samplesize"], 
                overlap = minsamplesets[i,"max_overlap"],
                nsets = minsamplesets[i, "number_of_sets"])
  sampleorder = as.data.frame(sampleorder)
  colnames(sampleorder) <- c(paste0("Trial", 
                                    str_pad(1:minsamplesets[i,"number_of_sets"],
                                            width = 2,
                                            side = "left",
                                            pad = "0")))
  write.csv(sampleorder, paste0(dir.out, "/N", eN, "_sampleorder.csv"))
}
