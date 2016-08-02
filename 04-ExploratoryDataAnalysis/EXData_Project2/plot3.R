
# The loadData.R script will download the file, unzip it, load 'NEI' and 'SCC'
# dataframes and then merge them into a dataframe named 'ALL'
source("./loadData.R")

# Q3. Of the four types of sources indicated by the `type` (point, nonpoint,
# onroad, nonroad) variable, which of these four sources have seen decreases in
# emissions from 1999–2008 for **Baltimore City**? Which have seen increases in
# emissions from 1999–2008? Use the **ggplot2** plotting system to make a plot
# answer this question.

library(ggplot2)

#subset the data to baltimore, MD
BALTIMORE <- ALL[ALL$fips == "24510",]

# I created 3 versions of the same graph to see which one I liked best.  I chose
# to submit the third but kept the code as reference.

#bar version
ggplot(data = BALTIMORE, aes(x=as.factor(year), y=Emissions, fill=type)) +
    geom_bar(stat = "identity") +  #sum values by year
    theme_bw() +  #minimal theme
    facet_grid(. ~ type)

#point version
ggplot(data = BALTIMORE) +
    geom_point(aes(x=as.factor(year), y=Emissions, color=type)) +
    facet_grid(. ~ type)

#line version - submit this one
ggplot(data = BALTIMORE, aes(x=as.factor(year), y=Emissions, color=type, group=1)) +
    geom_point(stat = "summary", fun.y=sum) +
    stat_summary(fun.y=sum,geom="line") +
    facet_grid(type ~ .) +
    labs(x = "Year", y = "Emissions (tons)") +
    ggtitle("PM2.5 Total Vehicle Emissions for Baltimore City, MD")
    ggsave("plot3.png")


# Answer: Non-Road, NonPoint, On-Road types have all seen decreases in emisions.
# Point type saw significant increases and then dropped in the last year to be
# almost at the same level as it started, but still with an increase.


