
# The loadData.R script will download the file, unzip it, load 'NEI' and 'SCC'
# dataframes and then merge them into a dataframe named 'ALL'
source("./loadData.R")

# Q2. Have total emissions from PM2.5 decreased in the **Baltimore City**, Maryland
# (`fips == "24510"`) from 1999 to 2008? Use the **base** plotting system to make
# a plot answering this question.

# Subset data for Blatimore City, MD
BALTIMORE <- ALL[ALL$fips == "24510",]
# str(BALTIMORE)
# sum(is.na(BALTIMORE))

# Calculate yearly totals from all sources for each of the years 1999-2008.
DF <- aggregate(BALTIMORE$Emissions, by=list(BALTIMORE$year), FUN=sum)

# Using the base plotting system, we plot the total Emission for Baltimore City, MD
png("plot2.png")
plot(DF, type = "l", main = "Total Emissions for Baltimore City, MD", ylab = "Emissions (tons)", xlab = "Year")
dev.off()


# Answer: overall they have decreased, though not in a linear pattern. a spike
# in 2005 brought it almost up to original levels but in 2008 it dropped sharply
# to be much less than in 1999.
