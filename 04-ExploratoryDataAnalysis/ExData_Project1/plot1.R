# exploreData - Project 1 - plot 1 - histogram
#
#     Our overall goal here is simply to examine how household energy usage varies
# over a 2-day period in February, 2007. Your task is to reconstruct the following
# plots below, all of which were constructed using the base plotting system.
#
# We use data from the UC Irvine Machine Learning Repository. We will be using the
# “Individual household electric power consumption Data Set”.
#
# exploratory graphs: "They help us find patterns in data and understand its
# properties. They suggest modeling strategies and help to debug analyses. We DON'T
# use exploratory graphs to communicate results."


#Download data
if(!file.exists("data")){dir.create("data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
if(!file.exists("data\\household_power_consumption.txt")){
    download.file(url = fileUrl, destfile = "data\\household_power_consumption.zip")
    unzip(zipfile = "data\\household_power_consumption.zip",exdir = "data")
}


# Load data with fread
library(data.table)   # http://www.inside-r.org/packages/cran/data.table/docs/fread
DT <- fread(input = "data\\household_power_consumption.txt", na.strings = c('?','NA','N/A',''))
is.data.frame(DT)
is.data.table(DT)
str(DT)


# Convert date and time fields
library(lubridate)  # ?lubridate
DT$DateX <- dmy(DT$Date)
DT$TimeX <- hms(DT$Time)
DT$DateTimeX <- dmy_hms(paste(DT$Date, DT$Time))
str(DT)

# Subset data to 2007-02-01 and 2007-02-02
DT <- subset(DT, DateX == ymd('2007-02-01') | DateX == ymd('2007-02-02'))
str(DT)

# # UPDATE, ISSUE SEEMS TO HAVE BEEN RESOLVED, COMMENTING THIS OUT
# # found an issue with fread not respecting na.string="?" paramater.  Resulted in all
# # columns reverting to characters https://class.coursera.org/exdata-014/forum/thread?thread_id=28
# # converting columns to numeric
# colNames <- c('Global_active_power','Global_reactive_power','Voltage','Global_intensity','Sub_metering_1','Sub_metering_2','Sub_metering_3')
# # for (col in colNames)
# #     DT[ DT[[col]] == "?" ] <- NA
# for (col in colNames)
#     set(DT, j=col, value=as.numeric(DT[[col]]))
# str(DT)


# Draw Plot 1 to screen
hist(DT$Global_active_power, col='red',xlab = "Global Active Power (kilowatts)", ylab = "Frequency",main = "Global Active Power")

# Draw Plot 1 to PNG
png("plot1.png", width = 480, height = 480)
hist(DT$Global_active_power, col='red',xlab = "Global Active Power (kilowatts)", ylab = "Frequency",main = "Global Active Power")
dev.off()

