#    http://shiny.rstudio.com/
# The goal of this exercise is to create a product to highlight the prediction algorithm that you have built and to provide an interface that can be accessed by others via a Shiny app..
# Tasks to accomplish
#     - Create a data product to show off your prediction algorithm You should create a Shiny app that accepts an n-gram and predicts the next word.
# Questions to consider
#     - What are the most interesting ways you could show off your algorithm?
#     - Are there any data visualizations you think might be helpful (look at the Swiftkey data dashboard if you have it loaded on your phone)?
#     - How should you document the use of your data product (separately from how you created it) so that others can rapidly deploy your algorithm?

# CRITERIA: Data Product
# - Does the link lead to a Shiny app with a text input box that is running on shinyapps.io?
# - Does the app load to the point where it can accept input?
# - When you type a phrase in the input box do you get a prediction of a single word after pressing submit and/or a suitable delay for the model to compute the answer?
# - Put five phrases drawn from Twitter or news articles in English leaving out the last word. Did it give a prediction for every one?



library(shiny)
library(stringi)
library(stringr)
library(data.table)
load("DT.RData", verbose=T) #DT: ng_name|ng_len|ng_src|predictor|prediction|freq|rel_freq|mle
setorder(DT, -ng_len, -freq, -rel_freq)
shinyAppDir(".")

###------------------------------------------------------------------------------------
# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(

   # Application title
    titlePanel("N-Gram Word Predictor"),

   # Sidebar with a slider input for number of bins
   sidebarLayout(
      sidebarPanel(
          textInput('predictor', 'Input Text:', placeholder = 'Type your phrase here...'),
          sliderInput("N_predictions", "Number of Word Predections:", min=1, max=15, value=5),
          tags$hr(),
          tags$img(src = 'swiftkey-splash.jpg', alt='swiftkey concept image',  width = 250)
      ),

      # Show a plot of the generated distribution
      mainPanel(
          tags$h3("Provided Text:", align="center"),
          tags$p( textOutput("predictor"), align="center"),
          tags$hr(),
          tags$h3("Next Word Predictions:", align="center"),
          tags$div(tableOutput("prediction"), align="center"),
          tags$hr(),
          tags$h4("Future Enhancements:"),
          tags$ol(
              tags$li("Add optional submit button (like sending a text message).  Display Sentance History in upper window after submit"),
              tags$li("Add Sentence History to the model dynamically (build ngrams)"),
              tags$li("Add Dictionary/Thesaurus for english language to help with predicting new/unknown words"),
              tags$li("Predict Current Word after 3 characters typed"),
              tags$li("Able to Click on best predicted word. inserts it into text box. Gives +1 to model dynamically. ?Display Horizontal?")
          )
      )
   )
))

###------------------------------------------------------------------------------------
# Define server logic required to draw a histogram
server <- shinyServer(function(input, output) {

    output$predictor <- renderText({input$predictor})
    output$prediction <- renderTable({
            as.data.table(predictNextWord(input$predictor, predictN=input$N_predictions, verbose=F))
        })

    })



###------------------------------------------------------------------------------------
#
# PREDICT
# assumes longest ngram will be the best match.
# If can't find it, 'backs off' and looks for ngrams one size smaller
# predict function can only handle 3 words being input at a time.  Need to enforce either at app or in function.
#DT: ng_name|ng_len|ng_src|predictor|prediction|freq|rel_freq|mle
getMatches <- function(query,backoff=1){
    return(DT[predictor==word(query, start=backoff, end=-1, sep=" "),])
}
#get top N predictTxt results
predictNextWord <- function(query, predictN=2, verbose=F){
    #if needed, truncate to last 3 words
    wc <- str_count(query, pattern = boundary("word"))
    if(wc>3) query <- word(query, start=-3, end=-1, sep = " ")

    ###REMOVE PUNCTUATION LIKE QUANTEDA
    #Lowercase & Trim
    query <- str_trim(str_to_lower(query), "both")
    #removePunct
    query <- stri_replace_all_regex(query, "(\\b)[\\p{Pd}](\\b)", "$1_hy_$2") # to preserve intra-word hyphens, replace with _hy_
    query <- stri_replace_all_fixed(query, "_hy_", "-") # put hyphens back the fast way


    if( nrow(getMatches(query,1)) ){
        if(verbose) print(paste("[query:",query,"] 3 word match"))
        result <- getMatches(query,1)
    } else if( nrow(getMatches(query,2)) ) {
        if(verbose) print(paste("[query:",query,"] 2 word match"))
        result <- getMatches(query,2)
    } else if ( nrow(getMatches(query,3)) ){
        if(verbose) print(paste("[query:",query,"] 1 word match"))
        result <- getMatches(query,3)
    } else{
        if(verbose) print(paste("[query:",query,"] no match"))
        result <- DT[ng_len=='1']
    }
    if(verbose) { print(head(result),predictN); out<-result[1:predictN, ]}
    else { out<- unique(as.vector(result[1:predictN, prediction])) }

    return(out)
}
# predictNextWord(query, predictN=10, verbose=T)


###------------------------------------------------------------------------------------
# Run the application
shinyApp(ui = ui, server = server)
