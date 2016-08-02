
# The loadData.R script will download the file, unzip it, load 'NEI' and 'SCC'
# dataframes and then merge them into a dataframe named 'ALL'
source("./loadData.R")


# 6. Compare emissions from motor vehicle sources in Baltimore City (`fips == "24510"`)
# with emissions from motor vehicle sources in **Los Angeles County**, California
# (`fips == "06037"`). Which city has seen greater changes over time in motor vehicle
# emissions?

# In plot 5 we determined that a subset of data will be done by searching for 'vehicle' in
# SCC.Level.Two (highest level) where location is Baltimore City OR Los Angeles (fips = 24510 or 06037)

ALL$isVehicle <- grepl("motor | vehicle", ALL$SCC.Level.Two, ignore.case = TRUE)

# Plot the results
# subset data when providing it to ggplot
ggplot(data = ALL[(ALL$fips %in% c("06037","24510")) & (ALL$isVehicle),], ) +
    #map aes, sum data, specify line
    stat_summary( mapping = aes(x = year, y = Emissions, color=fips), fun.y=sum, geom="line" ) +
    #modify legend labels http://www.cookbook-r.com/Graphs/Legends_(ggplot2)/
    scale_color_discrete( name="Location",
                          breaks = c("06037","24510"),
                          labels = c("Los Angeles, CA","Baltimore City, MD")) +
    theme_bw() +
    labs(x = "Year", y = "Emissions (tons)") +
    ggtitle("PM2.5 Total Vehicle Emissions")
ggsave("plot6.png")


# Answer: Los Angeles has seen greater changes over time, going from 6000 to 7000
# and then back down to 6500.  Los angeles emisions have consitently been significantly
# higher than Baltimore.  Baltimore's Emissions have been relativley more stable and
# slowly decreased.
