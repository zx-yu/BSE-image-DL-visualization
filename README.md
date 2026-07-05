# MATLAB Code for Image Dataset Preparation, CNN Training, and Grad-CAM Visualization

Copyright © 2026 Zix Yu

Licensed under the GNU General Public License, version 3 only.  
SPDX-License-Identifier: GPL-3.0-only

See the `LICENSE` file in the repository root for the complete license text.

The GPL-3.0 license applies only to the author-developed source code in this repository. MATLAB and its toolboxes are proprietary software distributed under their respective licenses.

## 1. Overview

This repository contains MATLAB scripts used to prepare an image dataset, train a convolutional neural network (CNN), and generate gradient-weighted class activation mapping (Grad-CAM) visualizations.

The workflow consists of three scripts:

1. `Image_augment_and_database_establishment.m`  
   Crops and rotates the original images to establish the training image database.

2. `Model_Training.m`  
   Defines and trains the CNN using MATLAB Deep Learning Toolbox.

3. `CAMvisualization.m`  
   Loads a trained CNN model, classifies image patches, generates Grad-CAM maps, and overlays the maps on the corresponding image patches.

---

## 2. Software Requirements

The scripts require:

- MATLAB
- Deep Learning Toolbox
- Image Processing Toolbox

---

## 3. Recommended Repository Structure

Place the scripts, trained model, example images, and license file in the following structure:

