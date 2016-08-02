
#Getting And Cleaning Data Project

##Introduction

The project involves an experiment in human activity recognition. 30 subjects participated in the experiment. During the process, they wore a smartphone on the waist and participated in six activities, namely walking, walking upstairs, walking downstairs, sitting, standing and laying. The smartphone records data by using its embedded accelerometer and gyroscope when subjects are active. The purpose of the project is to clean the raw data and prepare a tidy dataset for later analysis. 

##Data
Data for the project can be found here:  
    https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Information about the data can be found here:  
    http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

##Code Book
The `CodeBook.md` file describes the data in detail.

##Reproducing the Project Results
Executing the script `run_analysis.R` from the repository directory will do the following:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set.
4. Appropriately labels the data set with descriptive activity names.
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.


##Results
After successful execution the script should create two files:

1. `mergedData.txt` - merged and cleaned up data set
2. `tidyMeanData.txt` - tidy data with average of each variable for each activity and each subject

Both data sets stored in comma separated text files.  See `CodeBook.md` for a more detailed description.
