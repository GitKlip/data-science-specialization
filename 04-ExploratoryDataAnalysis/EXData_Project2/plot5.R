
# The loadData.R script will download the file, unzip it, load 'NEI' and 'SCC'
# dataframes and then merge them into a dataframe named 'ALL'
source("./loadData.R")


# Q5) How have emissions from motor vehicle sources changed from 1999–2008 in Baltimore City?

# explore columns to find which ones indicate motor vehicle
colNames <- c("SCC.Level.One","SCC.Level.Two","SCC.Level.Three","SCC.Level.Four","Usage.Notes")
for (col in colNames){
    print(paste0("## checking [",col,"] ##"))
    print(levels(as.factor(grep(x=ALL[[col]], pattern = "motor | vehicle", ignore.case = TRUE, value = TRUE))))
}

#Based on findings, subset of data will be done by searching for 'vehicle' in
# SCC.Level.Two (highest level) where location is Baltimore City, MD (`fips == "24510"`)

# Create logicl indicator to assist in subset of data
ALL$isVehicle <- grepl("motor | vehicle", ALL$SCC.Level.Two, ignore.case = TRUE)

#Plot the changes over the time period.
#subset the data and map x & y
ggplot(data = ALL[(ALL$fips == "24510") & (ALL$isVehicle),], aes(x = year, y = Emissions)) +
    #summarize data and use line to plot
    stat_summary(fun.y=sum, geom="line") +
    theme_bw() +
    labs(x = "Year", y = "Total Emissions (tons)") +
    ggtitle("PM2.5 Vehicle Emissions in Baltimore City, MD for 1999-2008")
ggsave("plot5.png", width = 4, height = 4)

# Answer: Emissions decreased sharply from 1999-2002 (400 to 190), stayed rather
# flat from 2002-2005, then dropped again from 2005-2008 (180 to 135)

