# Create Simulated Data from PsuedoLMs
# Author: Rachel A. Roston, Ph.D.

library(ANTsR)
library(ANTsRCore)
library(SlicerMorphR)

# SETUP
source("./Scripts/SimMorph_setup_variables.R")
dir.deform = "./Deformations/LMs_merged"

simulations = experiments[which(experiments$createSimData == TRUE),]

# GENERATE SIMULATED DATA
for(j in 1:nrow(simulations)){
  dir.sim = paste0("./Data/", simulations[j, "simulation"])
  
  if(!dir.exists(dir.sim)) dir.create(dir.sim)
  if(!dir.exists(paste0(dir.sim, "/", images))) dir.create(paste0(dir.sim, "/", images))
  if(!dir.exists(paste0(dir.sim, "/", landmarks))) dir.create(paste0(dir.sim, "/", landmarks))
  
    # Create simulated deformation from unmobdified pseudoLMs and modified pseudoLMs using bSpline
    originalLMs = read.markups.json(dir(dir.deform,
                                        pattern = paste0(simulations[j, "simulation"], "_og"),
                                        full.names = TRUE))
    modLMs = read.markups.json(dir(dir.deform,
                                   pattern = paste0(simulations[j, "simulation"], "_def"),
                                   full.names = TRUE))
    
    
    # Get simulated deformation transform from originalLMs and modLMs
    exp.tx = fitTransformToPairedPoints(movingPoints = originalLMs, 
                                       fixedPoints = modLMs, 
                                       transformType = "bspline", 
                                       domainImage = ref.img, 
                                       meshSize = 4, 
                                       numberOfFittingLevels = 6)
    
    # Transform the reference image w/the simulated deformation transform
    d.ref.img = applyAntsrTransformToImage(transform = exp.tx, 
                                               image = ref.img, 
                                               reference = ref.img, 
                                               interpolation = "bspline")
    antsImageWrite(d.ref.img, 
                   filename = paste0("./Data/Reference/", simulations[j, "simulation"], "-","ref.nrrd"))
    
    # Apply simulated deformation transform to subjects in reference image space
    affine.tx = vector()
    fwd.tx = vector()
    inv.tx = vector()
    for(i in 1:length(subjects)){
      affine.tx[i] = paste0(dir(paste0(dir.original, "/Transforms/affine"), 
                             pattern = subjects[i],
                             full.names = TRUE))
      
      fwd.tx[i] = paste0(dir(paste0(dir.original, "/Transforms/fwd"), 
                             pattern = subjects[i],
                             full.names = TRUE))
      
      inv.tx[i] = paste0(dir(paste0(dir.original, "/Transforms/inv"), 
                             pattern = subjects[i],
                             full.names = TRUE))
    }
  
    
    # Transform subjects to reference image space
    # Apply simulated deformation to subjects in reference image space
    # Transform subjects from reference image space back to subject space
    imgs.tx = list()
    imgs.sim.tx = list()
    for(i in 1:length(subjects)) {
      tmp.img = antsImageRead(dir(paste0(dir.original, "/", images), 
                                  pattern = subjects[i],
                                  full.names = TRUE))
      imgs.tx[[i]] = antsApplyTransforms(fixed = ref.img,
                                         moving = tmp.img,
                                         transformlist = c(fwd.tx[[i]], affine.tx[[i]]),
                                         interpolator = "linear")
      imgs.sim.tx[[i]] = applyAntsrTransformToImage(transform = exp.tx,
                                                    image = imgs.tx[[i]], 
                                                    reference = d.ref.img,
                                                    interpolation = "linear")
      tmp = antsApplyTransforms(fixed = antsImageRead(dir(paste0(dir.original, "/", images),
                                                          subjects[i],
                                                          full.names = TRUE)),
                                moving = imgs.sim.tx[[i]], 
                                transformlist = c(affine.tx[i], inv.tx[i]),
                                "linear")
      tmp = tmp*255
      antsImageWrite(tmp, filename = paste0(dir.sim, "/", images, "/", subjects[i], "_", simulations[j, "simulation"], ".nrrd"))
    }
  
    
  # copy original LMs for registration initialization
  # NOTE: only do this if the simulation does not affect landmark placement
  if(simulations$copy.LMs[j] == TRUE){
    for(i in 1:length(subjects)){
      file.copy(from = paste0(dir.original, "/", landmarks, "/", subjects[i], "_", original, ".mrk.json"),
                to =paste0(dir.sim, "/", landmarks, "/", subjects[i], "_", simulations[j, "simulation"], ".mrk.json"))
    }
  }
}