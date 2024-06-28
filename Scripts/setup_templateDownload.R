# Set up SimMorph
# Author: Rachel A. Roston, Ph.D.

# Create directory structure
directories = c("./Data/baseline/CT",
                "./Data/Atlas")
lapply(X = directories, FUN = dir.create)

#Download reference image

download.file(url = "http://repo.mouseimaging.ca/repo/Embryo_Atlas_CT_E15.5_nifti/final.model.nii", 
              destfile = "./Data/Reference/Embryo_Atlas.nii", 
              method = "curl")
download.file(url = "http://repo.mouseimaging.ca/repo/Embryo_Atlas_CT_E15.5_nifti/Embryo_Atlas_labels.nii", 
              destfile = "SimMorph/Data/Reference/Embryo_Atlas_labels.nii", 
              method = "curl")