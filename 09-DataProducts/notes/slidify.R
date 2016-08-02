#SLIDIFY
#http://slidify.org/
#---Quick Start-----------------
install.packages("devtools"); library(devtools)
install_github('slidify', 'ramnathv')
install_github('slidifyLibraries', 'ramnathv')
library(slidify)

setwd("~/sample/project")
author("first_deck") # create project and give it a name
  #creates project dir
  #creates & populates 'assets' dir
  #opens new index.Rmd file

# edit the document that opens (yamel and slides)

sidify('index.Rmd')  #generate the presentation

library(knitr)
browseURL('index.html') #view in browser


publish_github(user,repo) #Publish to Github

#HTML5 Deck Frameworks
# io2012
# html5slides
# deck.js
# dzslides
# landslide
# Slidy

# Mathjax - latex math formatting
# HTML - put it directly into the mardown file