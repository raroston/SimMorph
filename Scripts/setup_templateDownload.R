# Set up SimMorph
# Author: Rachel A. Roston, Ph.D.

wd = "" #Working directory of repository clone
setwd(wd)

# Create directory structure
directories = c("SimMorph/Data/baseline/CT",
                "SimMorph/Data/Atlas")
lapply(X = directories, FUN = dir.create)

#Download reference image

download.file(url = "http://repo.mouseimaging.ca/repo/Embryo_Atlas_CT_E15.5_nifti/final.model.nii", 
              destfile = "SimMorph/Data/Template/E15_template.nii", 
              method = "curl")
download.file(url = "http://repo.mouseimaging.ca/repo/Embryo_Atlas_CT_E15.5_nifti/Embryo_Atlas_labels.nii", 
              destfile = "SimMorph/Data/Template/E15_template_labels.nii", 
              method = "curl")
