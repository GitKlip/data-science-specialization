# Topics: reading data from mySql, HDF5, Web, APIs, Other sources


# Question 1
# Register an application with the Github API here https://github.com/settings/applications.
# Access the API to get information on your instructors repositories
# (hint: this is the url you want "https://api.github.com/users/jtleek/repos").
# Use this data to find the time that the datasharing repo was created. What time was it created?
#
# This tutorial may be useful (https://github.com/hadley/httr/blob/master/demo/oauth2-github.r).
# You may also need to run the code in the base R package and not R studio.
#
# 2014-02-06T16:13:11Z
# 2013-11-07T13:25:07Z  <<----- ANSWER (in the end, just go to link and look search in the data)
# 2013-08-28T18:18:50Z
# 2014-01-04T21:06:44Z

# Eriks application: https://github.com/settings/applications/194860

# https://github.com/hadley/httr/blob/master/demo/oauth2-github.r
library(httr)

# 1. Find OAuth settings for github:
#    http://developer.github.com/v3/oauth/
oauth_endpoints("github")

# 2. Register an application at https://github.com/settings/applications;
#    Use any URL you would like for the homepage URL (http://github.com is fine)
#    and http://localhost:1410 as the callback url
#
#    Insert your client ID and secret below - if secret is omitted, it will
#    look it up in the GITHUB_CONSUMER_SECRET environmental variable.
myapp <- oauth_app(appname = "github", key="a077767ae0d17c017e40", secret = "723664547310e1d99753765eb44661809f163325")
myapp

# 3. Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# 4. Use API
gtoken <- config(token = github_token)
req <- GET("https://github.com/jtleek/datasharing", gtoken)
stop_for_status(req)
content(req)
req

# OR:
req <- with_config(gtoken, GET("https://github.com/jtleek/datasharing"))
stop_for_status(req)
content(req)
req
typeof(content(req))

BROWSE("https://api.github.com/users/jtleek/repos",authenticate("Access Token","x-oauth-basic","basic"))
"created_at": "2013-11-07T13:25:07Z",



# Question 2
# The sqldf package allows for execution of SQL commands on R data frames. We will
# use the sqldf package to practice the queries we might send with the dbSendQuery
# command in RMySQL. Download the American Community Survey data and load it into
# an R object called: 'acs'
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv
# Which of the following commands will select only the data for the probability
# weights pwgtp1 with ages less than 50?
#
# sqldf("select * from acs")
# sqldf("select pwgtp1 from acs")
# sqldf("select * from acs where AGEP < 50")
# sqldf("select pwgtp1 from acs where AGEP < 50")  <<--- ANSWER



# Question 3
# Using the same data frame you created in the previous problem, what is the equivalent
# function to unique(acs$AGEP)
#
# sqldf("select distinct AGEP from acs")  <<--- ANSWER
# sqldf("select unique AGEP from acs")
# sqldf("select distinct pwgtp1 from acs")
# sqldf("select unique * from acs")



# Question 4
# How many characters are in the 10th, 20th, 30th and 100th lines of HTML from this page:
#     http://biostat.jhsph.edu/~jleek/contact.html
# (Hint: the nchar() function in R may be helpful)
#
# 45 31 7 31
# 43 99 7 25
# 45 31 2 25
# 45 31 7 25   <<<----  ANSWER
# 45 92 7 2
# 45 0 2 2
# 43 99 8 6

hurl <- "http://biostat.jhsph.edu/~jleek/contact.html"
con <- url(hurl)
?readLines
# http://www.peterbe.com/plog/blogitem-040312-1
# http://stackoverflow.com/questions/23001548/dealing-with-readlines-function-in-r
htmlCode <- readLines(con)
close(con)
typeof(htmlCode)
length(htmlCode)
sapply(htmlCode[c(10, 20, 30, 100)], nchar)
lapply(htmlCode[c(10, 20, 30, 100)], nchar)

# Question 5
# Read this data set into R and report the sum of the numbers in the fourth of the nine columns.
#     https://d396qusza40orc.cloudfront.net/getdata%2Fwksst8110.for
# Original source of the data: http://www.cpc.ncep.noaa.gov/data/indices/wksst8110.for
# (Hint this is a fixed width file format)
#
# 101.83
# 222243.1
# 35824.9
# 32426.7   <<<---- ANSWER
# 28893.3
# 36.5

# view data by going to url http://www.cpc.ncep.noaa.gov/data/indices/wksst8110.for
furl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fwksst8110.for"
local.file <- "data\\quiz2-q5.csv"

download.file(url = furl, destfile = local.file)

#get a visual on what it looks like
DF <- read.table(file = local.file, sep = "\t", header = TRUE)
head(DF)

DF1 <- read.fwf(file=local.file,skip = 4,widths = c(9,-5,4,-1,3,-5,4,-1,3,-5,4,-1,3,-5,4,-1,3) )
sum(DF1[, 4])

#this is correct because the SSTA column is 4 wide, not 3 (first char is a +/- sign)
DF2 <- read.fwf(file=local.file,widths=c(-1,9,-5,4,4,-5,4,4,-5,4,4,-5,4,4), skip=4)
sum(DF2[, 4])

