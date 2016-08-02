# Q4 TOPICS: editing text, regex, dates, resources

# Question 1
# The American Community Survey distributes downloadable data about United States communities.
# Download the 2006 microdata survey about housing for the state of Idaho using download.file()
# from here:
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv
# and load the data into R. The code book, describing the variable names is here:
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FPUMSDataDict06.pdf
#
# Apply strsplit() to split all the names of the data frame on the characters "wgtp". What is the
# value of the 123 element of the resulting list?
#
# "" "15"               <<-- ANSWER
# "wgtp" "15"
# "wgt" "15"
# "wgtp"

# 403, 756, 798

furl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
local.file <- "data\\quiz4-2006Idaho.csv"
if(!file.exists("data")){dir.create("data")}
download.file(url = furl, destfile = local.file)
DF <- read.table(file = local.file, sep = ",", header = TRUE)
headers <- names(DF)
typeof(headers)
result <- strsplit(headers, "wgtp")
typeof(result)
result[123]


# Question 2
# Load the Gross Domestic Product data for the 190 ranked countries in this data set:
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv
# Original data sources:
#     http://data.worldbank.org/data-catalog/GDP-ranking-table
# Remove the commas from the GDP numbers in millions of dollars and average them. What is the
# average?
#
# 293700.3
# 381668.9
# 381615.4
# 377652.4      <<<--- ANSWER
library(data.table)
gdpfurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
gdpfname <- "data\\quiz4-GDP.csv"
if(!file.exists("data")){dir.create("data")}
download.file(url = gdpfurl, destfile = gdpfname)
GDP <- data.table(read.csv(file=gdpfname, skip = 5, nrows = 190,header = FALSE))
setnames(GDP,old = c(1,2,4,5), new = c("countryCode","ranking","countryName","gdp"))
head(GDP)  #USA
tail(GDP)  #EMU
str(GDP)

GDP$gdpNumeric <- as.numeric(gsub(",", "", as.character(GDP$gdp)))
ave(GDP$gdpNumeric)
mean(GDP$gdpNumeric, na.rm = TRUE)



# Question 3
# In the data set from Question 2 what is a regular expression that would allow you to count the
# number of countries whose name begins with "United"? Assume that the variable with the country
# names in it is named countryNames. How many countries begin with United?
#
# grep("^United",countryNames), 4
# grep("United$",countryNames), 3
# grep("*United",countryNames), 2
# grep("^United",countryNames), 3   <<<---Answer
grep("^United",GDP$countryName)
summary(grepl("^United",GDP$countryName))

# Question 4
# Load the Gross Domestic Product data for the 190 ranked countries in this data set:
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv
# Load the educational data from this data set:
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv
# Original data sources:
#     http://data.worldbank.org/data-catalog/GDP-ranking-table
#     http://data.worldbank.org/data-catalog/ed-stats
# Match the data based on the country shortcode. Of the countries for which the end of the fiscal
# year is available, how many end in June?
#
# 15
# 13            <<<---ANSWER
# 31
# 8

gdpfurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
gdpfname <- "data\\quiz3-GDP.csv"
if(!file.exists("data")){dir.create("data")}
download.file(url = gdpfurl, destfile = gdpfname)
GDP <- data.table(read.csv(file=gdpfname, skip = 5, nrows = 190,header = FALSE))
setnames(GDP,old = c(1,2,4,5), new = c("CountryCode","ranking","CountryName","gdp"))
head(GDP)  #USA
str(GDP)

edufurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv"
edufname <- "data\\quiz3-EDU.csv"
if(!file.exists("data")){dir.create("data")}
download.file(url = edufurl, destfile = edufname)
EDU <- data.table(read.csv(file = edufname, header = TRUE))
head(EDU)
str(EDU)
names(EDU)

# http://stackoverflow.com/questions/1299871/how-to-join-data-frames-in-r-inner-outer-left-right
DF <- merge(GDP, EDU, all = TRUE, by = c("CountryCode"))
isJuneFYE <- grepl(DF$Special.Notes, pattern = "fiscal year end.*June.*;", ignore.case = TRUE, perl = TRUE)
summary(isJuneFYE)
DF[isJuneFYE, Special.Notes]

# Question 5
# You can use the quantmod (http://www.quantmod.com/) package to get historical stock prices for
# publicly traded companies on the NASDAQ and NYSE. Use the following code to download data on
# Amazon's stock price and get the times the data was sampled.
#     library(quantmod)
#     amzn = getSymbols("AMZN",auto.assign=FALSE)
#     sampleTimes = index(amzn)
# How many values were collected in 2012? How many values were collected on Mondays in 2012?
#
# 250, 47           <<<--- ANSWER
# 250, 51
# 251, 47
# 365, 52
library(quantmod)
??quantmod
amzn <- getSymbols("AMZN",auto.assign=FALSE)
length(amzn)
head(amzn)
str(amzn)
sampleTimes <- index(amzn)
length(sampleTimes)
head(sampleTimes)
str(sampleTimes)
is.OHLC(amzn)

table(year(sampleTimes),weekdays(sampleTimes))
addmargins(table(year(sampleTimes),weekdays(sampleTimes)), FUN=sum)



amzn2012 <- amzn['2012']
length(amzn2012)
sampleTimes2012 <- index(amzn2012)
length(sampleTimes2012)





