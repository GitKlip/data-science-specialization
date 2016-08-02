

# Question 1
# The American Community Survey distributes downloadable data about United States
# communities. Download the 2006 microdata survey about housing for the state of
# Idaho using download.file() from here:
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv
# and load the data into R. The code book, describing the variable names is here:
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FPUMSDataDict06.pdf
# How many properties are worth $1,000,000 or more?
#
# 53  <-----ANSWER
# 2076
# 24
# 159
if(!file.exists("data")){dir.create("data")}
housing.file = "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
local.housing.file = "data\\housing.2006.idaho.data.csv"
housing.codebook = "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FPUMSDataDict06.pdf"

download.file(url = housing.file, destfile = local.housing.file)

DF <- read.table(file = local.housing.file, sep = ",", header = TRUE)

head(DF,1)
summary(DF)
typeof(DF)

library(sqldf)
sqldf("Select count(*) as cnt from DT where VAL>=24")

# library(data.table)
# DT <- data.table(DF)
# DT[,vAL==24]


# Question 2)
# Use the data you loaded from Question 1. Consider the variable FES
# in the code book. Which of the "tidy data" principles does this variable violate?
#
# Tidy data has one variable per column.
# Tidy data has no missing values.    <-----ANSWER
# Tidy data has one observation per row.
# Each variable in a tidy data set has been transformed to be interpretable.
summary(DF['FES'])


# Question 3
# Download the Excel spreadsheet on Natural Gas Aquisition Program here:
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FDATA.gov_NGAP.xlsx
# Read rows 18-23 and columns 7-15 into R and assign the result to a variable called: dat
# What is the value of: sum(dat$Zip*dat$Ext,na.rm=T)
# (original data source: http://catalog.data.gov/dataset/natural-gas-acquisition-program)
# 338924
# 36534720  <-----ANSWER
# 0
# 184585
if(!file.exists("data")){dir.create("data")}
fileURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FDATA.gov_NGAP.xlsx"
localFile = "data\\local.DATA.gov_NGAP.xlsx"

# the download mode needs to be set properly as write-binary (wb) since xlsx is basically a binary file (zip).
download.file(url=fileURL, destfile=localFile,  mode = 'wb')


library(xlsx)
dat <- read.xlsx(localFile, sheetIndex = 1, header = TRUE, startRow = 18, endRow = 23, colIndex = 7:15 )
dat
sum(dat$Zip*dat$Ext,na.rm=T)



# Question 4
# Read the XML data on Baltimore restaurants from here:
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml
# How many restaurants have zipcode 21231?
# 181
# 156
# 17
# 127    <-----ANSWER
if(!file.exists("data")){dir.create("data")}
fileURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml"
localFile = "data\\local.restaurants.xml"

# the download mode needs to be set properly as write-binary (wb) since xlsx is basically a binary file (zip).
download.file(url=fileURL, destfile=localFile,  mode = 'wb')

library(XML)
# http://www.omegahat.org/RSXML/shortIntro.pdf
# http://www.stat.berkeley.edu/~statcur/Workshop2/Presentations/XML.pdf
doc <- xmlTreeParse(localFile,useInternal=TRUE)
rootNode <- xmlRoot(doc)
xmlName(rootNode)
zips <- xpathSApply(rootNode,"//zipcode",xmlValue)
DT <- data.table(zips)
DT[zips==21231]
nrow(DT[zips==21231])

# Question 5
# The American Community Survey distributes downloadable data about United States
# communities. Download the 2006 microdata survey about housing for the state of
# Idaho using download.file() from here:
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv
# using the fread() command load the data into an R object: 'DT'
# Which of the following is the fastest way to calculate the average value of the
# variable: 'pwgtp15' broken down by sex using the data.table package?
#
# mean(DT[DT$SEX==1,]$pwgtp15); mean(DT[DT$SEX==2,]$pwgtp15)
# mean(DT$pwgtp15,by=DT$SEX)
# DT[,mean(pwgtp15),by=SEX]
# tapply(DT$pwgtp15,DT$SEX,mean)
# rowMeans(DT)[DT$SEX==1]; rowMeans(DT)[DT$SEX==2]
# sapply(split(DT$pwgtp15,DT$SEX),mean)


if(!file.exists("data")){dir.create("data")}
fileURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv"
localFile = "data\\local.2006housing.csv"

download.file(url=fileURL, destfile=localFile,  mode = 'wb')
DT <- fread(input = localFile)
head(DT)

library(pryr)
typeof(DT)
is.function(DT)
is.primitive(DT)
is.data.table(DT)
is.data.frame(DT)
is.table(DT)
otype(DT)
ftype(DT)
methods(DT)


library(sqldf)
sqldf("Select count(*) as cnt from DF where VAL>=24")

