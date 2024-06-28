# Setup SimMorph Variables
# Author: Rachel A. Roston, Ph.D.

# Files and lists
original = "baseline"
simulations = read.csv("./ProjectDesign/experimentlist.csv")[,2]
heart.sims = simulations[grep("Heart", simulations)]
subjects = read.csv("./ProjectDesign/subjects.csv")[,2]
ref = "./Data/Reference/Embryo_Atlas.nii"
reflms = "./Data/Reference/Embryo_Atlas.mrk.json"
reflabels = "./Data/Reference/Embryo_Atlas_labels.nii"
labelNames = read.csv("./ProjectDesign/komp_label_conversion.csv")
heart.sims = read.csv("./ProjectDesign/experimentlist.csv")[1:7,2:4]

# Directories
dir.data = "./Data"
dir.original = paste0("./Data/", original)
images = "CT"
landmarks = "LMs"