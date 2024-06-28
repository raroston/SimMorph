# Setup SimMorph Variables
# Author: Rachel A. Roston, Ph.D.

original = "baseline"
simulations = read.csv("./ProjectDesign/experimentlist.csv")[,2]
subjects = read.csv("./ProjectDesign/subjects.csv")[,2]
ref = "./Data/Reference/Embryo_Atlas.nii"
reflms = "./Data/Reference/Embryo_Atlas.mrk.json"
reflabels = "./Data/Reference/Embryo_Atlas_labels.nii"
images = "CT"
landmarks = "LMs"

dir.data = "./Data"
dir.original = paste0("./Data/", original)