```text
repository_root/
│
├── README.md
├── LICENSE
├── Image_augment_and_database_establishment.m
├── Model_Training.m
├── CAMvisualization.m
├── v0TrainingResults_220_20240728185754.mat
│
├── New_images/
│   ├── 1/
│   │   └── example_class_1.tif
│   ├── 2/
│   │   └── example_class_2.tif
│   ├── 3/
│   │   └── example_class_3.tif
│   └── 4/
│       └── example_class_4.tif
│
└── TrainingImage_220/
    ├── 1/
    ├── 2/
    ├── 3/
    └── 4/

---

## 4. Script Functions

### 4.1 `Image_augment_and_database_establishment.m`

#### Purpose

This script establishes the image database used for CNN training.

#### Main operations

For each of the four sample classes, the script:

1. Reads all `.tif` images from:

   ```text
   New_images/<class number>/
   ```

2. Converts each image to double precision.

3. Retains the first image channel and crops the image height to the first 884 pixels.

4. Rotates the image.

5. Divides each rotated image into non-overlapping `220 × 220` pixel patches.

6. Saves the patches.

---

### 4.2 `Model_Training.m`

#### Purpose

This script trains a CNN to classify four image classes.

#### Main operations

The script:

1. Loads all training patches from `TrainingImage_220`.

2. Uses the folder names as class labels.

3. Randomly selects up to 1,000 patches from each class.

4. Divides the selected images.

5. Defines a CNN with five convolutional blocks.

6. Trains the network using the Adam optimizer.

7. Evaluates classification accuracy on the test dataset.

8. Saves the trained network and associated workspace variables to a timestamped `.mat` file.

---

### 4.3 `CAMvisualization.m`

#### Purpose

This script provides a reproducible Grad-CAM example using one trained model and the first original image found in a manually selected class folder.

It performs patch-level classification, marks correct and incorrect predictions with different border colors, and overlays a Grad-CAM relevance map on each image patch.

#### Main operations

The script:

1. Loads .mat file.

2. Reads the image-patch size.

3. Uses the manually specified true class.

4. Reads the first `.tif` image.

5. Extracts a `4 × 5` grid of `220 × 220` pixel patches from the image.

6. Classifies each of the 20 patches using the trained CNN.

7. Compares the predicted class index `I` with the specified true class index `SampleName`.

8. Calculates a Grad-CAM map for the predicted class of each patch.

9. Overlays each Grad-CAM map on its corresponding image patch.

10. Saves each patch-level visualization as a separate `.tif` file.

---

## 5. How to Run the Quick Test

### Step 1: Prepare an example image

Place at least one `.tif` image in the folder corresponding to its true class.

### Step 2: Set the true class

Open `CAMvisualization.m` and set:

```matlab
SampleName = 1;
```

Valid values are:

```text
1, 2, 3, or 4
```

The selected value determines both:

- the image folder to be read;
- the true class used in the `I == SampleName` validation.

### Step 3: Confirm the model filename

Ensure that the following model file is present in the repository root:

```text
v0TrainingResults_220_20240728185754.mat
```

The script loads this model using:

```matlab
load v0TrainingResults_220_20240728185754
```

### Step 4: Run the script

Run CAMvisualization.m

## 6. Expected Quick-Test Results

After successful execution, the script generates 20 Grad-CAM visualization files in the MATLAB current working directory:

```text
CAM-1-1.tif
CAM-1-2.tif
...
```

The total number of generated files is:

```text
4 rows × 5 columns = 20 image patches
```

Each output image should contain:

- the corresponding `220 × 220` image patch;
- a green border if `I == SampleName`;
- a red border if `I ~= SampleName`;
- a semi-transparent Grad-CAM overlay for the predicted class;
- a title reporting the true and predicted class indices, if enabled in the script.

A successful quick test confirms that:

1. the trained network can be loaded;
2. the example image can be read;
3. the image can be divided into 20 patches;
4. every patch can be classified;
5. the correct/incorrect comparison can be performed;
6. Grad-CAM maps can be calculated and exported.

---

## 7. Grad-CAM Output Location

The generated Grad-CAM images are saved in the MATLAB current working directory.

When the MATLAB Current Folder is set to the repository root containing `CAMvisualization.m`, the output files are generated in the same directory as the script.

Example output path:

```text
repository_root/CAM-1-1.tif
```

No additional output directory is created automatically.

---

## 8. Reproducing Model Training

To retrain the model:

1. Arrange the original images under `New_images/1` to `New_images/4`.

2. Run:

   ```matlab
   Image_augment_and_database_establishment
   ```

3. Confirm that the generated patches are present under:

   ```text
   TrainingImage_220/
   ```

4. Ensure that `stopIfAccuracyNotImproving.m` is available, or remove the associated `OutputFcn` option.

5. Run:

   ```matlab
   Model_Training
   ```

6. MATLAB will generate a new model file such as:

   ```text
   v0TrainingResults_220_20260702123000.mat
   ```

7. Update the `load` command in `CAMvisualization.m` if a new model filename is used.

---

## 9. Notes on Reproducibility

- The supplied `.mat` file is a trained model and is sufficient for running the Grad-CAM example.
- The folder name is used as the class label during model training.
- The comparison `I == SampleName` assumes that the order of the network output classes corresponds to the numeric class labels `1`, `2`, `3`, and `4`.
- The quick-test script reads only the first `.tif` image returned from the selected class folder.
- The example image must contain a usable region of at least `880 × 1100` pixels.
- The image-preparation script may generate different numbers of patches after 90° and 270° rotation if the usable image dimensions are not exact multiples of 220.
- Random dataset splitting means that retraining may produce slightly different model parameters and accuracy values unless a fixed random-number seed is specified.
- The provided code demonstrates the computational workflow used for image classification and Grad-CAM visualization.
- Confidential experimental datasets are not required to run the supplied quick test.
- The trained model file may be large; users should verify that it is stored directly in the repository or through an appropriate large-file mechanism supported by the repository platform.

---

## 10. Computer Code Availability Statement

The image preprocessing, convolutional neural-network training, and Grad-CAM visualization scripts used in this study are openly available from this public repository. The repository contains individual MATLAB source files, a trained example model (`v0TrainingResults_220_20240728185754.mat`), usage instructions, and an example workflow for generating Grad-CAM outputs.

The network was constructed and trained using MATLAB Deep Learning Toolbox. The Grad-CAM images are saved in the MATLAB current working directory, which corresponds to the repository root when the scripts are run as instructed.

MATLAB and its toolboxes are proprietary software. The author-developed scripts in this repository are freely available for download, inspection, and reuse under the GNU General Public License v3.0 only.

---

## 11. Suggested Citation

When using or adapting this code, please cite the associated research article:

*Quantitative recognition and analysis of rock microstructure deterioration under freeze-thaw cycles: A metal-intrusion-integrated deep-learning approach*
