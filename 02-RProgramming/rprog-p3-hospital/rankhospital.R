### Ranking hospitals by outcome in a state
# Write a function called rankhospital that takes three arguments: the 2-character abbreviated name of a state (state), an outcome (outcome), and the ranking of a hospital in that state for that outcome (num). The function reads the outcome-of-care-measures.csv file and returns a character vector with the name of the hospital that has the ranking specified by the num argument. For example, the call
# > rankhospital("MD", "heart failure", 5)
# would return a character vector containing the name of the hospital with the 5th lowest 30-day death rate for heart failure. The num argument can take values “best”, “worst”, or an integer indicating the ranking (smaller numbers are better). If the number given by num is larger than the number of hospitals in that state, then the function should return NA. Hospitals that do not have data on a particular outcome should be excluded from the set of hospitals when deciding the rankings.
# Handling ties. It may occur that multiple hospitals have the same 30-day mortality rate for a given cause of death. In those cases ties should be broken by using the hospital name. For example, in Texas (“TX”), the hospitals with lowest 30-day mortality rate for heart failure are shown here.
# The function should check the validity of its arguments. If an invalid state value is passed to best, the function should throw an error via the stop function with the exact message “invalid state”. If an invalid outcome value is passed to best, the function should throw an error via the stop function with the exact message “invalid outcome”.

## Check that state and outcome are valid
## Return hospital name in that state with the given rank 30-day death rate
rankhospital <- function(state, outcome, num = "best") {
  setwd('~/Documents/Coursera-DataScience/rprog-p3-hospital/')
  
  ## Read outcome data, Exclude NA's na.strings=c("Not Available","NA")
  data <- read.csv("~/Documents/Coursera-DataScience/rprog-p3-hospital/rprog-data-ProgAssignment3-data/outcome-of-care-measures.csv", na.strings=c("Not Available","NA"), stringsAsFactors=FALSE)
  
  ## validate state input
  validStates = as.factor(data[,7])
  if(!state %in% validStates) {stop("invalid state")}
  
  # Validate outome input
  validOutcomes = c("heart attack", "heart failure", "pneumonia")
  if(!outcome %in% validOutcomes) {stop("invalid outcome")}
  
  # Validate num input (“best”, “worst”, or an integer)
  if(!class(num)=="numeric" & !num %in% c("best","worst")) stop("invalid num")
  

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
  #print(sorted)
  
  #return the value based on the desired rank
  if(class(num)=="numeric") rank=num
  else if(num=="best") rank=1
  else if(num=="worst") rank=length(sorted[,1]) 

  return(sorted[rank,1]) 
  
}
# Here is some sample output from the function.
# > source("rankhospital.R")
# > rankhospital("TX", "heart failure", 4)
# [1] "DETAR HOSPITAL NAVARRO"
# > rankhospital("MD", "heart attack", "worst")
# [1] "HARFORD MEMORIAL HOSPITAL"
# > rankhospital("MN", "heart attack", 5000)
# [1] NA





