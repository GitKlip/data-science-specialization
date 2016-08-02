
# The loadData.R script will download the file, unzip it, load 'NEI' and 'SCC'
# dataframes and then merge them into a dataframe named 'ALL'
source("./loadData.R")


# Q1. Have total emissions from PM2.5 decreased in the United States from 1999 to 2008?
# Using the **base** plotting system, make a plot showing the _total_ PM2.5 emission
from all sources for each of the years 1999, 2002, 2005, and 2008.

# aggregate the total PM2.5 emission from all sources for each of the years
DF <- aggregate(NEI$Emissions, by=list(NEI$year), FUN=sum)

# plot the total PM2.5 Emission from all sources, Using the base plotting system
png("plot1.png")
plot(DF, type = "l", main = "Total PM2.5 Emissions", ylab = "Emissions (tons)", xlab = "Year")
dev.off()

# Answer: yes, it's decreasing


