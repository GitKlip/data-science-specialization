
#http://cran.r-project.org/web/packages/googleVis/googleVis.pdf
#https://www.coursera.org/learn/data-products/lecture/WIaxf/googlevis

install.packages("googleVis")
suppressPackageStartupMessages(library(googleVis))
M<- gvisMotionChart(Fruits, "Fruit", "Year", options=list(width=600, height=400))
plot(M)#R Display Method
print(M, "chart")#Slidify Display Method

# https://developers.google.com/chart/interactive/docs/gallery/geochart  >> Configuration Options
# https://github.com/mages/Introduction_to_googleVis/blob/gh-pages/index.Rmd

demo(googleVis)
