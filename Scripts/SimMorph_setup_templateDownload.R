# Initial setup of SimMorph
# Author: Rachel A. Roston, Ph.D.

# Create directory for baseline images. Download baseline images from www.mousephenotype.org
directories = c("./Data/baseline/CT")
lapply(X = directories, FUN = dir.create)

#Download reference image files
download.file(url = "http://repo.mouseimaging.ca/repo/Embryo_Atlas_CT_E15.5_nifti/final.model.nii", 
              destfile = "./Data/Reference/Embryo_Atlas.nii", 
              method = "curl")
download.file(url = "http://repo.mouseimaging.ca/repo/Embryo_Atlas_CT_E15.5_nifti/Embryo_Atlas_labels.nii", 
              destfile = "./Data/Reference/Embryo_Atlas_labels.nii", 
              method = "curl")