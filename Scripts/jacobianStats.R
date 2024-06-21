# Tensor Based Morphometry
# R.A. Roston & A.M. Maga
# 2024-03-28

jacobianStats <- function(jacobians,
                           groups,
                           binaryLabel,
                           P = 0.05,
                           PadjustMethod, # options: "none" or methods same as p.adjust()
                           outputFolder,
                           filePrefix){
  
  library(ANTsR)
  library(ANTsRCore)
  
  #set the regression
  print("Starting statistical analysis")
  j_mat = imageListToMatrix( jacobians, binaryLabel )
  j_mdl = lm( j_mat ~ groups)    # raw volume data
  j_bmdl = bigLMStats( j_mdl , 1.e-5 )
  print( min( p.adjust( j_bmdl$beta.pval, 'none' ) , na.rm=T ) )
  
  #do multiple corrections
  #P defines the significance level we want to evaluate things after FDR correction
  volstats = j_bmdl$beta.pval
  
  correct.ps= p.adjust(volstats, PadjustMethod)
  pImg = makeImage(binaryLabel, correct.ps)
  
  pMask = thresholdImage(pImg, 10^-16, P, 1, 0)
  betaImg = makeImage( mask, j_bmdl$beta ) * pMask
  
  print("Writing images")
  antsImageWrite(pImg, paste0(dir.out, filePrefix, "_pImg.nrrd"))
  antsImageWrite(betaImg, paste0(dir.out, filePrefix, "_betaImg.nrrd"))
  
}
