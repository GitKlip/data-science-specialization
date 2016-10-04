#Data Science Specialization - Capstone Project 
##Natural Language Processing

<img src="./figures/capstone-sponsors.png" alt="Course Sponsors" "/>

###Objective
The objective of the capstone project was to build a predictive model and implement a web app that predicts the next word when a user enters a phrase.

<img src="./figures/swiftKey-splash-2.jpg" alt="Context Image" style="width: 200px;"/>

###Take Aways
* Natural Language Processing is challenging and fun.
* There are often simpler ways to accomplish a goal that get close to the results of a more complex method. 
* Tradeoffs between performance and accuracy must always be considered in light of the goal you're trying to accomplish.

### Results
* [Milestone Analysis Report](http://rpubs.com/ercorne/ds_capstone_milestone) with results of data exploration performed in 'R' and published via RPubs
* Short [Project Presentation](http://rpubs.com/ercorne/ds_capstone_presentation) created in 'R Presentation' and published via RPubs
* [Interactive Web App](https://cornelsen.shinyapps.io/NLP_Text_Predictor/) Developed in 'Shiny' and published via shinyapps.io
* [Source Code](https://github.com/GitKlip/data-science-specialization/tree/master/10-CapstoneNLP) for the project in GitHub

### Next Steps
I think I've done a decent job of accomplishing the goals that were set out.  I see some additonal areas that can be improved upon and am jotting them down here for future development:

* Model - Address weakenss of Stupid Backoff Model (long range Context). ?Clustering, Parts of Speach? 
* WebApp - Add optional submit button (like sending a text message).  Display Sentance History in upper window after submit
* WebApp - Add Sentence History to the model dynamically (build ngrams)
* Model/WebApp - Add Dictionary/Thesaurus for english language to help with predicting new/unknown words
* Model/WebApp - Predict Current Word after 3 characters typed
* WebApp - Able to Click on best predicted word. inserts it into text box. Gives +1 to model dynamically. ?Display Horizontal?
* Model - Add MLE calculation.  Compare Frequency prediction with MLE prediction.

