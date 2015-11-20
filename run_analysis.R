
require(dplyr)

## load test data
xtest <- read.table(file="test/X_test.txt")
ytest <- read.table(file="test/y_test.txt")
names(ytest) <- "response"
stest <- read.table(file="test/subject_test.txt")
names(stest) <- "subject"
test <- dplyr::bind_cols(list(stest, ytest, xtest))

## load train data
xtrain <- read.table(file="train/X_train.txt")
ytrain <- read.table(file="train/y_train.txt")
names(ytrain) <- "response"
strain <- read.table(file="train/subject_train.txt")
names(strain) <- "subject"
train <- dplyr::bind_cols(list(strain, ytrain,xtrain))

## combine to master table 
master <- dplyr::bind_rows(list(test, train))

## load variable names for identification of std and mean variables
labels <- as.character(read.table(file="features.txt")[[2]])
keepIndex <- grep("(std\\(\\))|([Mm]ean\\(\\))",labels)

master <- master[,c(1:2, keepIndex + 2)]
labels <- labels[keepIndex]

##clean variable names of punctuation chars
## and change to camelCase
labels <- gsub("(\\(\\))|-","",labels)
labels <- gsub("mean","Mean",labels)
labels <- gsub("std","Std",labels)
names(master)[3:ncol(master)] <- labels

## clean Global Env
rm(list=ls()[!(ls() == "master")])

## load activiites and match
act <- read.table("activity_labels.txt")
names(act) <- c("ind", "activity")
master <- master %>% inner_join(act, by=c("response"="ind")) %>% select(-response) 

library(reshape2)
# construct variable means and final tidy data set
tdy <- master %>% group_by(subject, activity) %>% summarise_each(funs(mean))
tdy_cast <- tdy %>% melt(id.vars=c("subject","activity")) %>% dcast(subject ~ variable + activity)

write.table(tdy_cast, "tidy.txt", row.names = FALSE)
