---
title: "Codebook"
author: "Geoff Clark"
date: "November 20, 2015"
output:
  html_document:
    highlight: null
    keep_md: yes
    self_contained: no
    smart: no
    theme: null
---
## Variables and Units of Measure
Our data set comes from the accelerometer and gyroscope 3-axial raw signals `tAccXYZ` and `tGyroXYZ`. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (`tBodyAccXYZ` and `tGravityAccXYZ`) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (`tBodyAccJerkXYZ` and `tBodyGyroJerkXYZ`). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (`tBodyAccMag`, `tGravityAccMag`, `tBodyAccJerkMag`, `tBodyGyroMag`, `tBodyGyroJerkMag`). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing `fBodyAccXYZ`, `fBodyAccJerkXYZ`, `fBodyGyroXYZ`, `fBodyAccJerkMag`, `fBodyGyroMag`, `fBodyGyroJerkMag`. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

            __________________|_________________
            tBodyAccXYZ       | tBodyGyroXYZ
            tGravityAccXYZ    | tBodyGyroJerkXYZ
            tBodyAccJerkXYZ   | tBodyGyroMag
            tBodyAccMag       | tBodyGyroJerkMag
            tGravityAccMag    | fBodyGyroXYZ
            tBodyAccJerkMag   | fBodyGyroMag
            fBodyAccXYZ       | fBodyGyroJerkMag
            fBodyAccJerkXYZ   | fBodyAccJerkMag
            fBodyAccMag       |

While a number variables were estimated from these signals, only Mean and Standard deviation were kept in the master and transformed data sets 

`Mean`: Mean value
`Std`: Standard deviation

Additional vectors obtained by averaging the signals in a signal window sample. These are used on the angle variable:  
`gravityMean`  
`tBodyAccMean`  
`tBodyAccJerkMean`  
`tBodyGyroMean`  
`tBodyGyroJerkMean`  

The complete list of variables of each feature vector is available in 'features.txt'

## Script Operation

Test and train data exists in 3 files each for a total of 6 files. Files beginning with `X` are the continuous measurment data while the two other files are categorical data related to subject and activity. Below is the code to combine the three `test` files into one table. 

```
xtest <- read.table(file="test/X_test.txt")
ytest <- read.table(file="test/y_test.txt")
names(ytest) <- "response"
stest <- read.table(file="test/subject_test.txt")
names(stest) <- "subject"
test <- dplyr::bind_cols(list(stest, ytest, xtest))
```
We do the same operation on the training set and then merge into one master data set

```
master <- dplyr::bind_rows(list(test, train))
```

Now for some subsetting and variable name cleanup. The raw data is without meaning headers but we have descriptions in `features.txt`. We are interested only in variables describing Mean or Standard Deviation. Assuming the data is ordered in the same way as the labels, we can `grep` the relevant names from the descriptions and create a subsetting index to drop unwanted variables.

```
labels <- as.character(read.table(file="features.txt")[[2]])
keepIndex <- grep("(std\\(\\))|([Mm]ean\\(\\))",labels)
master <- master[,c(1:2, keepIndex + 2)] ##remember we added two columns above
labels <- labels[keepIndex]
```
The variable names have punctuation and are hard to read, so we clean them up here.

```
labels <- gsub("(\\(\\))|-","",labels)
labels <- gsub("mean","Mean",labels)
labels <- gsub("std","Std",labels)
names(master)[3:ncol(master)] <- labels ## we added two columns with good names already
```
Now we should get a meaninful name for the activity variable. Now it is represented by an integer. We load these names and create a table to join with `master`.

```
act <- read.table("activity_labels.txt")
names(act) <- c("ind", "activity")
master <- master %>% inner_join(act, by=c("response"="ind")) %>% select(-response) 
```
Our data has multiple observations per subject as measures. This is due to both repeated measurements over time and multiple measurements per activity. To get to one record per subject we have to both pivot and aggregate the data (mean). We first summarize our data with a grouped mean. We then use the `reshape2` package to first melt and then cast the data into the required shape. 

```
library(reshape2)
tdy <- master %>% group_by(subject, activity) %>% summarise_each(funs(mean))
tdy_cast <- tdy %>% melt(id.vars=c("subject","activity")) %>% dcast(subject ~ variable + activity)
write.table(tdy_cast, "tidy.txt", row.names = FALSE) ## write local table for upload
```