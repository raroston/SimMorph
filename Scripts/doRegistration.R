# Registration function
# Author: Rachel A. Roston, Ph.D.

doRegistration = function(subject, 
                          ref.img.path,
                          ref.lms.path,
                          dir.img, 
                          dir.lms, 
                          dir.out,
                          save.TotalTransforms = TRUE,
                          save.CT_transformed = TRUE,
                          save.Jacobian = FALSE,
                          test = FALSE) {
  
  
  library(SlicerMorphR)
  library(ANTsR)
  
  
  # INPUT SUBJECT FILES
  
  if(test == TRUE){
    print(dir.lms)
    print(dir.img)
  } else {
    tmp.lm <- read.markups.json(dir(dir.lms,
                                    pattern = subject,
                                    full.names = TRUE))
    tmp.img <- antsImageRead(dir(dir.img,
                                 pattern = subject,
                                 full.names = TRUE))
    tmp.img <- iMath(tmp.img, "Normalize")
  }
  

  if(test == TRUE){
    print(ref.lms.path)
    print(ref.img.path)
  } else {
    
    # INPUT ATLAS / REFERENCE FILES and MOVING IMG FILES
    ref.lm <- read.markups.json(ref.lms.path)
    ref.img <- antsImageRead(ref.img.path)
    ref.img <- iMath(ref.img, operation = "Normalize") #normalizes intensities to 0 1 range
    
    # REGISTRATION 
    lm.tx <- fitTransformToPairedPoints(fixedPoints = ref.lm, 
                                        movingPoints = tmp.lm,
                                        transformType = "Similarity", 
                                        domainImage = ref.img)
    
    affine = antsRegistration(fixed=ref.img, 
                              moving = tmp.img, 
                              typeofTransform = "Rigid", 
                              initialTransform = lm.tx)
    syn1 = antsRegistration(fixed=ref.img, 
                            moving = tmp.img, 
                            typeofTransform = "SyN", 
                            initialTransform = affine$fwdtransforms)
    
  }  
  
  dir.fwd.tx = paste0(dir.out, "/Transforms/fwd")
  dir.affine.tx = paste0(dir.out, "/Transforms/affine")
  dir.inv.tx = paste0(dir.out, "/Transforms/inv")
  
  if(test == TRUE){
    
    print(dir.fwd.tx)
    print(dir.affine.tx)
    print(dir.inv.tx)
    
  } else {
    if(!dir.exists(paste0(dir.out, "/Transforms"))){
      dir.create(paste0(dir.out, "/Transforms"))
    }
    if(!dir.exists(dir.fwd.tx)) dir.create(dir.fwd.tx)
    if(!dir.exists(dir.affine.tx)) dir.create(dir.affine.tx)
    if(!dir.exists(dir.inv.tx)) dir.create(dir.inv.tx)
    
    file.copy(from = syn1$fwdtransforms[1],
              to = paste0(dir.fwd.tx, "/", subject, "_Warp", ".nii.gz"))
    file.copy(from = syn1$fwdtransforms[2],
              to = paste0(dir.affine.tx, "/", subject, "_Affine", ".mat"))
    file.copy(from = syn1$invtransforms[2],
              to = paste0(dir.inv.tx, "/", subject, "_InverseWarp", ".nii.gz"))
    
    
    if(save.TotalTransforms == TRUE){
      
      dir.totaltransforms = paste0(dir.out, "/TotalTransforms")
      
      if(!dir.exists(paste0(dir.totaltransforms))){
        dir.create(paste0(dir.totaltransforms))
      }
      
      composite.transforms <- antsApplyTransforms(fixed = ref.img, 
                                                  moving = tmp.img,
                                                  transformlist = c(syn1$fwdtransforms[1], syn1$fwdtransforms[2]), 
                                                  interpolator = "linear",
                                                  compose = paste0(dir.totaltransforms, "/", subject, "_Total-"))
    }
    
    if(save.CT_transformed == TRUE){
      
      dir.img.transformed = paste0(dir.out, "/TransformedImgs")
      if(!dir.exists(paste0(dir.img.transformed))){
        dir.create(paste0(dir.img.transformed))
      } 
      
      composite.img <- antsApplyTransforms(fixed = ref.img,
                                           moving = tmp.img,
                                           transformlist = composite.transforms)
      antsImageWrite(composite.img, filename = paste0(dir.img.transformed, "/", subject, '_transformed.nrrd'))
    }
  }
  
  if(save.Jacobian == TRUE){
    
    # save jacobians
    jacs.file = paste0(subject, "_Jacobian.nrrd")
    
    dir.jacs = paste0(dir.out, "/TBM")
    if(!dir.exists(dir.jacs)) dir.create(dir.jacs)
    }
    
    if(test == TRUE){
      print(paste0(dir.jacs, "/", jacs.file))
    } else {
      tmp = createJacobianDeterminantImage( ref.img, syn1$fwdtransforms[1], doLog = TRUE, geom = TRUE )
      jacs.tmp = smoothImage( tmp, 2*antsGetSpacing(ref.img)[1], FALSE ) #smooth the edges
      antsImageWrite(image = jacs.tmp, 
                     filename = paste0(dir.jacs, jacs.file))
    }
}