# Getting and Cleaning Data Course Project
### Author: Tuoling Qiu
### Date: Mar. 15, 2017

## This repo includes the following files:
* README.md

* tidy_data.txt: this is a tidy data set.  
The average of each variable of the original data set for each activity and each subject were computed.

* CodeBook.md:
describes the variables, values of the new tidy data set and the work I performed to clean up the data as required by the project.

* run_analysis.R: the R script I used to clean up the data. 
To use it, please change "mywd" variable at the top of the file to your own working directory.
and run it in R with: source("run_analysis.R"). This script downloads the original data, cleans up the data, and writes a new tidy data set "tidy_data.txt" inside the "UCI HAR Dataset" folder it creates.

* The original data set can be downloaded from the following link:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip


