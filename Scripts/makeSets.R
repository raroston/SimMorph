# Function to make sets for permutaton tests
# Author: Rachel A. Roston, Ph.D.

makeSets = function(V, nsamples, nsets, overlap){
  sets = list()
  for(i in 1:nsets){
    if(i == 1) {
      sets[[i]] = sample(x = V, size = nsamples, replace = F)
    } else if (i*nsamples <= length(V)) {
      remaining = V[-unlist(sets)]
      sets[[i]] = sample(x = remaining, size = nsamples, replace = F)
    } else {
      a = 0
      while(sum(a) < length(a)){
        s = sample(1:30, nsamples)
        for(j in 1:length(sets)){
          a[j] = length(intersect(s, sets[[j]])) < overlap
        }
        sets[[i]] = s
      }
    }
  }
  return(sets)
}