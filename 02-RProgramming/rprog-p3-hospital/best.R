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
## Returns the hospital name in the given state with lowest 30-day death rate for the given outcome. 
best <- function(state, outcome) {
  setwd('~/Documents/Coursera-DataScience/rprog-p3-hospital/')

  ## Read outcome data, Exclude NA's na.strings=c("Not Available","NA")
  data <- read.csv("~/Documents/Coursera-DataScience/rprog-p3-hospital/rprog-data-ProgAssignment3-data/outcome-of-care-measures.csv", na.strings=c("Not Available","NA"), stringsAsFactors=FALSE)
  
  ## Check that state and outcome are valid
  validStates = as.factor(data[,7])
  if(!state %in% validStates) {stop("invalid state")}
  
  validOutcomes = c("heart attack", "heart failure", "pneumonia")
  if(!outcome %in% validOutcomes) {stop("invalid outcome")}
    
  # use input 'outcome' to determine what column to look at
  #   [2] "Hospital.Name"                                                                        
  #   [7] "State"                                                                                
  #   [11] "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Attack"    
  #   [17] "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Failure"                           
  #   [23] "Hospital.30.Day.Death..Mortality..Rates.from.Pneumonia"                               
  if(outcome =="heart attack") colnum = 11
  else if(outcome =="heart failure") colnum = 17
  else if(outcome =="pneumonia") colnum = 23
  
  # filter results to the state, return the column that we're looking for
  filtered = subset(data, State==state)
  
  #order results by the outcome values and hospital name, return only c(hospital,state,values), NA will be at bottom
  sorted <- filtered[order(filtered[,colnum],filtered[,2], na.last=TRUE),c(2,7,11)]
  
  #remove NA's
  sorted <- na.omit(sorted)
  
  #this means the top row, first column is the value we want
  return(sorted[1,1])
  
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
# Useful Sites
# http://www.rexamples.com/11/Filtering%20data
# http://www.cookbook-r.com/
# http://cran.r-project.org/doc/contrib/Short-refcard.pdf
# http://www.statmethods.net/