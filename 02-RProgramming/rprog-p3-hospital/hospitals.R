## HOW TO PREP DATA ##
# > outcome <- read.csv("~/Documents/Coursera-DataScience/rprog-p3-hospital/rprog-data-ProgAssignment3-data/outcome-of-care-measures.csv", na.strings=c("Not Available","NA"), stringsAsFactors=FALSE)
# > 
# > outcome[, 11] <- as.numeric(outcome[, 11])
# > ## You may get a warning about NAs being introduced; that is okay
# > hist(outcome[, 11])
# 
## Finding the best hospital in a state ##
# Write a function called best that take two arguments: the 2-character abbreviated name of a state and an outcome name. The function reads the outcome-of-care-measures.csv file and returns a character vector with the name of the hospital that has the best (i.e. lowest) 30-day mortality for the specified outcome in that state. The hospital name is the name provided in the Hospital.Name variable. The outcomes can be one of “heart attack”, “heart failure”, or “pneumonia”. Hospitals that do not have data on a particular outcome should be excluded from the set of hospitals when deciding the rankings.
#
# Handling ties. If there is a tie for the best hospital for a given outcome, then the hospital names should be sorted in alphabetical order and the first hospital in that set should be chosen (i.e. if hospitals “b”, “c”, and “f” are tied for best, then hospital “b” should be returned).
#
# The function should check the validity of its arguments. If an invalid state value is passed to best, the function should throw an error via the stop function with the exact message “invalid state”. If an invalid outcome value is passed to best, the function should throw an error via the stop function with the exact message “invalid outcome”.
#
best <- function(state, outcome) {

  ## Read outcome data
  data <- read.csv("~/Documents/Coursera-DataScience/rprog-p3-hospital/rprog-data-ProgAssignment3-data/outcome-of-care-measures.csv", na.strings=c("Not Available","NA"), stringsAsFactors=FALSE)
  
  ## Check that state and outcome are valid
    validStates = as.factor(data[,7])
    if(!state %in% validStates) {stop("invalid state")}
    
    validOutcomes = c("heart attack", "heart failure", "pneumonia")
    if(!outcome %in% validOutcomes) {stop("invalid outcome")}
    
    return("VALID INPUT")
    
  ## Return hospital name in that state with lowest 30-day death rate.  Exclude NA's na.strings=c("Not Available","NA")
#   2=hospital.name
#   7=state
#   11=30DayDeathRate
min(..., na.rm = FALSE)
  
}
# Here is some sample output from the function.
# > source("best.R")
# > best("TX", "heart attack")
# [1] "CYPRESS FAIRBANKS MEDICAL CENTER"
# > best("TX", "heart failure")
# [1] "FORT DUNCAN MEDICAL CENTER"
# > best("MD", "heart attack")
# [1] "JOHNS HOPKINS HOSPITAL, THE"
# > best("MD", "pneumonia")
# [1] "GREATER BALTIMORE MEDICAL CENTER"
# > best("BB", "heart attack")
# Error in best("BB", "heart attack") : invalid state
# > best("NY", "hert attack")
# Error in best("NY", "hert attack") : invalid outcome
# >
#   2
# Save your code for this function to a file named best.R
