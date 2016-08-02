# Exploration of PM2.5 emissions Data
Erik Cornelsen  
Saturday, May 09, 2015  

## Introduction

The overall goal of this assignment is to explore the National Emissions Inventory database and see what it say about fine particulate matter pollution in the United states over the 10-year period 1999-2008. 

Fine particulate matter (PM2.5) is an ambient air pollutant for which there is strong evidence that it is harmful to human health. In the United States, the Environmental Protection Agency (EPA) is tasked with setting national ambient air quality standards for fine PM and for tracking the emissions of this pollutant into the atmosphere. Approximatly every 3 years, the EPA releases its database on emissions of PM2.5. This database is known as the National Emissions Inventory (NEI). You can read more information about the NEI at the [EPA National Emissions Inventory web site](http://www.epa.gov/ttn/chief/eiinformation.html). For each year and for each type of PM source, the NEI records how many tons of PM2.5 were emitted from that source over the course of the entire year.

## Data

The data for this analysis is available from the course web site as a single zip file:

  * [Data for Peer Assessment](https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip) [29Mb]

The zip file contains two files:

1. **PM2.5 Emissions Data** (`summarySCC_PM25.rds`): This file contains a data frame
with all of the PM2.5 emissions data for 1999, 2002, 2005, and 2008. For each
year, the table contains number of **tons** of PM2.5 emitted from a specific
type of source for the entire year. Here are the first few rows.
    
```    
    ##     fips      SCC Pollutant Emissions  type year
    ## 4  09001 10100401  PM25-PRI    15.714 POINT 1999
    ## 8  09001 10100404  PM25-PRI   234.178 POINT 1999
    ## 12 09001 10100501  PM25-PRI     0.128 POINT 1999
    ## 16 09001 10200401  PM25-PRI     2.036 POINT 1999
    ## 20 09001 10200504  PM25-PRI     0.388 POINT 1999
    ## 24 09001 10200602  PM25-PRI     1.490 POINT 1999
```

  * `fips`: A five-digit number (represented as a string) indicating the U.S. county 
  * `SCC`: The name of the source as indicated by a digit string (see source code classification table)
  * `Pollutant`: A string indicating the pollutant
  * `Emissions`: Amount of PM2.5 emitted, in tons
  * `type`: The type of source (point, non-point, on-road, or non-road)
  * `year`: The year of emissions recorded

2. **Source Classification Code Table** (`Source_Classification_Code.rds`): This
table provides a mapping from the SCC digit strings int he Emissions table to
the actual name of the PM2.5 source. The sources are categorized in a few
different ways from more general to more specific. For example, source
'10100101' is known as 'Ext Comb /Electric Gen /Anthracite Coal /Pulverized
Coal'.


## Load the Data

```r
setwd("~/Analysis/Coursera/data-science-coursera/04-ExploratoryDataAnalysis/EXData_Project2")
getwd()
## [1] "C:/Users/Erik/Documents/Analysis/Coursera/data-science-coursera/04-ExploratoryDataAnalysis/EXData_Project2"


if(!file.exists("data")){dir.create("data")}
if(!file.exists("data\\summarySCC_PM25.rds") | !file.exists("data\\Source_Classification_Code.rds")){
    fileUrl <- "http://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
    zipFileName <- "data\\EPA_NEI_data.zip"
    download.file(url = fileUrl, destfile = zipFileName, mode="wb")
    unzip(zipfile = zipFileName, exdir = "data")
}

# National Emissions Inventory database.  PM2.5 Emissions Data for 1999, 2002, 2005, and 2008
#   * `fips`: A five-digit number (represented as a string) indicating the U.S. county 
#   * `SCC`: The name of the source as indicated by a digit string (see source code classification table)
#   * `Pollutant`: A string indicating the pollutant
#   * `Emissions`: Amount of PM2.5 emitted, in tons
#   * `type`: The type of source (point, non-point, on-road, or non-road)
#   * `year`: The year of emissions recorded
if(!exists("NEI")){
    NEI <- readRDS("data\\summarySCC_PM25.rds")
#     str(NEI)
}

# Source Classification Code Table. describes the data in the table above
if(!exists("SCC")){
    SCC <- readRDS("data\\Source_Classification_Code.rds")
#     str(SCC)
}

#Merge the datasets together
if(!exists("ALL")){
    ALL <- merge(NEI, SCC, all.x = TRUE, all.y = FALSE, by = c("SCC"))
#     str(ALL)
}
```

## Explore and Analyze Data
Below are the questions we have about the data and some plots that help us to visualize the answers. For each question I created a .R file to create the plot that best addressed the question.

###1. Have total emissions from PM2.5 decreased in the United States from 1999 to 2008? 
  Using the **base** plotting system, make a plot showing the _total_ PM2.5 emission from all sources for each of the years 1999, 2002, 2005, and 2008.

Answer: yes, it's decreasing


```r
# First we'll aggregate the total PM2.5 emission from all sources for each of the years 1999, 2002, 2005, and 2008.
DF <- aggregate(NEI$Emissions, by=list(NEI$year), FUN=sum)

# Using the base plotting system, now we plot the total PM2.5 Emission from all sources
plot(DF, type = "l", main = "Total PM2.5 Emissions", ylab = "Emissions (tons)", xlab = "Year")
```

![](files/Q1-1.png) 


###2. Have total emissions from PM2.5 decreased in the **Baltimore City**, Maryland (`fips == "24510"`) from 1999 to 2008? Use the **base** plotting system to make a plot answering this question.
  
Answer: overall they have decreased, though not in a linear pattern.


```r
# Subset data for Blatimore City, MD 
BALTIMORE <- ALL[ALL$fips == "24510",] 
# str(BALTIMORE)
# sum(is.na(BALTIMORE))

# Calculate yearly totals from all sources for each of the years 1999, 2002, 2005, and 2008.
DF <- aggregate(BALTIMORE$Emissions, by=list(BALTIMORE$year), FUN=sum)
# DF

# Using the base plotting system, we plot the total Emission for Baltimore City, MD
plot(DF, type = "l", main = "Total Emissions for Baltimore City, MD", ylab = "Emissions (tons)", xlab = "Year")
```

![](files/Q2-1.png) 

###3. Of the four types of sources indicated by the `type` (point, nonpoint, onroad, nonroad) variable, which of these four sources have seen decreases in emissions from 1999-2008 for **Baltimore City**? Which have seen increases in emissions from 1999-2008? Use the **ggplot2** plotting system to make a plot answer this question.


```r
library(ggplot2)
str(BALTIMORE)
## 'data.frame':	2096 obs. of  20 variables:
##  $ SCC                : chr  "10100504" "10100504" "10100504" "10100504" ...
##  $ fips               : chr  "24510" "24510" "24510" "24510" ...
##  $ Pollutant          : chr  "PM25-PRI" "PM25-PRI" "PM25-PRI" "PM25-PRI" ...
##  $ Emissions          : num  0.034 0.0309 1.31 0.0309 0.0433 ...
##  $ type               : chr  "POINT" "POINT" "POINT" "POINT" ...
##  $ year               : int  2008 2008 2005 2008 2008 2002 1999 2005 2002 2002 ...
##  $ Data.Category      : Factor w/ 6 levels "Biogenic","Event",..: 6 6 6 6 6 6 6 6 6 6 ...
##  $ Short.Name         : Factor w/ 11238 levels "","2,4-D Salts and Esters Prod /Process Vents, 2,4-D Recovery: Filtration",..: 3298 3298 3298 3298 3298 3298 3324 3324 3324 3421 ...
##  $ EI.Sector          : Factor w/ 59 levels "Agriculture - Crops & Livestock Dust",..: 20 20 20 20 20 20 19 19 19 25 ...
##  $ Option.Group       : Factor w/ 25 levels "","C/I Kerosene",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ Option.Set         : Factor w/ 18 levels "","A","B","B1A",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ SCC.Level.One      : Factor w/ 17 levels "Brick Kilns",..: 3 3 3 3 3 3 3 3 3 3 ...
##  $ SCC.Level.Two      : Factor w/ 146 levels "","Agricultural Chemicals Production",..: 32 32 32 32 32 32 32 32 32 52 ...
##  $ SCC.Level.Three    : Factor w/ 1061 levels "","100% Biosolids (e.g., sewage sludge, manure, mixtures of these matls)",..: 317 317 317 317 317 317 692 692 692 886 ...
##  $ SCC.Level.Four     : Factor w/ 6084 levels "","(NH4)2 SO4 Acid Bath System and Evaporator",..: 2527 2527 2527 2527 2527 2527 590 590 590 31 ...
##  $ Map.To             : num  NA NA NA NA NA NA NA NA NA NA ...
##  $ Last.Inventory.Year: int  NA NA NA NA NA NA NA NA NA NA ...
##  $ Created_Date       : Factor w/ 57 levels "","1/27/2000 0:00:00",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ Revised_Date       : Factor w/ 44 levels "","1/27/2000 0:00:00",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ Usage.Notes        : Factor w/ 21 levels ""," ","includes bleaching towers, washer hoods, filtrate tanks, vacuum pump exhausts",..: 1 1 1 1 1 1 1 1 1 1 ...

qplot(displ,hwy,data=mpg,geom=c("point","smooth"))
```

![](files/Q3-1.png) 

```r

qplot(hwy,data=mpg,fill=drv)
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

![](files/Q3-2.png) 

```r

#bar version
ggplot(data = BALTIMORE, aes(x=as.factor(year), y=Emissions, fill=type)) + 
    geom_bar(stat = "identity") +  #sum values by year
    theme_bw() +  #minimal theme
    facet_grid(. ~ type)
```

![](files/Q3-3.png) 

```r

#point version
ggplot(data = BALTIMORE) + 
    geom_point(aes(x=as.factor(year), y=Emissions, color=type)) +
    facet_grid(. ~ type)
```

![](files/Q3-4.png) 

```r

#line version
ggplot(data = BALTIMORE, aes(x=as.factor(year), y=Emissions, color=type, group=1)) + 
    geom_point(stat = "summary", fun.y=sum) +
    stat_summary(fun.y=sum,geom="line") +
    facet_grid(. ~ type)
```

![](files/Q3-5.png) 

###4. Across the United States, how have emissions from coal combustion-related sources changed from 1999-2008
Answer: Total Emissions for Coal Combusion across U.S. have decreased during the given timeframe from about 550k tons to 330k tons.

```r

# First subset data to coal combustion data
# The SCC.Level.# columns go from generic to specific.  I assume that coal combustion related sources are those where:
#     (SCC.Level.One OR SCC.Level.Two contains the substring 'combustion') AND (SCC.Level.Four contains the substring 'coal')

isCombustion <- grepl("combustion", ALL$SCC.Level.One, ignore.case = TRUE) | grepl("combustion", ALL$SCC.Level.Two, ignore.case = TRUE)
isCoal <- grepl("coal", ALL$SCC.Level.Four, ignore.case = TRUE)
isCoalCombustion <- (isCombustion & isCoal)

COAL <- ALL[isCoalCombustion,c("SCC","year","Emissions","SCC.Level.One","SCC.Level.Two","SCC.Level.Three","SCC.Level.Four","Usage.Notes")]
str(COAL)
## 'data.frame':	4567 obs. of  8 variables:
##  $ SCC            : chr  "10100101" "10100101" "10100101" "10100101" ...
##  $ year           : int  1999 2002 1999 2002 2005 1999 2005 2005 2008 1999 ...
##  $ Emissions      : num  898.42 0.08 2.48 58.61 131.8 ...
##  $ SCC.Level.One  : Factor w/ 17 levels "Brick Kilns",..: 3 3 3 3 3 3 3 3 3 3 ...
##  $ SCC.Level.Two  : Factor w/ 146 levels "","Agricultural Chemicals Production",..: 32 32 32 32 32 32 32 32 32 32 ...
##  $ SCC.Level.Three: Factor w/ 1061 levels "","100% Biosolids (e.g., sewage sludge, manure, mixtures of these matls)",..: 88 88 88 88 88 88 88 88 88 88 ...
##  $ SCC.Level.Four : Factor w/ 6084 levels "","(NH4)2 SO4 Acid Bath System and Evaporator",..: 4455 4455 4455 4455 4455 4455 4455 4455 4455 4455 ...
##  $ Usage.Notes    : Factor w/ 21 levels ""," ","includes bleaching towers, washer hoods, filtrate tanks, vacuum pump exhausts",..: 1 1 1 1 1 1 1 1 1 1 ...


# aggregate(COAL$Emissions, by=list(COAL$year), FUN=sum)

ggplot(data = COAL, aes(x = year, y = Emissions)) + 
    stat_summary(fun.y=sum,geom="line") +
    coord_cartesian() +
    theme_bw() +
    labs(x = "Year", y = "Total Emissions (tons)") +
    ggtitle("PM2.5 Coal Combustion Emissions Across US for 1999-2008")
```

![](files/Q4-1.png) 

###5. How have emissions from motor vehicle sources changed from 1999-2008 in **Baltimore City**? 

Answer: Emissions decreased sharply from 1999-2002 (400 to 190), stayed rather flat from 2002-2005, then dropped again from 2005-2008 (180 to 135)

```r
# explore columns to find which ones indicate motor vehicle 
colNames <- c("SCC.Level.One","SCC.Level.Two","SCC.Level.Three","SCC.Level.Four","Usage.Notes")
for (col in colNames){
    print(paste0("## checking [",col,"] ##"))
    print(levels(as.factor(grep(x=ALL[[col]], pattern = "motor | vehicle", ignore.case = TRUE, value = TRUE))))
}
## [1] "## checking [SCC.Level.One] ##"
## character(0)
## [1] "## checking [SCC.Level.Two] ##"
## [1] "Highway Vehicles - Diesel"             
## [2] "Highway Vehicles - Gasoline"           
## [3] "Off-highway Vehicle Diesel"            
## [4] "Off-highway Vehicle Gasoline, 2-Stroke"
## [5] "Off-highway Vehicle Gasoline, 4-Stroke"
## [1] "## checking [SCC.Level.Three] ##"
##  [1] "Filling Vehicle Gas Tanks - Stage II"                  
##  [2] "Heavy Duty Diesel Vehicles (HDDV) Class 2B"            
##  [3] "Heavy Duty Diesel Vehicles (HDDV) Class 3, 4, & 5"     
##  [4] "Heavy Duty Diesel Vehicles (HDDV) Class 6 & 7"         
##  [5] "Heavy Duty Diesel Vehicles (HDDV) Class 8A & 8B"       
##  [6] "Heavy Duty Gasoline Vehicles 2B thru 8B & Buses (HDGV)"
##  [7] "Light Duty Diesel Vehicles (LDDV)"                     
##  [8] "Light Duty Gasoline Vehicles (LDGV)"                   
##  [9] "Motor Vehicle Fires"                                   
## [10] "Motor Vehicles: SIC 371"                               
## [1] "## checking [SCC.Level.Four] ##"
## [1] "All Terrain Vehicles"                  
## [2] "Paved Roads: All Vehicle Types"        
## [3] "Specialty Vehicles/Carts"              
## [4] "Unpaved Roads: Heavy Duty Vehicles"    
## [5] "Unpaved Roads: Light Duty Vehicles"    
## [6] "Unpaved Roads: Medium Duty Vehicles"   
## [7] "Vehicle Traffic: Light/Medium Vehicles"
## [1] "## checking [Usage.Notes] ##"
## character(0)

#Based on findings, subset of data will be done by searching for 'vehicle' in SCC.Level.Two (highest level) where location is Baltimore City, Maryland (`fips == "24510"`)
ALL$isVehicle <- grepl("motor | vehicle", ALL$SCC.Level.Two, ignore.case = TRUE)
outColumns <- c("SCC","year","fips","Emissions","SCC.Level.One","SCC.Level.Two","SCC.Level.Three","SCC.Level.Four","Usage.Notes")
BVEHICLES <- ALL[ (ALL$fips == "24510") & (ALL$isVehicle), outColumns] 
str(BVEHICLES)
## 'data.frame':	1393 obs. of  9 variables:
##  $ SCC            : chr  "2201001170" "2201001170" "2201001170" "220100117B" ...
##  $ year           : int  2008 2008 2008 2005 2002 2002 2005 2005 2002 2008 ...
##  $ fips           : chr  "24510" "24510" "24510" "24510" ...
##  $ Emissions      : num  0.0024 0.00303 0.00114 0.00257 0.01 ...
##  $ SCC.Level.One  : Factor w/ 17 levels "Brick Kilns",..: 9 9 9 9 9 9 9 9 9 9 ...
##  $ SCC.Level.Two  : Factor w/ 146 levels "","Agricultural Chemicals Production",..: 49 49 49 49 49 49 49 49 49 49 ...
##  $ SCC.Level.Three: Factor w/ 1061 levels "","100% Biosolids (e.g., sewage sludge, manure, mixtures of these matls)",..: 587 587 587 587 587 587 587 587 587 587 ...
##  $ SCC.Level.Four : Factor w/ 6084 levels "","(NH4)2 SO4 Acid Bath System and Evaporator",..: 4785 4785 4785 4781 4781 4784 4784 4783 4783 4795 ...
##  $ Usage.Notes    : Factor w/ 21 levels ""," ","includes bleaching towers, washer hoods, filtrate tanks, vacuum pump exhausts",..: 1 1 1 1 1 1 1 1 1 1 ...

#Plot the changes over the time period.  two approaches to the same result
ggplot(data = BVEHICLES, aes(x = year, y = Emissions)) + 
    stat_summary(fun.y=sum,geom="line") +
    coord_cartesian() +
    theme_bw() +
    labs(x = "Year", y = "Total Emissions (tons)") +
    ggtitle("PM2.5 Coal Combustion Emissions in Baltimore City, MD for 1999-2008")
```

![](files/Q5-1.png) 

```r

ggplot(data = ALL[(ALL$fips == "24510") & (ALL$isVehicle),], aes(x = year, y = Emissions)) + 
    stat_summary(fun.y=sum, geom="line") +
    theme_bw() +
    labs(x = "Year", y = "Total Emissions (tons)") +
    ggtitle("PM2.5 Vehicle Emissions in Baltimore City, MD for 1999-2008")
```

![](files/Q5-2.png) 

```r

#validate the graph with raw data
# aggregate(BVEHICLES$Emissions, by=list(BVEHICLES$year), FUN=sum)
```


###6. Compare emissions from motor vehicle sources in Baltimore City (`fips == "24510"`) with emissions from motor vehicle sources in **Los Angeles County**, California (`fips == "06037"`). Which city has seen greater changes over time in motor vehicle emissions?

Answer: Los Angeles has seen greater changes over time, going from 6000 to 7000 and then back down to 6500.  Los angeles emisions have consitently been significantly higher than Baltimore.  Baltimore's Emissions have been relativley more stable and slowly decreased

```r

# explore columns to find which ones indicate motor vehicle 
colNames <- c("SCC.Level.One","SCC.Level.Two","SCC.Level.Three","SCC.Level.Four","Usage.Notes")
for (col in colNames){
    print(paste0("## checking [",col,"] ##"))
    print(levels(as.factor(grep(x=ALL[[col]], pattern = "motor | vehicle", ignore.case = TRUE, value = TRUE))))
}
## [1] "## checking [SCC.Level.One] ##"
## character(0)
## [1] "## checking [SCC.Level.Two] ##"
## [1] "Highway Vehicles - Diesel"             
## [2] "Highway Vehicles - Gasoline"           
## [3] "Off-highway Vehicle Diesel"            
## [4] "Off-highway Vehicle Gasoline, 2-Stroke"
## [5] "Off-highway Vehicle Gasoline, 4-Stroke"
## [1] "## checking [SCC.Level.Three] ##"
##  [1] "Filling Vehicle Gas Tanks - Stage II"                  
##  [2] "Heavy Duty Diesel Vehicles (HDDV) Class 2B"            
##  [3] "Heavy Duty Diesel Vehicles (HDDV) Class 3, 4, & 5"     
##  [4] "Heavy Duty Diesel Vehicles (HDDV) Class 6 & 7"         
##  [5] "Heavy Duty Diesel Vehicles (HDDV) Class 8A & 8B"       
##  [6] "Heavy Duty Gasoline Vehicles 2B thru 8B & Buses (HDGV)"
##  [7] "Light Duty Diesel Vehicles (LDDV)"                     
##  [8] "Light Duty Gasoline Vehicles (LDGV)"                   
##  [9] "Motor Vehicle Fires"                                   
## [10] "Motor Vehicles: SIC 371"                               
## [1] "## checking [SCC.Level.Four] ##"
## [1] "All Terrain Vehicles"                  
## [2] "Paved Roads: All Vehicle Types"        
## [3] "Specialty Vehicles/Carts"              
## [4] "Unpaved Roads: Heavy Duty Vehicles"    
## [5] "Unpaved Roads: Light Duty Vehicles"    
## [6] "Unpaved Roads: Medium Duty Vehicles"   
## [7] "Vehicle Traffic: Light/Medium Vehicles"
## [1] "## checking [Usage.Notes] ##"
## character(0)
?with
## starting httpd help server ... done
#Based on findings, subset of data for vehicles will be done by searching for 'vehicle' in SCC.Level.Two (highest level) 
ALL$isVehicle <- grepl("motor | vehicle", ALL$SCC.Level.Two, ignore.case = TRUE)
outColumns <- c("SCC","year","fips","Emissions","SCC.Level.One","SCC.Level.Two","SCC.Level.Three","SCC.Level.Four","Usage.Notes")
BVEHICLES <- ALL[ (ALL$fips %in% c("06037","24510")) & (ALL$isVehicle), outColumns] 
str(BVEHICLES)
## 'data.frame':	2717 obs. of  9 variables:
##  $ SCC            : chr  "2201001000" "2201001110" "2201001110" "2201001110" ...
##  $ year           : int  2002 1999 2008 2008 2008 2002 2005 2002 2005 2005 ...
##  $ fips           : chr  "06037" "06037" "06037" "06037" ...
##  $ Emissions      : num  0.25 4.93 249.88 92.97 528.01 ...
##  $ SCC.Level.One  : Factor w/ 17 levels "Brick Kilns",..: 9 9 9 9 9 9 9 9 9 9 ...
##  $ SCC.Level.Two  : Factor w/ 146 levels "","Agricultural Chemicals Production",..: 49 49 49 49 49 49 49 49 49 49 ...
##  $ SCC.Level.Three: Factor w/ 1061 levels "","100% Biosolids (e.g., sewage sludge, manure, mixtures of these matls)",..: 587 587 587 587 587 587 587 587 587 587 ...
##  $ SCC.Level.Four : Factor w/ 6084 levels "","(NH4)2 SO4 Acid Bath System and Evaporator",..: 5555 4775 4775 4775 4775 4771 4771 4774 4774 4773 ...
##  $ Usage.Notes    : Factor w/ 21 levels ""," ","includes bleaching towers, washer hoods, filtrate tanks, vacuum pump exhausts",..: 1 1 1 1 1 1 1 1 1 1 ...

#http://www.cookbook-r.com/Graphs/Legends_(ggplot2)/

#subset data when providing it to ggplot
ggplot(data = ALL[(ALL$fips %in% c("06037","24510")) & (ALL$isVehicle),] ) +  
    #map aes, sum data, specify line
    stat_summary( mapping = aes(x = year, y = Emissions, color=fips), fun.y=sum, geom="line" ) +    
    #modify legend labels http://www.cookbook-r.com/Graphs/Legends_(ggplot2)/
    scale_color_discrete(name="Location", breaks = c("06037","24510"), labels = c("Los Angeles, CA","Baltimore City, MD")) +    
    theme_bw() +
    labs(x = "Year", y = "Emissions (tons)") +
    ggtitle("PM2.5 Total Vehicle Emissions")
```

![](files/Q6-1.png) 



