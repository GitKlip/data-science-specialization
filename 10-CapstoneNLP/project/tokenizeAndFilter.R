

###----THE QUANTEDA WAY ###
# http://stackoverflow.com/questions/25330753/more-efficient-means-of-creating-a-corpus-and-dtm-with-4m-rows
# https://cran.r-project.org/web/packages/quanteda/vignettes/quickstart.html
# https://cran.r-project.org/web/packages/quanteda/quanteda.pdf
# profanity http://rstudio-pubs-static.s3.amazonaws.com/169109_dcd8434e77bb43da8cf057971a010a56.html

install.packages('quanteda',dependencies = TRUE)
source('library.R')
require(quanteda)

N <- 200000
txt.raw <- readDataLines('data/final/en_US/en_US.twitter.txt', nLines=N)
myCorpus <- corpus(txt.raw)
summary(myCorpus, n=5)
myCorpus[3:5]
texts(myCorpus)[3:5]
plot(summary(myCorpus))
options(width = 120); kwic(myCorpus, "village", valuetype = 'regex')
sample(myCorpus, size = ndoc(myCorpus)*.1, replace = FALSE)  #random sample
readability(myCorpus[3:5])


myCorpus


# ---
txt.dfm <- dfm(myCorpus,
    verbose = TRUE, toLower = TRUE, removeNumbers = TRUE, removePunct = TRUE,
    removeSeparators = TRUE, stem = TRUE, language = "english", removeURL = TRUE,
    ngrams = 1, skip = 0,
    ignoredFeatures = stopwords('SMART'))

length(features(txt.dfm))
topfeatures(txt.dfm, 20)
s<- sample(txt.dfm, size = length(features(txt.dfm))*.1, replace = FALSE)  #random sample
s<- sample(txt.dfm, what = "features", size = length(features(txt.dfm))*.1, replace = FALSE)
sample(txt.dfm, what='features')[ , 1:10]



if (require(RColorBrewer))
    plot(txt.dfm, max.words = 20, colors = brewer.pal(6, "Dark2"), scale = c(8, .5))


txt.dtm <- convert(txt.dfm, to = "tm")
if(require(tm))
    findFreqTerms(txt.dtm,lowfreq = 100)

# ---
# testing Twitter functions
testTweets <- c("My homie @justinbieber #justinbieber shopping in #LA yesterday #beliebers",
                "2all the ha8ers including my bro #justinbieber #emabiggestfansjustinbieber",
                "Justin Bieber #justinbieber #belieber #fetusjustin #EMABiggestFansJustinBieber")
dfm(testTweets, keptFeatures = "#*", removeTwitter = FALSE)  # keep only hashtags
dfm(testTweets, keptFeatures = "^#.*$", valuetype = "regex", removeTwitter = FALSE)

#---
#PROFANITY FILTER
http://www.frontgatemedia.com/a-list-of-723-bad-words-to-blacklist-and-how-to-use-facebooks-moderation-tool/
http://www.freewebheaders.com/full-list-of-bad-words-banned-by-google/
http://www.bannedwordlist.com/
https://raw.githubusercontent.com/shutterstock/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/master/en

###----THE TM WAY ###
# http://stackoverflow.com/questions/28033034/r-and-tm-package-create-a-term-document-matrix-with-a-dictionary-of-one-or-two
# https://gist.github.com/benmarwick/5370329


# tm intro: https://cran.r-project.org/web/packages/tm/vignettes/tm.pdf
# tm docs: https://cran.r-project.org/web/packages/tm/tm.pdf

install.packages("tm", dependencies = TRUE)
install.packages("RWeka", dependencies = TRUE)
library(tm)
library(RWeka)


### Create Corpus
# https://www.quora.com/How-do-you-create-a-corpus-from-a-data-frame-in-R
# http://cran.r-project.org/web/packages/tm/vignettes/tm.pdf
# dfCorpus <- Corpus(DataframeSource(twitter10))
dt<-data.frame(twitter10[1:1000,])
dfCorpus <- Corpus(DataframeSource(dt))
dfCorpus
class(as.vector(blogs$V1))
inspect(dfCorpus[3:5])
as.character(dfCorpus[[1]])
lapply(dfCorpus[3:5], as.character)



### Perform Transformations (whitespace, caps)
# http://stackoverflow.com/questions/15506118/make-dataframe-of-top-n-frequent-terms-for-multiple-corpora-using-tm-package-in

# process text (your methods may differ)
skipWords <- function(x) removeWords(x, stopwords(kind="SMART"))  #common, often used words that add little value
funcs <- list(tolower, removePunctuation, removeNumbers, stripWhitespace, skipWords, stemDocument)
trnfCorpus <- tm_map(dfCorpus, FUN = tm_reduce, tmFuns = funcs)
lapply(dfCorpus[3:5], as.character)
lapply(trnfCorpus[[3:5]], as.character)

class(dfCorpus)
N<-10
as.character(dfCorpus[[N]])
as.character(trnfCorpus[[N]])


### Create TermDocMatrix and find most used words
trnfCorpus.dtm <- TermDocumentMatrix(trnfCorpus, control = list(wordLengths = c(3,13)))
trnfCorpus.dtm
N <- 10
findFreqTerms(trnfCorpus.dtm, N)
m <- as.matrix(a.dtm)
v <- sort(rowSums(m), decreasing=TRUE)
head(v, N)


# make a list of the dtms
dtm_list <- list(a.dtm1, b.dtm1, c.dtm1, d.dtm1)
# apply the rowsums function to each item of the list
lapply(dtm_list, function(x)  sort(rowSums(as.matrix(x)), decreasing=TRUE))

###  Tokenize & N-Grams
# http://stackoverflow.com/questions/8898521/finding-2-3-word-phrases-using-r-tm-package
