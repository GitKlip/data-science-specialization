
Code Book
=========

#Input Data

The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:
    
* `http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones`

Data set used is available by url:
    
* `https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip`.

For a detailed description of files and data sets please see `README.txt` in the zip archive.  Following is a brief overview of the relevant files:

1. Under the 'UCI HAR Dataset' directory are the following files:
    1. README.txt - describes how the data is structured in great detail. start here
    1. features_info.txt - describes the columns of the main data set.  very useful.
    1. features.txt - is a listing of the 561 column names in the main data set
    1. activity_labels.txt - gives the word labels for the numeric values in y_test.txt 
1. Under the 'train' and 'test' folders we find identical structues
    1. X_test.txt - the main data set with 561 *unlabeled* columns
        1. fixed width: 1 empty space. 1 char for +/- indicator. 14 chars for number. repeated 561 times
    1. y_test.txt - single column with the numeric values for the activities
    1. subject_test.txt - single column with numeric values for the subject that created each observation
    

#Data Transformations

Following transformations were performed by `run_analysis.R` script:

1. Download data from URL and unzip file.
1. Identify desired columns which have 'mean()' or 'std()' in their names
1. create dataframes for both 'train' and 'test' folders
    1. load X_*.txt data, subset to keep the desired columns, apply column labels
    1. join subject_*.txt to X_*.txt (numeric person id)
    1. join y_*.txt to X_*.txt (numeric activity id)
1. Union Train and Test datasets vertically
1. Join the character labels to the merged dataframe
1. write the merged data set to file 'mergedData.txt'
1. Create second data set with the average(mean) of each variable for each activity and each subject.
1. write the aggregate data set to file 'tidyMeanData.txt'


#Output Data

Two files are created from the run_analysis.R script: 

1. `mergedData.txt`
    1. merged and cleaned data set created from the raw data
    1. .txt file with comma separated values
    1. 10299 obs. of  69 variables with file size of ~8MB
1. `tidyMeandata.txt`
    1. tidy data with average(mean) of each variable for each activity and each subject
    1. .txt file with comma separated values
    1. 180 obs. of  68 variables with file size of ~220KB


