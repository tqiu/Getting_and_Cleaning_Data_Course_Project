# CodeBook.md
### Author: Tuoling Qiu
### Date: Mar. 15, 2017

# Getting and Cleaning Data Course Project
### This markdown file describes the variables, values of the new tidy data set and the work I performed to clean up the data as required by the project.

## Description of the variables in the new data set
1. subject: numbering of subjects (1-30). The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years.
2. activity: there are 6 activities: WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING. Each person performed six activities wearing a smartphone (Samsung Galaxy S II) on the waist.
3. 66 other variables: their names are composed of the following words:
    + time: signals were captured in the time domain at a constant rate of 50 Hz
    + frequency: a Fast Fourier Transform (FFT) was applied to some of these signals producing      frequency domain signals
    + Body: related to body movement
    + Gravity: acceleration of gravity
    + Acceleration: accelerometer measurement
    + Gyroscope: gyroscopic measurements
    + Jerk: sudden movement acceleration
    + Magnitude: magnitude of movement
    + Mean and Std: mean and standard deviation for each measurement
    + X, Y or Z: signals in the X, Y or Z directions
    
    + The units given are g’s for the accelerometer and rad/sec for the gyro and g/sec and rad/sec/sec for the corresponding jerks.
    + **All values of these variables were averaged for each subject and each activity**
    + For example, the value on row2, column3 means that the mean of body linear acceleration for the 1st subject and "LAYING" activity measured in the time domain and in the X direction is 0.2215982 g.
    
To summarize, this new data set has 180 rows and 68 columns. 180 rows are composed of 30 subjects and 6 activities for each subject. Among the 68 columns, there are 1 subject numbering, 1 activity label, 33 mean and 33 standard deviation features. The data set contains the header for all variable names.
    
Reference: "features_info.txt" and "README.txt" provided in the data for the project:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
For more details about the original data, please refer to these files.

## Study design
### Download the data
```
mywd <- "/media/tuoling/Data/course/MOOC/Data_Science_coursera/cleaning_data/"
setwd(mywd)
if(!file.exists("dataset")) dir.create("dataset")
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile="dataset.zip", method="curl")
unzip(zipfile="dataset.zip", exdir="dataset")
```

### Files in folder "UCI HAR Dataset" that will be used are:
1. Subject files: test/subject_test.txt and train/subject_train.txt
2. Measurement files: test/X_test.txt and train/X_train.txt
3. Activity label files: test/y_test.txt, train/y_train.txt and activity_labels.txt
4. Variable names: features.txt

**The following R scripts are contained in run_analysis.R file**  

### 1. Merges the training and the test sets to create one data set.
```
## Set current working directory
setwd(paste0(mywd, "dataset/UCI HAR Dataset"))
## Read and merge the training and test sets to create one data set
train <- read.table("train/X_train.txt")
test <- read.table("test/X_test.txt")
combine <- rbind(train, test)
```

### 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
```
## Read all feature (variable) names
feature <- read.table("features.txt")
## Extract the index of variables with only the measurements on the mean and standard deviation
feature_index <- grep("mean\\(|std\\(", feature$V2)
## Use the indices to subset the variables
extract <- combine[,feature_index]
```

### 3. Uses descriptive activity names to name the activities in the data set
```
## Read activity label files
y_train <- read.table("train/y_train.txt")
y_test <- read.table("test/y_test.txt")
label <- read.table("activity_labels.txt")
## Convert the activity numbering (class: integer) to factors, with levels set to descriptive 
## activity names
y_train_factor <- factor(as.factor(y_train$V1), labels=label$V2)
y_test_factor <- factor(as.factor(y_test$V1), labels=label$V2)
## Concatenate factors and paste it to the extracted data frame as the first column
activity <- c(as.character(y_train_factor), as.character(y_test_factor))
extract_name <- cbind(activity, extract)
```

### 4. Appropriately labels the data set with descriptive variable names. 
```
## Load 'readr' package for the parse_number() function
library(readr)
## Extract variable names with only the measurements on the mean and standard deviation
names <- sapply(parse_number(names(extract)), function(x) feature[x,2])
## Modify the variable names to descriptive names
names <- as.character(names)
## Delete () and - in the names
names <- gsub("\\(\\)|-", "", names)
## Change the leading "t" and "f" to more descriptive words: time and frequency
names <- gsub("^t", "time", names)
names <- gsub("^f", "frequency", names)
## Change "Acc" to "Acceleration"
names <- gsub("Acc", "Acceleration", names)
## Capitalize the "mean" and "std"
names <- gsub("mean", "Mean", names)
names <- gsub("std", "Std", names)
## Change "Mag" and "Gyro" to the full words
names <- gsub("Mag", "Magnitude", names)
names <- gsub("Gyro", "Gyroscope", names)
## Remove the duplicate "Body"
names <- gsub("BodyBody", "Body", names)
## Assign names to the extracted data set
names(extract_name)[-1] <- names
```

### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
```
## Load 'dplyr' package for easy data reshaping
library(dplyr)
## Read subject numbering
subject_train <- read.table("train/subject_train.txt")
subject_test <- read.table("test/subject_test.txt")
subject_num <- rbind(subject_train, subject_test)
names(subject_num) <- "subject"
## Paste the suject numbering to the data frame as the first column
tidy_data <- cbind(subject_num, extract_name)
## Calculate the average of each variable for each subject and each activity
tidy_data <- tidy_data %>% group_by(subject, activity) %>% summarise_each(funs(mean))
## write the new data set to "tidy_data.txt" file
write.table(tidy_data, file="tidy_data.txt", row.names = FALSE)
```
