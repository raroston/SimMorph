# Calculate number of voxels detected in TBM results
# Author: Rachel A. Roston, Ph.D.
# Data: 2024-04-03

remove(list = ls())
gc()

library(ANTsR)
library(stringr)

wd = "/home2/rachel/P01/syntheticdata/Github/SimMorph/Results/TBM/"
setwd(wd)

permutations = dir(wd, "Permutation_N")

for(i in 1:length(permutations)){
  results = data.frame()
  imgs = list()
  
  files = dir(permutations[i], "betaImg", full.names = TRUE)
  
  for(j in 1:length(files)){
    
    print(j)
    
    imgs[[j]] = antsImageRead( files[j] )
    
    positive = sum(imgs[[j]] > 0)
    negative = sum(imgs[[j]] < 0)
    
    tmp.results = data.frame(files[j], negative, positive)
    results = rbind(results, tmp.results)
  }
  
  write.csv(results, paste0("permutations_detection_results_", permutations[i], ".csv"))
  
}
