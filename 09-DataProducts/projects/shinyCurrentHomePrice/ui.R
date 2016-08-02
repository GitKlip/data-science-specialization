
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(lubridate)

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
            h4('Calculation used:'),
            "currentPrice = ( purchasePrice * currentHPI ) / purchaseHPI",
            verbatimTextOutput("calculation"),
            h4('Your estimated current home value is:'),
            verbatimTextOutput("prediction"),
            HTML("<hr>"),
            h4("About the Data:"),
            "The Housing Price Index (HPI) is an accurate indicator of house price trends at various geographic levels.  It is provided by the  Federal Housing Finance Agency (www.fhfa.gov) and it measures average price changes in repeat sales or refinancings on the same single-family properties.",
            HTML("<b>CITATION:</b> Bogin, A., Doerner, W. and Larson, W. (2016). Local House Price Dynamics: New Indices and Stylized Facts. Federal Housing Finance Agency, Working Paper 16-01. The working paper is accessible at http://www.fhfa.gov/papers/wp1601.aspx")
        )
    )
)
