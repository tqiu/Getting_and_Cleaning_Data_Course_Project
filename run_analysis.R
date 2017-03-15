### Download the data
mywd <- "/media/tuoling/Data/course/MOOC/Data_Science_coursera/cleaning_data/"
setwd(mywd)
if(!file.exists("dataset")) dir.create("dataset")
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile="dataset.zip", method="curl")
unzip(zipfile="dataset.zip", exdir="dataset")


### 1. Merges the training and the test sets to create one data set.

## Set current working directory
setwd(paste0(mywd, "dataset/UCI HAR Dataset"))
## Read and merge the training and test sets to create one data set
train <- read.table("train/X_train.txt")
test <- read.table("test/X_test.txt")
combine <- rbind(train, test)


### 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

## Read all feature (variable) names
feature <- read.table("features.txt")
## Extract the index of variables with only the measurements on the mean and standard deviation
feature_index <- grep("mean\\(|std\\(", feature$V2)
## Use the indices to subset the variables
extract <- combine[,feature_index]


### 3. Uses descriptive activity names to name the activities in the data set

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


### 4. Appropriately labels the data set with descriptive variable names. 

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


### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

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

