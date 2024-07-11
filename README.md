# Simulated Morphology

This repository contains data and scripts for "The use of morphological simulation to test the limits on phenotype discovery in 3D image analysis": 

## Detailed instructions to reproduce the analysis:
### Setup, registration, and generation of simulated morphology data
1. Make a local copy of this repository. Run this analysis from the repository directory
2. Run [SimMorph_setup_templateDownload.R](https://github.com/raroston/SimMorph/blob/main/Scripts/setup_templateDownload.R) to download the Wong et al. (2012) reference image and labels and create the directory for baseline images.
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
   - Set the directories (you will need to create the MEMOS output directories):
     - Volume directory: **"SimMorph/Data/[folder]/CT/"** (e.g., "/SimMorph/Data/baseline/CT/")
     - Output directory: **"SimMorph/Data/[folder]/MEMOS/"** (e.g., "/SimMorph/Data/baseline/MEMOS/")
   - Click "Apply"
   - Repeat this for each set of CT volumes (all original baseline CT volumes and simulated CT volumes)
   - Calculate the organ volumes and heart volumes with [save_labelstats.R](https://github.com/raroston/SimMorph/blob/main/Scripts/save_labelstats.R)
   - Calculate the heart volumes with [save_volstats.R](https://github.com/raroston/SimMorph/blob/main/Scripts/save_volstats.R)
7. To plot heart volume results in a violin plot, use [plot_volstats.R](https://github.com/raroston/SimMorph/blob/main/Scripts/plot_volstats.R)

### Tensor-based morphometry (TBM)
8. Register the simulate morphology images to the reference image and calculate the Jacobian determinants with [registration_simulatedimages.R](https://github.com/raroston/SimMorph/blob/main/Scripts/registration_simulatedimages.R)
9. The sets of subjects to test minimum sample size and permutations in this study are located in "./Results/TBM". New sets can be generated with [save_MinSampleSets.R](https://github.com/raroston/SimMorph/blob/main/Scripts/save_MinSampleSets.R).
10. To do the statistical analyses, run [TBM_MinSample_Permutations.R](https://github.com/raroston/SimMorph/blob/main/Scripts/TBM_MinSample_Permutations.R). This will generate image volumes. To visualize the volumes:
    - Import the reference image and TBM result images into 3D Slicer
    - Import the [TMB color lookup table](https://github.com/raroston/SimMorph/blob/main/ProjectDesign/JacobianAnalysis.ctbl) into 3D Slicer
    - In the Volumes module, change the Active Volume to the desire result volume and select the TBM lookup table
    - In one of Slice Views, overlay the results volume over the reference image ([User Interface, 3D Slicer Documentation](https://slicer.readthedocs.io/en/latest/user_guide/user_interface.html#slice-view)). Now you can scroll through the slices and visualize the results.
11. To determine if any differences were detected, run [TBMDetection.R](https://github.com/raroston/SimMorph/blob/main/Scripts/TBMDetection.R)
