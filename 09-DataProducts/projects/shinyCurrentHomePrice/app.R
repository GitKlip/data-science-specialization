# shinyAPP Published: https://cornelsen.shinyapps.io/shinyCurrentHomePrice/
# rPresenter Published: http://rpubs.com/ercorne/shinyHomeHPI
# Code on GitHub: https://github.com/GitKlip/9-DataProducts


# http://www.fhfa.gov/DataTools/Downloads/Pages/House-Price-Index.aspx
#   The HPI is a broad measure of the movement of single-family house prices. The HPI is a weighted, repeat-sales index, meaning that it measures average price changes in repeat sales or refinancings on the same properties. This information is obtained by reviewing repeat mortgage transactions on single-family properties whose mortgages have been purchased or securitized by Fannie Mae or Freddie Mac since January 1975.
#   The HPI serves as a timely, accurate indicator of house price trends at various geographic levels. Because of the breadth of the sample, it provides more information than is available in other house price indexes. It also provides housing economists with an improved analytical tool that is useful for estimating changes in the rates of mortgage defaults, prepayments and housing affordability in specific geographic areas.
#   The HPI includes house price figures for the nine Census Bureau divisions, for the 50 states and the District of Columbia, and for Metropolitan Statistical Areas (MSAs) and Divisions.
#   FHFA publishes monthly and quarterly HPI reports.
# http://www.fhfa.gov/DataTools/Downloads/Pages/House-Price-Index-Datasets.aspx#qpo
# http://www.fhfa.gov/PolicyProgramsResearch/Research/Pages/wp1601.aspx
# http://www.fhfa.gov/DataTools/Downloads/Documents/HPI/HPI_AT_3zip.xlsx
# http://www.fhfa.gov/DataTools/Downloads/Documents/HPI/HPI_AT_ZIP5.xlsx
#
# "HPI for Five-Digit ZIP Codes (All-Transactions Index)
# Experimental Indexes Showing Cumulative (Nominal) Annual Appreciation"
#
# * These annual ZIP5 indexes should be considered developmental. As with the standard FHFA HPIs, revisions to these indexes may reflect the impact of new data or technical adjustments. Indexes are calibrated using appraisal values and sales prices for mortgages bought or guaranteed by Fannie Mae and Freddie Mac. As discussed in the Working Paper 16-01, in cases where sample sizes are small for the five-digit ZIP Code area, an index is either not reported if recording has not started or a missing value is reported with a period ("."). Index values always reflect the native five-digit ZIP index, i.e. they are not made with data from another area or year. Three HPI values are provided and, since the indexes reflect cumulative appreciation since a certain period, the values reflect the base year being used (annual appreciations are the same). Column A is the ZIP code, Column B is the year, Column C is the annual change, Column D is the index value with a base of 100 when first recorded, Column E is the index value with a base of 100 in 1990, and Column F is the index value with a base of 100 in 2000. If a ZIP code has a missing value in Column D in 1990 or 2000 then the ZIP code will have blank values in Column E or F, respectively.
#
# ** For tracking and feedback purposes, please cite Working Paper 16-01 when using these data. A suggested form is: Bogin, A., Doerner, W. and Larson, W. (2016). Local House Price Dynamics: New Indices and Stylized Facts. Federal Housing Finance Agency, Working Paper 16-01. The working paper is accessible at http://www.fhfa.gov/papers/wp1601.aspx.



#TODO - documentation for class submission
#TODO - Input Validation (year not in data, zip not in data)
#TODO - numeric zip not being restricted by 'max=' attribute.  why?
#TODO - display old/new indexes, price difference and direction,
#TODO - improve plot
#TODO - use zip3 data. reduces geo zoom, increases time to monthly, more up to date data.
#TODO - add auto data update ability for zip3 (would require rio or something to read .xlsx)
#TODO - research better ways to make shiny apps
#     https://blog.rstudio.org/2014/06/19/interactive-documents-an-incredibly-easy-way-to-use-shiny/
#     http://shiny.rstudio.com/articles/interactive-docs.html
#     http://rmarkdown.rstudio.com/flexdashboard/shiny.html
#TODO - get rio or other xlsx read options to work for loading current data directly from url

### COMMON ###
# ?global?.  will only run once
library(shiny)
library(lubridate)
setwd("./")

#Load data
#couldn't get rio or other xlsx read options to work, so...
#download data from here: "http://www.fhfa.gov/DataTools/Downloads/Documents/HPI/HPI_AT_ZIP5.xlsx"
#save data in .csv format with just a single header row.
fileName <- "data/HPI_AT_ZIP5.csv"
df <- read.table( file=fileName, sep=",", header=TRUE, stringsAsFactors=TRUE,
                    na.strings = c("NA","","#DIV/0!",NA,".")) #account for various NA strings

#Function to calculate the new predicted price
calcNewPrice <- function(pYear,pPrice,zipDF){
    oldIndex <- zipDF[zipDF$Year==pYear,"HPI"]
    newIndex <- zipDF[zipDF$Year==max(zipDF$Year),"HPI"]
    oldPrice <- pPrice
    newPrice <- (oldPrice * newIndex) / oldIndex
    return(newPrice)
}


### UI DEFINITION ###
# UI user provides:
# INPUT: zipcode, purchase date, purchase price
# OUTPUT: trend plot of index, prediction of current home value

ui <- shinyUI(
    pageWithSidebar(
        #Appliction Title
        headerPanel("Estimate Current Home Value using HPI"),

        sidebarPanel(
            "Fill out the form below with the details of your hope purchase and click the submit button.",
            numericInput('zipCode', 'Home Zip Code:', 84043 ,min=0,max=99999),
            dateInput('purchaseDate', 'Home Purchase Date:',value='2013-01-01',max = today()),
            numericInput('purchasePrice', 'Home Purchase Price:',100000),
            submitButton('Submit'),
            HTML("<hr/><b>**NOTE**:</b>"),
            "The current implementation is a 'stupid simple' way to calculate your current home value and should not be used for financial decisions."
        ),

        mainPanel(
            plotOutput('indexPlot'),
            h4('Your estimated current home value is:'),
            verbatimTextOutput("prediction"),
            HTML("<hr>"),
            h4("About the Data:"),
            "The Housing Price Index (HPI) is an accurate indicator of house price trends at various geographic levels.  It is provided by the  Federal Housing Finance Agency (www.fhfa.gov) and it measures average price changes in repeat sales or refinancings on the same single-family properties."
        )
    )
)
### SERVER DEFINITION ###
# will execute whenever input triggers
# Server:
#   subset based on zipcode
#   plot index data and trendline
#   predict current house price  (newIndex-purchaseIndex)*purchasePrice=estimatedCurrentValue
server <- shinyServer(
    function(input, output) {

        #create a plot of the HPI by year for the specified zip code
        output$indexPlot <- renderPlot({
            zip <- input$zipCode
            plot(HPI ~ Year, data=df[df$Five.Digit.ZIP.Code==zip,], type="l",
                 main=paste("Home Price Index for Zipcode",zip))
        })

        #calculate the predicted home value
        output$prediction <- renderPrint({
            zip <- input$zipCode
            pYear <- year(input$purchaseDate)
            pPrice <- input$purchasePrice
            calcNewPrice(pYear, pPrice, df[df$Five.Digit.ZIP.Code==zip,])
        })
    }
)

### APP EXECUTION ###
shinyApp(ui = ui, server = server)
