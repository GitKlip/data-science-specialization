### Download Zip Data (550MB)

if(!dir.exists("./data")) dir.create("./data")
fileUrl <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
zipFileName <- "./data/Coursera-SwiftKey.zip"
if(!file.exists(zipFileName)){
    print(paste("downloading Zip File",fileUrl,"to",zipFileName,"..."))
    download.file(url = fileUrl, destfile = zipFileName, mode="wb")
    print("UnZipping File...")
    unzip(zipfile = zipFileName, exdir="./data")
    print("complete")
}

###Extract Data from Zip
# ?readLines
# ?read.table
# # https://www.r-bloggers.com/easy-way-of-determining-number-of-linesrecords-in-a-given-large-file-using-r/
# file.info('data/Coursera-SwiftKey/final/en_US/en_US.twitter.txt')
# head(readLines('data/Coursera-SwiftKey/final/en_US/en_US.twitter.txt',skipNul = TRUE)) #slow, but works with files <50MB

# install.packages("data.table", dependencies = TRUE)
require(data.table)

#Read Full Files
n=100000  #read in n lines if desired
blogs <- fread('./data/final/en_US/en_US.blogs.txt', sep='\n', nrows=n, header=FALSE, encoding="UTF-8", showProgress=TRUE)
news <- fread('./data/final/en_US/en_US.news.txt', sep='\n', nrows=n, header=FALSE, encoding="UTF-8", showProgress=TRUE)
# twitter <- fread('./data/final/en_US/en_US.twitter.txt', sep='\n', nrows=n, header=FALSE, encoding="UTF-8",na.strings==c("NA","N/A","null"))
# twitter <- readLines('data/final/en_US/en_US.twitter.txt',skipNul = TRUE)
N <- -1
con <- file('data/final/en_US/en_US.twitter.txt', "r")
twitter <- data.table(readLines(con,skipNul = TRUE,n = N))  ## Read the file in
close(con)  ##It's important to close the connection when you are done

dim(blogs); dim(news); dim(twitter);

#Subset Random Sample (10% of total)
getPartialData <- function(df) {
    set.seed(12)
    return(df[sample(1:nrow(df))[1:round(nrow(df)/10)],]) #sample random 10%
}
blogs10 <- getPartialData(blogs)
news10 <- getPartialData(news)
twitter10 <- getPartialData(twitter)



#Split training data into training and validation datasets
# install.packages("caret", dependencies = TRUE)
# library(caret)
# set.seed(72719)
# inTrain <- createDataPartition(trn.all$classe, p = .75)[[1]]
# trn <- trn.all[ inTrain,]
# vld <- trn.all[-inTrain,]










# **Tips, tricks, and hints**
#
#     1. ***Loading the data in.*** This dataset is fairly large. We emphasize that you don't necessarily need to load the entire dataset in to build your algorithms (see point 2 below). At least initially, you might want to use a smaller subset of the data. Reading in chunks or lines using R's readLines or scan functions can be useful. You can also loop over each line of text by embedding readLines within a for/while loop, but this may be slower than reading in large chunks at a time. Reading pieces of the file at a time will require the use of a file connection in R. For example, the following code could be used to read the first few lines of the English Twitter dataset:
#     ```
# con <- file("en_US.twitter.txt", "r")
# readLines(con, 1)  ## Read the first line of text
# readLines(con, 1)  ## Read the next line of text
# readLines(con, 5)  ## Read in the next 5 lines of text
# close(con)  ##It's important to close the connection when you are done
# ```
# See the `?connections` help page for more information.
#
# 1. ***Sampling.*** To reiterate, to build models you don't need to load in and use all of the data. Often relatively few randomly selected rows or chunks need to be included to get an accurate approximation to results that would be obtained using all the data. Remember your inference class and how a representative sample can be used to infer facts about a population. You might want to create a separate sub-sample dataset by reading in a random subset of the original data and writing it out to a separate file. That way, you can store the sample and not have to recreate it every time. You can use the rbinom function to "flip a biased coin" to determine whether you sample a line of text or not.
#

# myF <- function(x){
# return(x+x)
# }
# myF(1)
# print(myF(3))
#
# z<-4+4
# z
# ```{r}

