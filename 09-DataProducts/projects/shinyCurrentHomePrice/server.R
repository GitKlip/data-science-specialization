
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

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

shinyServer(
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

        #display to the user what calculation was done
        output$calculation <- renderPrint({
            zipDF <- df[df$Five.Digit.ZIP.Code==input$zipCode,]
            oldIndex <- zipDF[zipDF$Year==year(input$purchaseDate),"HPI"]
            newIndex <- zipDF[zipDF$Year==max(zipDF$Year),"HPI"]
            oldPrice <- input$purchasePrice
            newPrice <- (oldPrice * newIndex) / oldIndex

            paste(newPrice," = (",oldPrice,"*",newIndex,") /",oldIndex)
        })
    }
)
