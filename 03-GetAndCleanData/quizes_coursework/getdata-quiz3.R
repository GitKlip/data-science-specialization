#Q3 TOPICS: subset, summarize, reshaping, Data frames, dplyr, merging data

# Question 1
# The American Community Survey distributes downloadable data about United States communities.
# Download the 2006 microdata survey about housing for the state of Idaho using download.file()
# from here:
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv
# and load the data into R. The code book, describing the variable names is here:
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FPUMSDataDict06.pdf
#
# Create a logical vector that identifies the households on greater than 10 acres who sold more
# than $10,000 worth of agriculture products. Assign that logical vector to the variable
# agricultureLogical. Apply the which() function like this to identify the rows of the data frame
# where the logical vector is TRUE. which(agricultureLogical) What are the first 3 values that
# result?
#
# 125, 238,262    <<<<<---- ANSWER
# 59, 460, 474
# 25, 36, 45
# 403, 756, 798
furl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
local.file <- "data\\quiz3-2006Idaho.csv"
if(!file.exists("data")){dir.create("data")}
download.file(url = furl, destfile = local.file)
DF <- read.table(file = local.file, sep = ",", header = TRUE)
str(DF)
summary(DF)
table(DF$ACR,DF$BDS,DF$VAL,useNA = "ifany")

DF$agricultureLogical <- (DF$ACR == 3) & (DF$AGS == 6)
which(DF$agricultureLogical)


# Question 2
# Using the jpeg package read in the following picture of your instructor into R
#     https://d396qusza40orc.cloudfront.net/getdata%2Fjeff.jpg
# Use the parameter native=TRUE. What are the 30th and 80th quantiles of the resulting data?
# (some Linux systems may produce an answer 638 different for the 30th quantile)
#
# -16776430 -15390165
# -15259150 -10575416    <<<---  ANSWER
# -15259150 -594524
# -14191406 -10904118
library(jpeg)
??jpeg
furl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fjeff.jpg"
fname <- "data\\quiz3-jeff.jpg"
if(!file.exists("data")){dir.create("data")}
download.file(url = furl, destfile = fname, mode="wb")
img = readJPEG(fname,native = TRUE)
quantile(img, probs = c(.3,.8))

# Question 3
# Load the Gross Domestic Product data for the 190 ranked countries in this data set:
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv
# Load the educational data from this data set:
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv
# Original data sources:
#     http://data.worldbank.org/data-catalog/GDP-ranking-table
#     http://data.worldbank.org/data-catalog/ed-stats
# Match the data based on the country shortcode. How many of the IDs match? Sort the data frame
# in descending order by GDP rank (so United States is last). What is the 13th country in the
# resulting data frame?
#
# 190 matches, 13th country is Spain
# 189 matches, 13th country is Spain
# 189 matches, 13th country is St. Kitts and Nevis   <<<---ANSWER
# 234 matches, 13th country is St. Kitts and Nevis
# 190 matches, 13th country is St. Kitts and Nevis
# 234 matches, 13th country is Spain
if(!file.exists("data")){dir.create("data")}
gdpfurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
gdpfname <- "data\\quiz3-GDP.csv"
download.file(url = gdpfurl, destfile = gdpfname)
GDP <- data.table(read.csv(file=gdpfname, skip = 5, nrows = 190,header = FALSE))
setnames(GDP,old = c(1,2,4,5), new = c("countryCode","ranking","countryName","gdp"))
head(GDP)  #USA
tail(GDP)  #EMU
str(GDP)

edufurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv"
edufname <- "data\\quiz3-EDU.csv"
if(!file.exists("data")){dir.create("data")}
download.file(url = edufurl, destfile = edufname)
EDU <- data.table(read.csv(file = edufname, header = TRUE))
head(EDU)
str(EDU)

library(sqldf)
joinSql <- "SELECT GDP.countryCode,GDP.ranking,GDP.countryName,GDP.gdp, EDU.'Income.Group'
            FROM GDP
            join EDU on (GDP.countryCode = EDU.CountryCode)
            ORDER BY GDP.ranking DESC"
GDP_EDU <- sqldf(joinSql,stringsAsFactors = FALSE)
typeof(GDP_EDU)
is.data.frame(GDP_EDU)
is.data.table(GDP_EDU)
summary(GDP_EDU)
head(GDP_EDU)

# Question 4
# What is the average GDP ranking for the "High income: OECD" and "High income: nonOECD" group?
#
# 23, 45
# 133.72973, 32.96667
# 23.966667, 30.91304
# 23, 30
# 30, 37
# 32.96667, 91.91304   <<<--ANSWER
levels(GDP_EDU$Income.Group)
sql <- "SELECT  T.'Income.Group', avg(T.ranking)
        FROM GDP_EDU as T
        GROUP BY T.'Income.Group' "
sqldf(sql,stringsAsFactors = FALSE)

# Question 5
# Cut the GDP ranking into 5 separate quantile groups. Make a table versus Income.Group.
# How many countries are Lower middle income but among the 38 nations with highest GDP?
#
# 12
# 13
# 0
# 5                 <<<---ANSWER
library(dplyr)
DF <- GDP_EDU
help(quantile)
Sys.getenv()
getR()

install.packages("Hmisc",dependencies = TRUE)
library("Hmisc")
names(GDP_EDU)

GDP_EDU$RankGroup <- cut2(GDP_EDU$ranking,g=5,)
table(GDP_EDU$RankGroup)
table(GDP_EDU$RankGroup, GDP_EDU$Income.Group)


