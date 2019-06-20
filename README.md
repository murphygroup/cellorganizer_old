# README

This is the official source code repository of [CellOrganizer](http://www.cellorganizer.org).

## Pre-requisites

* Matlab 2018b or newer
* Bioinformatics Toolbox
* Computer Vision System Toolbox
* Control System Toolbox
* Curve Fitting Toolbox
* Image Processing Toolbox
* Mapping Toolbox
* Optimization Toolbox
* Robust Control Toolbox
* Signal Processing Toolbox
* Simulink
* Simulink Design Optimization
* Statistics and Machine Learning Toolbox
* System Identification Toolbox
* Wavelet Toolbox

## Installation

To install CellOrganizer

1. Download the latest distribution from `http://www.cellorganizer.org` or  `http://murphylab.web.cmu.edu/software/CellOrganizer`.

2. Unzip the distribution into a folder of your choice.

3. Start Matlab and change the default directory to the folder chosen above.

4. Run setup

## Using CellOrganizer from the Matlab command line

Type `setup()` at the Matlab command prompt to add the relevant paths.  The main CellOrganizer commands are

  > img2slml

which trains a model from a set of images

and

  > slml2img

which synthesizes one or more image(s) from a trained model.

## Examples

There are a numbers of demo files that illustrate how to use CellOrganizer from the command line.  Type

  > demoinfo

to get a listing of available demos.
