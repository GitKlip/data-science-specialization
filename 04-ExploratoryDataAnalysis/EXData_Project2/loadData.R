if(!file.exists("data")){dir.create("data")}
if(!file.exists("data\\summarySCC_PM25.rds") | !file.exists("data\\Source_Classification_Code.rds")){
    fileUrl <- "http://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
    zipFileName <- "data\\EPA_NEI_data.zip"
    print(paste("downloading Zip File",fileUrl,"to",zipFileName,"..."))
    download.file(url = fileUrl, destfile = zipFileName, mode="wb")
    print("complete")
    print("UnZipping File...")
    unzip(zipfile = zipFileName, exdir = "data")
    print("complete")

}

# National Emissions Inventory database.  PM2.5 Emissions Data for 1999, 2002, 2005, and 2008
#   * `fips`: A five-digit number (represented as a string) indicating the U.S. county
#   * `SCC`: The name of the source as indicated by a digit string (see source code classification table)
#   * `Pollutant`: A string indicating the pollutant
#   * `Emissions`: Amount of PM2.5 emitted, in tons
#   * `type`: The type of source (point, non-point, on-road, or non-road)
#   * `year`: The year of emissions recorded
if(!exists("NEI")){
    print("loading data\\summarySCC_PM25.rds into NEI dataframe")
    NEI <- readRDS("data\\summarySCC_PM25.rds")
    print("complete")

    #     str(NEI)
    #     head(NEI)
    #     summary(NEI)
}

# Source Classification Code Table. describes the data in the table above
if(!exists("SCC")){
    print("loading data\\Source_Classification_Code.rds into SCC dataframe")
    SCC <- readRDS("data\\Source_Classification_Code.rds")
    print("complete")
    #     str(SCC)
    #     head(SCC)
    #     summary(SCC)
}

# create a merged data set with all values from NEI and the corresponding values from SEC
if(!exists("ALL")){
    print("mergeing NEI and SCC dataframes into 'ALL' dataframe")
    ALL <- merge(NEI, SCC, all.x = TRUE, all.y = FALSE, by = c("SCC"))
    print("complete")
    #     str(ALL)
}



## Remove data variables to recover memory space.
# rm(NEI,SCC)
