# Calculate number of voxels detected in TBM results
# Author: Rachel A. Roston, Ph.D.

# Setup
library(ANTsR)
library(stringr)

results = dir("./Results")
permutations = dir("./Results/TBM/Permutation_N")

# Calculations
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
