# The goal here is to build your first simple model for the relationship between words. This is the first step in building a predictive text mining application. You will explore simple models and discover more complicated modeling techniques.
#
# #-----
# Tasks to accomplish
#
# 1) Build basic n-gram model - using the exploratory analysis you performed, build a basic [n-gram model](http://en.wikipedia.org/wiki/N-gram) for predicting the next word based on the previous 1, 2, or 3 words.
# 2) Build a model to handle unseen n-grams - in some cases people will want to type a combination of words that does not appear in the corpora. Build a model to handle cases where a particular n-gram isn't observed.
#
# #-----
# Questions to consider
#
# 1) How can you efficiently store an n-gram model (think Markov Chains)?
# 1) How can you use the knowledge about word frequencies to make your model smaller and more efficient?
# 1) How many parameters do you need (i.e. how big is n in your n-gram model)?
# 1) Can you think of simple ways to "smooth" the probabilities (think about giving all n-grams a non-zero probability even if they aren't observed in the data) ?
# 1) How do you evaluate whether your model is any good?
# 1) How can you use [backoff models](http://en.wikipedia.org/wiki/Katz%27s_back-off_model) to estimate the probability of unobserved n-grams?
#
# #-----
# Hints, tips, and tricks
#
# As you develop your prediction model, two key aspects that you will have to keep in mind are the size and runtime of the algorithm. These are defined as:
#
#     * Size: the amount of memory (physical RAM) required to run the model in R
# * Runtime: The amount of time the algorithm takes to make a prediction given the acceptable input
#
# Your goal for this prediction model is to minimize both the size and runtime of the model in order to provide a reasonable experience to the user.
#
# Keep in mind that currently available predictive text models can run on mobile phones, which typically have limited memory and processing power compared to desktop computers. Therefore, you should consider very carefully (1) how much memory is being used by the objects in your workspace; and (2) how much time it is taking to run your model. Ultimately, your model will need to run in a Shiny app that runs on the shinyapps.io server.
#
# #-----
# Tips, tricks, and hints
#
# Here are a few tools that may be of use to you as you work on their algorithm:
#
#     * object.size(): this function reports the number of bytes that an R object occupies in memory
# * Rprof(): this function runs the profiler in R that can be used to determine where bottlenecks in your function may exist. The profr package (available on CRAN) provides some additional tools for visualizing and summarizing profiling data.
# * gc(): this function runs the garbage collector to retrieve unused RAM for R. In the process it tells you how much memory is currently being used by R.
#
# There will likely be a tradeoff that you have to make in between size and runtime. For example, an algorithm that requires a lot of memory, may run faster, while a slower algorithm may require less memory. You will have to find the right balance between the two in order to provide a good experience to the user.
#---------------------------------------

f <- function(queryHistoryTab, query, n = 2) {
  require(tau)
  #build some trigrams from the queryHistoryTab
  trigrams <- sort(tau::textcnt(rep(tolower(names(queryHistoryTab)), queryHistoryTab), method = "string", n = length(scan(text = query, what = "character", quiet = TRUE)) + 1))
  query <- tolower(query)
  idx <- which(substr(names(trigrams), 0, nchar(query)) == query)  #find which trigrams text match the query
  res <- head(names(sort(trigrams[idx], decreasing = TRUE)), n) #get matching trigrams text ordered by frequency
  res <- substr(res, nchar(query) + 2, nchar(res))  #strip out prior words and return the predicted words
  return(res)
}
f(c("Can of beer" = 3, "can of Soda" = 2, "A can of water" = 1, "Buy me a can of soda, please" = 2), "Can of")
#---------------------------------------

http://stackoverflow.com/questions/16383194/stupid-backoff-implementation-clarification
https://www.r-bloggers.com/natural-language-processing-what-would-shakespeare-say/
USE THIS: https://rpubs.com/tvganesh/PredictNextWord


#---
library(quanteda)
library(data.table)
library(stringr)

corpi <- inaugCorpus
ng1 <- dfm(corpi, ngrams=1, concatenator=" ", ignoredFeatures = stopwords("english"))
ng2 <- dfm(corpi, ngrams=2, concatenator=" ", ignoredFeatures = stopwords("english"))
ng3 <- dfm(corpi, ngrams=3, concatenator=" ", ignoredFeatures = stopwords("english"))
ng4 <- dfm(corpi, ngrams=4, concatenator=" ", ignoredFeatures = stopwords("english"))

ng2.trim <- trim(ng2, minCount=5, minDoc=2 )
ng3.trim <- trim(ng3, minCount=2, minDoc=2 )

ng.trim <- tf(rbind(ng2.trim,ng3.trim), scheme = 'count')

ng.freq <- topfeatures(ng.trim, n=length(features(ng.trim)))
ng.names <- names(ng.freq)
tot.features <- length(ng.freq)
tot.tokens <- sum(ng.freq)

dt <- data.table(ngram=ng.names,backoff1=word(ng.names, start=1, end=-2), backoff2=word(ng.names, 1) ,
                 occurances=ng.freq, corpus.coverage=ng.freq/tot.tokens   )

query<-"we must"
idx.ngm <- which(dt$ngram == query)
if(length(idx.ngm)) { #exact matchs of ngram
  print("found in ngram")
    dt[idx.ngm,]

  } else {
  idx.bo1 <- which(dt$backoff1 == query)

  if(length(idx.bo1)) {  #matchs of ngram minus last word
    print("found in backoff1")
    dt[idx.bo1,]

  } else {
    idx.bo2 <- which(dt$backoff2 == query)
    if(length(idx.bo1)) {  #matchs of ngram minus two words
        print("found in backoff2")
        dt[idx.bo1,]
    } else {
      print("InsertStopwordHere")
    }
  }
}



showPrediction<- function(DT,IDX,N){
  #get rows by idx
  #order by occurances/pct
  #get to N results
  #trim to only return last word of ngram (prediction)
}


typeof(idx.ngm)

res <- head(names(sort(trigrams[idx], decreasing = TRUE)), n) #get matching trigrams text ordered by frequency
res <- substr(res, nchar(query) + 2, nchar(res))  #strip out prior words and return the predicted words


#
# stringr::str_sub(s, )
# stringr::word(s, -1)
# stringr::str_c(word(s, -3),word(s, -2), sep = " ")
# stringr::str_locate_all(s, " ")
# stringr::str_extract_all(s,"from", simplify=T)
#
#
# gsub("_","|", s)
# grep("_", x=s, fixed=T)
# spl<- strsplit(s, split="_", )
# gregexpr('_', s)
# substr(s, , nchar(s))
# stringr::str_locate(s, "_")
#
# fellow-citizens|of of|the the|senate senate|and and|of the|house
