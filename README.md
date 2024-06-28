# Simulated Morphology

This repository contains data and scripts for "The use of morphological simulation to test the limits on phenotype discovery in 3D image analysis": 

## Detailed instructions to reproduce the analysis in "The use of morphological simulation to test the limits on phenotype discovery in 3D image analysis":
### Setup, registration, and generation of simulated morphology data
1. Make a local copy of this repository
2. Run [setup_templateDownload.R](https://github.com/raroston/SimMorph/blob/main/Scripts/setup_templateDownload.R) to set up the directory structure and download the Wong et al. (2012) reference image.
3. Download the 30 baseline subjects from www.mousephenotype.org/embryoviewer/:
   - Search for any gene in the Interactive Embryo Viewer (e.g., "Acvr2a")
   - Click on the **Download embryo data** button
   - Find and download the subjects included in the [subjects list](https://github.com/raroston/SimulatedMorphology/blob/main/ProjectDesign/subjects.csv)
   - Save the image files to the directory "/SimMorph/Data/baseline/CT/"
4. Register the 30 subjects to the reference image with [registration_originalimages.R](https://github.com/raroston/SimMorph/blob/main/Scripts/registration_originalimages.R)
5. Generate simulated morphology images with [create-simulated-data.R](https://github.com/raroston/SimMorph/blob/main/Scripts/create-simulated-data.R)
   - Unmerged and merged pseudolandmark datasets for creating simulated deformations are in **"SimMorph/Deformations/"**

### Heart volume measurements and violin plot
6. Heart volume results for each subject are in the directory **"SimMorph/Results/OrganVolumes/"**. To replicate these results from scratch:
   - Install the MEMOS extension in 3D Slicer
   - To run MEMOS on baseline and simulated CT data, navigate to the MEMOS module in 3D Slicer and click on the "Batch mode" tab. 
   - Set the directories:
     - Volume directory: **"SimMorph/Data/[folder]/CT/"** (e.g., "/SimMorph/Data/baseline/CT/")
     - Output directory: **"SimMorph/Data/[folder]/MEMOS/"** (e.g., "/SimMorph/Data/baseline/MEMOS/")
   - Click "Apply"
   - Repeat this for each set of CT volumes (original baseline CT volumes and simulated CT volumes)
   - Calculate the organ volumes and heart volumes with [save_labelstats.R](https://github.com/raroston/SimMorph/blob/main/Scripts/save_labelstats.R)
   - Calculate the heart volumes with [save_volstats_plot.R](https://github.com/raroston/SimMorph/blob/main/Scripts/save_volstats_plot.R)

### Tensor-based morphometry 
7. Register the simulate morphology images to the reference image and calculate the Jacobian determinants with [registration_simulatedimages.R](https://github.com/raroston/SimMorph/blob/main/Scripts/registration_simulatedimages.R)
