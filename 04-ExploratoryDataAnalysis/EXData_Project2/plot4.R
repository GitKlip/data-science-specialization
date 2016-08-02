
# The loadData.R script will download the file, unzip it, load 'NEI' and 'SCC'
# dataframes and then merge them into a dataframe named 'ALL'
source("./loadData.R")


# Q4. Across the United States, how have emissions from coal combustion-related
# sources changed from 1999–2008

# explore columns to find which ones indicate coal combustion sources
colNames <- c("SCC.Level.One","SCC.Level.Two","SCC.Level.Three","SCC.Level.Four","Usage.Notes")
for (col in colNames){
    print(paste0("## checking [",col,"] ##"))
    print(levels(as.factor(grep(x=ALL[[col]], pattern = "combustion | coal", ignore.case = TRUE, value = TRUE))))
}

# The SCC.Level.# columns go from generic to specific.  Based on my earlier search
# I assume that coal combustion related sources are those where:
# (SCC.Level.One OR SCC.Level.Two contains 'combustion') AND (SCC.Level.Four contains 'coal')

# Create logical columns indicating the sources to assist in subsetting the data
ALL$isCombustion <- grepl("combustion", ALL$SCC.Level.One, ignore.case = TRUE) |
                    grepl("combustion", ALL$SCC.Level.Two, ignore.case = TRUE)
ALL$isCoal <- grepl("coal", ALL$SCC.Level.Four, ignore.case = TRUE)
ALL$isCoalCombustion <- (ALL$isCombustion & ALL$isCoal)

# subset data to coal combustion data
COAL <- ALL[ALL$isCoalCombustion,c("SCC","year","Emissions",colNames)]
# summary(COAL)
# str(COAL)
# head(COAL)
# tail(COAL)
# aggregate(COAL$Emissions, by=list(COAL$year), FUN=sum)

ggplot(data = COAL, aes(x = year, y = Emissions)) +
    stat_summary(fun.y=sum,geom="line") +
    coord_cartesian() +
    theme_bw() +
    labs(x = "Year", y = "Total Emissions (tons)") +
    ggtitle("PM2.5 Total Coal Combustion Emissions Across US")
ggsave("plot4.png")

# Answer: Total Emissions for Coal Combusion across U.S. have decreased during the
# given timeframe from about 550k tons to 330k tons.  There was a slight increase
# from 2002 to 2005 with a sharp decline after that.

