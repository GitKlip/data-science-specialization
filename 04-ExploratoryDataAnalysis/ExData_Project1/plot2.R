# exploreData - Project 1 - plot 1 - histogram
#
#     Our overall goal here is simply to examine how household energy usage varies
# over a 2-day period in February, 2007. Your task is to reconstruct the following
# plots below, all of which were constructed using the base plotting system.
#
# We use data from the UC Irvine Machine Learning Repository. We will be using the
# “Individual household electric power consumption Data Set”.

#Download data
if(!file.exists("data")){dir.create("data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
if(!file.exists("data\\household_power_consumption.txt")){
    download.file(url = fileUrl, destfile = "data\\household_power_consumption.zip")
    unzip(zipfile = "data\\household_power_consumption.zip",exdir = "data")
}


# Load data with fread
library(data.table)   # http://www.inside-r.org/packages/cran/data.table/docs/fread
DT <- fread(input = "data\\household_power_consumption.txt", na.strings = c("?","NA","N/A",""))
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



# Draw Plot 2 to screen
plot(DT$DateTimeX, DT$Global_active_power, type = "l", ylab ="Global Active Power (kilowatts)", xlab = "")

# Draw Plot 1 to PNG
png("plot2.png", width = 480, height = 480)
plot(DT$DateTimeX, DT$Global_active_power, type = "l", ylab ="Global Active Power (kilowatts)", xlab = "")
dev.off()


