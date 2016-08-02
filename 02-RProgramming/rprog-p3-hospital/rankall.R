# 4 Ranking hospitals in all states
# Write a function called rankall that takes two arguments: an outcome name (outcome) and a hospital rank- ing (num). The function reads the outcome-of-care-measures.csv file and returns a 2-column data frame containing the hospital in each state that has the ranking specified in num. For example the function call rankall("heart attack", "best") would return a data frame containing the names of the hospitals that are the best in their respective states for 30-day heart attack death rates. The function should return a value for every state (some may be NA). The first column in the data frame is named hospital, which contains the hospital name, and the second column is named state, which contains the 2-character abbreviation for the state name. Hospitals that do not have data on a particular outcome should be excluded from the set of hospitals when deciding the rankings.
# Handling ties. The rankall function should handle ties in the 30-day mortality rates in the same way that the rankhospital function handles ties.
# NOTE: For the purpose of this part of the assignment (and for efficiency), your function should NOT call the rankhospital function from the previous section.
# The function should check the validity of its arguments. If an invalid outcome value is passed to rankall, the function should throw an error via the stop function with the exact message “invalid outcome”. The num variable can take values “best”, “worst”, or an integer indicating the ranking (smaller numbers are better). If the number given by num is larger than the number of hospitals in that state, then the function should return NA.

## Read outcome data.  Return a data frame with the hospital names and the (abbreviated) state name for the given rank and outcome.
rankall <- function(outcome, num = "best") {
  
  setwd('~/Documents/Coursera-DataScience/rprog-p3-hospital/')
  
  ## Read outcome data, Exclude NA's na.strings=c("Not Available","NA")
  data <- read.csv("~/Documents/Coursera-DataScience/rprog-p3-hospital/rprog-data-ProgAssignment3-data/outcome-of-care-measures.csv", na.strings=c("Not Available","NA"), stringsAsFactors=FALSE)
  
  
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
  #   [23] "Hospital.30.Day.Death.s.Mortality..Rates.from.Pneumonia"  
  hospital_col = 2
  state_col = 7
  if(outcome =="heart attack") outcome_col = 11
  else if(outcome =="heart failure") outcome_col = 17
  else if(outcome =="pneumonia") outcome_col = 23
  
  #order data by the State, Outcome, and Hospital Name, return only c(hospital,state,values), NA will be at bottom
  sorted <- na.omit(data[order(data[,state_col],data[,outcome_col],data[,hospital_col], na.last=TRUE),c(2,7,outcome_col)])
  sorted <- na.omit(sorted)
  #print(head(sorted))
  #print(tail(sorted))

  

  
  #loop through each state and add it's correctly ranked item to the output list
  validStates = levels(as.factor(data[,7]))
  hospitals = NULL
  for( s in validStates) {


    #get subset of data for specified state
    statedata = sorted[sorted$State==s, 1]
    
    #determine the desired rank(r)
    if(class(num)=="numeric") r=num
    else if(num=="best") r=1
    else if(num=="worst") r=length(statedata) 
    
    #add identified hospital to the hospitals vector
    hospitals = c(hospitals,statedata[r])
   # print(s)
   # print(statedata[r])
  }
 # print(validStates)
#  print(hospitals)
  results = data.frame(hospitals,validStates)
  colnames(results) = c('hospital','state')
  #print(results)
  return(results)
}
