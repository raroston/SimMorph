# Setup SimMorph Variables
# Author: Rachel A. Roston, Ph.D.

library(stringr)

# Files and lists
original = "baseline"
experiments = read.csv("./ProjectDesign/experimentlist.csv")
heart.sims = experiments[grep("Heart", experiments$simulation),]
subjects = read.csv("./ProjectDesign/subjects.csv")[,2]
ref = "./Data/Reference/Embryo_Atlas.nii"
reflms = "./Data/Reference/Embryo_Atlas.mrk.json"
reflabels = "./Data/Reference/Embryo_Atlas_labels.nii"
labelNames = read.csv("./ProjectDesign/komp_label_conversion.csv")
samplesizes = seq(3,27,by = 3)

# Directories
dir.data = "./Data"
dir.original = paste0("./Data/", original)
images = "CT"
landmarks = "LMs"