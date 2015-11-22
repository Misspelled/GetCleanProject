---
title: "README"
author: "Geoff Clark"
date: "November 20, 2015"
output:
  html_document:
    keep_md: yes
    self_contained: no
    smart: no
---
## Overview
This repository contains the script and data to load and manipulate raw data collected from Samsung Galaxy S smartphone accelerometers.The data was collected on a group of 30 volunteers performing a   discrete number of activities while wearing smartphones. Measurements were 3-axial linear acceleration and 3-axial angular velocity. The data has been randomly partitioned into two sets, with 70% of the subjects generating training data and 30% generating test data.

## Data
Data used by the script is comprised of the following:

*   Two text files in the repository main directory used for variable labels, `activity_labels.txt` and `features.txt`
*   Six text files in two subdirectories for measurement and categorical variables
    +   Three files in the `test` folder named `subject_test.txt`, `X_test.txt` and `y_test.txt`
    +   Three files in the `train` folder similarly named with 'train' replacing 'test' in the file names 
Data files contained in the `Inertial Signal` subdirectories of both `test` and `train` are not used in this exercise. 

## Script
The main tasks of the accompanying script are as follows:

1.  Loading measurement, attribute and variable name data from flat text files from the main and sub directory folders of the repository
2.  Combining categorical and measurement data into a common table for both test and train data sets
3.  Combining test and train tables into one master data set
4.  Subsetting the measurement variables to include only mean and standard deviation measurements
5.  Cleaning variable names to ensure readability and consistency
6. Creating a separate 'wide' format transformation containing one record (row) for each subject with all measurements in column form

To run this script you must ensure the files *and* subdirectories detailed in Data section are present in the working directory. Then simply source the script file run_analysis.R.


