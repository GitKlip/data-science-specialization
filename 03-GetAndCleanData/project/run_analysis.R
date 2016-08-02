
#####  Download and Extract data from Zip File -----------------------------------------------------------------
if(!file.exists("UCI HAR Dataset")){
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    zipFileName <- "UCI_Human_Activity Recognition_data.zip"
    print(paste("downloading Zip File",fileUrl,"to",zipFileName,"..."))
    download.file(url = fileUrl, destfile = zipFileName, mode="wb")
    print("complete")
    print("UnZipping File...")
    unzip(zipfile = zipFileName)
    print("complete")
}

# Identify desired columns -----------------------------------------------------
#     Features_info.txt & requirement 3 tell us we need to look for columns with 'mean()' or 'std()' in their names
#     Features.txt has the column names for the 561 variables.
features <- "UCI HAR Dataset\\features.txt"
dfColNames <- read.table(features, sep = " ", col.names = c("colNum","name"))

# add logical column for desired field names
dfColNames$keep <-  grepl( pattern = "std\\(\\)|mean\\(\\)", x = dfColNames$name,  perl = TRUE)

# add width values for desired field names (negatives will be ignored to read.fwf)
dfColNames <- transform(dfColNames, colWidths = ifelse(keep, 16, -16))


# PROCESS TRAIN DATA -----------------------------------------------------
numRows = -1L #used for testing on smaller data set (-1L is for no limit)

# load X_train.txt, subset by columns, apply column labels from features.txt
xTrain <- "UCI HAR Dataset\\train\\X_train.txt"
dfXTrain <- read.fwf(xTrain,
                     n = numRows,
                     widths = dfColNames[,4],  #specifies both colWidths and which cols to keep
#                      col.names = dfColNames[dfColNames$keep,2],  #gives labels on cols to keep
                     buffersize = 500,      #limit number of rows at a time because the rows are so long
                     header = FALSE,
                     strip.white = TRUE )
colnames(dfXTrain) <- dfColNames[dfColNames$keep,2]

# Add subject_train.txt (Numeric person ID) to data table
trainSubjects <- "UCI HAR Dataset\\train\\subject_train.txt"
dfXTrain$subjectId<- read.table(trainSubjects, header = FALSE, col.names = "subject", nrows = numRows)[,1]

# Add y_train.txt (numeric activity label) to data table
trainActvities <- "UCI HAR Dataset\\train\\y_train.txt"
dfXTrain$activityId <- read.table(trainActvities, header = FALSE, nrows = numRows)[,1]

# PROCESS TEST DATA -----------------------------------------------------
# load X_test.txt, subset by columns, apply column labels from features.txt
xTest <- "UCI HAR Dataset\\test\\X_test.txt"
dfXTest <- read.fwf(xTest,
                     n = numRows,
                     widths = dfColNames[,4],  #specifies both colWidths and which cols to keep
#                      col.names = as.character(dfColNames[dfColNames$keep,2]),  #gives labels on cols to keep
                     buffersize = 500,      #limit number of rows at a time because the rows are so long
                     header = FALSE,
                     strip.white = TRUE )
colnames(dfXTest) <- dfColNames[dfColNames$keep,2]

# Add subject_test.txt (Numeric person ID) to data table
testSubjects <- "UCI HAR Dataset\\test\\subject_test.txt"
dfXTest$subjectId <- read.table(testSubjects, header = FALSE, col.names = "subject", nrows = numRows)[,1]

# Add y_test.txt (numeric activity label) to data table
testActvities <- "UCI HAR Dataset\\test\\y_test.txt"
dfXTest$activityId <- read.table(testActvities, header = FALSE, nrows = numRows)[,1]

# MERGE TEST & TRAIN -----------------------------------------------------

# Union Train and Test datasets vertically
DF <- rbind(dfXTrain, dfXTest)

# create an activity label factor by joining activity_labels.txt to the DF  data table
activityLabels <- "UCI HAR Dataset\\activity_labels.txt"
labels <- read.table(activityLabels, header = FALSE, col.names = c("id","activity"), nrows = numRows)
DF$activity <- labels[DF$activityId,2]

# Write Merged Dataset
write.table(DF, file = "mergedData.txt", sep=",", row.names = FALSE)

# Tidy Mean Data -----------------------------------------------------
#  Create second data set with the average(mean) of each variable for each activity and each subject.
DF2 <- aggregate.data.frame(DF[,c(as.character(dfColNames[dfColNames$keep,2]))],
                            FUN = mean, by = list( Activity = as.character(DF$activity), Subject = DF$subjectId),
                            simplify = TRUE )
write.table(DF2, file = "tidyMeanData.txt", sep=",", row.names = FALSE)


