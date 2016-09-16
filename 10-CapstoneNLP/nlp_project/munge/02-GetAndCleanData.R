
#DONE - Remove Stemming & StopWords may harm predicting an actual word
#TODO - ?Add profanity filter?
#TODO - better way to random sample data as it's being read in?
# NGRAM stats  10% of 100k records (small)
# blogs     3.5     14.5    23.4    26.6
# news      2.66    11      18.7    17.4
# twitter   3.03    7.75    8.47    9.03
# corpi     9.26    37.1    55.93   64.15

setwd("~/Analysis/data-science-specialization/10-CapstoneNLP/nlp_project")
source('munge/utils.R')
library(stringi)
library(plyr)
library(quanteda)
# library(readr)
# library(ggplot2)
# library(pander)


### INITIALIZE
N <- -1
PCT <- .1
blnSTEM <- FALSE
argSTOP <- NULL #stopwords('SMART'))
source_files <- c("./data/final/en_US/en_US.blogs.txt","./data/final/en_US/en_US.news.txt","./data/final/en_US/en_US.twitter.txt")
cache_raw_save_file <- sprintf("./cache/nlpCache_RAW_N%d_P%d.RData",N,PCT*100)
cache_data_save_file <- paste0("./cache/nlpCache_DATA_N",N,"_P",PCT,"_STM",blnSTEM,"_STP",as.logical(argSTOP),".RData")


### READ/SAMPLE RAW DATA
if (!file.exists(cache_raw_save_file)) {
    for (f in source_files ) {
        set.seed(84043) # for reproducibility
        if(file.exists(f)){

            print(paste("Reading & Loading:",basename(f),N,PCT,blnSTEM,argSTOP))
            vName <- stri_split_fixed(basename(f), ".")[[1]][2]

            txt.raw <- readDataFile(f, nLines = N)
            if(PCT>0 & PCT<1){  #Sample if desired
                print(paste0("sampling data. PCT=",PCT*100))
                txt.raw <- sample(txt.raw, size = length(txt.raw)*PCT,  replace = FALSE)
            }

            assign(paste0(vName,".raw"), value=txt.raw)
            rm(txt.raw,vname)

        }
        else {
            print(paste("FILE NOT FOUND:",f))
        }
    }#end For

    #Save data to file to reduce need to recompute when closing and reopening session.
    print("Creating cache_raw_save_file")
    save( blogs.raw, news.raw, twitter.raw, file=cache_raw_save_file)
} else {
    load(cache_raw_save_file, verbose=TRUE)
}

## PROCESS DATA.  BASIC STATS & CREATE CORPI & DFM FOR ALL FILE NAMES
if (!file.exists(cache_data_save_file)) {
    for (f in source_files ) {
        set.seed(84043) # for reproducibility
        print(paste("Processing:",basename(f),N,PCT,blnSTEM,argSTOP))
        vName <- stri_split_fixed(basename(f), ".")[[1]][2]
        txt.raw <- get(paste0(vName,".raw"))

        print("Creating df")
        df <- data.frame(src = as.factor(vName),
                         sent.cnt = stri_count(txt.raw, regex="\\S+([.?!]|$)"),   #SentenceCount.
                         word.cnt = stri_count(txt.raw,regex="\\S+"),   #WordCount.
                         char.cnt = stri_length(txt.raw))   #CharacterCount.

        #create Basic Stats on data
        print("Creating txt.stats")
        system.time( txt.stat <- summarise(df,
                              src = vName,
                              num.rows = dim(df)[1],
                              sent.min = min(sent.cnt),
                              sent.avg = mean(sent.cnt),
                              sent.max = max(sent.cnt),
                              word.min = min(word.cnt),
                              word.avg = mean(word.cnt),
                              word.max = max(word.cnt),
                              char.min = min(char.cnt),
                              char.avg = mean(char.cnt),
                              char.max = max(char.cnt) ) )

        #create corpus from data
        print("Creating txt.cps")
        system.time( txt.cps <- corpus(txt.raw,
                          docvars=df,
                          source = f,
                          citation = "Original data from HC Corpora. see http://www.corpora.heliohost.org and http://www.corpora.heliohost.org/aboutcorpus.html",
                          notes = "training dataset https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip was provided containing a sample from HC Corpra texts in different languages. ") )


        #Create sparse/dense file matrix on data for multiple NGrams
        print("Creating dfm.ng")
        system.time( cps.dfm.ng1 <- quanteda::dfm(txt.cps, ngrams = 1, stem = blnSTEM, skip = 0, verbose=TRUE,
                         toLower=TRUE, removeNumbers=TRUE, removePunct=TRUE, removeSeparators=TRUE, removeURL=TRUE,
                         removeTwitter=TRUE, language = "english", ignoredFeatures = argSTOP) )
        system.time( cps.dfm.ng2 <- quanteda::dfm(txt.cps, ngrams = 2, stem = blnSTEM, skip = 0, verbose=TRUE,
                         toLower=TRUE, removeNumbers=TRUE, removePunct=TRUE, removeSeparators=TRUE, removeURL=TRUE,
                         removeTwitter=TRUE, language = "english", ignoredFeatures = argSTOP) )
        system.time( cps.dfm.ng3 <- quanteda::dfm(txt.cps, ngrams = 3, stem = blnSTEM, skip = 0, verbose=TRUE,
                         toLower=TRUE, removeNumbers=TRUE, removePunct=TRUE, removeSeparators=TRUE, removeURL=TRUE,
                         removeTwitter=TRUE, language = "english", ignoredFeatures = argSTOP) )

        #Give the generated data unique names in the enviornment for later combining
        assign(paste0(vName,".stat"), value=txt.stat)
        assign(paste0(vName,".cps"), value=txt.cps)
        assign(paste0(vName,".dfm.ng1"), value=cps.dfm.ng1)
        assign(paste0(vName,".dfm.ng2"), value=cps.dfm.ng2)
        assign(paste0(vName,".dfm.ng3"), value=cps.dfm.ng3)

        rm(vName,f,txt.raw,df,txt.stat,txt.cps)

    }#end for

    #put basic stats together into one df
    data.summary <- rbind(blogs=blogs.stat,news=news.stat,twitter=twitter.stat)
    rm(blogs.stat,news.stat,twitter.stat)

    #merge corpus files into one (src attribute allows proper grouping)
    corpi <- blogs.cps + news.cps + twitter.cps
    rm(blogs.cps, news.cps, twitter.cps)

    #Create DFM/NGRAM from all combined corpi
    print("Creating corpi.ng")
    system.time( corpi.dfm.ng1 <- quanteda::dfm(corpi, ngrams = 1, stem = blnSTEM, skip = 0, verbose=TRUE,
                                toLower=TRUE, removeNumbers=TRUE, removePunct=TRUE, removeSeparators=TRUE, removeURL=TRUE,
                                removeTwitter=TRUE, language = "english", ignoredFeatures = argSTOP) )
    system.time( corpi.dfm.ng2 <- quanteda::dfm(corpi, ngrams = 2, stem = blnSTEM, skip = 0, verbose=TRUE,
                                toLower=TRUE, removeNumbers=TRUE, removePunct=TRUE, removeSeparators=TRUE, removeURL=TRUE,
                                removeTwitter=TRUE, language = "english", ignoredFeatures = argSTOP) )
    system.time( corpi.dfm.ng3 <- quanteda::dfm(corpi, ngrams = 3, stem = blnSTEM, skip = 0, verbose=TRUE,
                                toLower=TRUE, removeNumbers=TRUE, removePunct=TRUE, removeSeparators=TRUE, removeURL=TRUE,
                                removeTwitter=TRUE, language = "english", ignoredFeatures = argSTOP) )


    #Save data to file to reduce need to recompute when closing and reopening session.
    print("Creating cacheSaveFile")
    save(data.summary, corpi, corpi.dfm.ng1, corpi.dfm.ng2, corpi.dfm.ng3,# corpi.dfm.ng4,
         blogs.dfm.ng1, blogs.dfm.ng2, blogs.dfm.ng3, #blogs.dfm.ng4,
         news.dfm.ng1, news.dfm.ng2, news.dfm.ng3, #news.dfm.ng4,
         twitter.dfm.ng1, twitter.dfm.ng2, twitter.dfm.ng3, #twitter.dfm.ng4,
         file=cache_data_save_file)
} else {
    load(cache_data_save_file, verbose=TRUE)
}

#
# summary(corpi)
# summary(subset(corpi, src == "news" ))


# compare corpi.dfm.ng2.indv(132,320,497,588) and corpi.dfm.ng2.grps
# summary(corpi)
# system.time(
# corpi.dfm.ng2.grps <- quanteda::dfm(corpi, ngrams = 2, stem = TRUE, skip = 0, verbose=TRUE, groups="src",
#                             toLower=TRUE, removeNumbers=TRUE, removePunct=TRUE, removeSeparators=TRUE, removeURL=TRUE,
#                             language = "english",ignoredFeatures = stopwords('SMART'))
#     )


# if (!file.exists(cache_save_file)) {
#
#     unigrams <- quanteda::dfm(corpustrain, ngrams = 1, groups = "src", verbose = FALSE)
#     bigrams  <- quanteda::dfm(corpustrain, ngrams = 2, groups = "src", verbose = FALSE)
#     trigrams <- quanteda::dfm(corpustrain, ngrams = 3, groups = "src", verbose = FALSE)
#     quadgrams <- quanteda::dfm(corpustrain, ngrams = 4, groups = "src", verbose = FALSE)
#     quintgrams <- quanteda::dfm(corpustrain, ngrams = 5, groups = "src", verbose = FALSE)
#
#     save(corpustrain, unigrams, bigrams, trigrams, quadgrams, quintgrams, file = corpus_file)
# } else {
#     load(cache_save_file)
# }
#
#
#


#PROFANITY FILTER
# http://www.frontgatemedia.com/a-list-of-723-bad-words-to-blacklist-and-how-to-use-facebooks-moderation-tool/
#     http://www.freewebheaders.com/full-list-of-bad-words-banned-by-google/
#     http://www.bannedwordlist.com/
#     https://raw.githubusercontent.com/shutterstock/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/master/en


###CREATE N-GRAMS
# http://www.universitypress.org.uk/journals/ami/20-656.pdf  (Stemming with NGrams)
# https://www.elastic.co/guide/en/elasticsearch/guide/current/_ngrams_for_partial_matching.html







##--------------------------------------------------------------
# ### IMPORT DATA INTO CORPUS
# for (f in source_files ) {
#     corpusName <- substr(basename(f), 1, nchar(basename(f)) - 4) #get filename w/o path or extension
#     print(paste("loading corpus:",corpusName))
#     myCorpus <- corpus( readDataLines(f,nLines = N) )  #TODO - need to random sample the file
#     myCorpus[["wc"]] <- stri_count(myCorpus[1:ndoc(myCorpus)],regex="\\S+")
#     myCorpus[["chars"]] <- stri_length(myCorpus[1:ndoc(myCorpus)])
#     myCorpus[["src"]] <- basename(f)
#
#     assign(corpusName, myCorpus) #assign corpus to a var in the environment based on the filename
#
#     rm(corpusName,myCorpus,f)
# }


# ### GET BASIC STATS
# #TODO - this seems to run VERY SLOW.  need to consider performing the stats on the raw character vectors using grep or apply or something else.
# getCorpusStats <- function(myCorpus) {
#     df <- summary(myCorpus, n=ndoc(myCorpus), verbose=FALSE)
#     print(paste("processing corpus stats:",corpusName))
#     corpus.stats <- data.frame(
#         mem.size.MB = print(object.size(myCorpus)[1]/1000000), #size in memory (MB)
#         num.rows = dim(df)[1],
#         sent.min = min(df$Sentences),
#         sent.max = max(df$Sentences),
#         sent.avg = mean(df$Sentences),
#         wc.min = min(df$wc),
#         wc.max = max(df$wc),
#         wc.avg = mean(df$wc),
#         char.min = min(df$chars),
#         char.max = max(df$chars),
#         char.avg = mean(df$chars)
#     )
#     return(corpus.stats)
# }
# corpi.stats <- rbind.data.frame( blogs=getCorpusStats(en_US.blogs), news=getCorpusStats(en_US.news), twitter=getCorpusStats(en_US.twitter))
# corpi.stats

#
# ###----------------
# f<-"./data/final/en_US/en_US.news.txt"
# substr(basename(f), 1, nchar(basename(f)) - 4)
# split(paste0(basename(f)),sep='.')
#
# ---
# options(width = 120);
# l<-kwic(en_US.twitter, "love", valuetype = 'fixed', window=0, case_insensitive = FALSE)
# h<-kwic(en_US.twitter, "hate", valuetype = 'fixed', window=0, case_insensitive = FALSE)
# b<-kwic(en_US.twitter, "biostats", valuetype = 'fixed', window=7)
# s<-kwic(en_US.twitter, "A computer once beat me at chess, but it was no match for me at kickboxing", valuetype = 'fixed', window=0)
#
# grep("biostats",txt.raw)
# txt.raw[556872]
# sum(stri_count(txt.raw,regex="biostats") )
# na.exclude(stri_match(txt.raw,regex="biostats"))
# stri_extract(txt.raw,regex="biostats")
# stri_match_all_regex(txt.raw,pattern="biostats")
# (txt.raw,regex="biostats")

# x<-l
# class(x)
# typeof(x)
# str(x)
# head(x)
# dim(x)
#
# save(h,l, file='./cache/myCache.Rdat')
# dim(l)[1] / dim(h)[1]
#
# grepl( "love", en_US.news)
# grep( "love", en_US.news)
#
# twitter[rbinom(length(twitter)*.10, length(twitter), .5)]
# sample(myCorpus, size = ndoc(myCorpus)*.1, replace = FALSE)  #random sample
# readability(myCorpus[3:5])
##------------------------------------------------------------
#
# ## INIT
# # source('munge/utils.R')
# #library(readr)
# library(stringi)
# library(quanteda)
# # library(ggplot2)
# # library(pander)
#
# getwd()
#
#
# ### INITIALIZE
# N <- -1
#
# F <- c("./data/final/en_US/en_US.twitter.txt")
# file.exists(F)
#
# sc <- function(txt) { stri_count(txt, regex="\\S+([.?!]|$)") }  #SentenceCount. find 1+word and punctuation or end of line.
# wc <- function(txt) { stri_count(txt,regex="\\S+") }  #WordCount.
# cc <- function(txt) { stri_length(txt) }  #CharacterCount.
#
# tst.w <- c("this is a string current trey","nospaces","multiple    spaces","   leadingspaces","trailingspaces    ","    leading and trailing    ","just one space each")
# tst.s <- c("sentance one. sentance two!ssss sentance three? sentance four.")
# sc(tst.s)
# wc(tst.w)
# cc(tst.w)
#
#
# ## ReadThenCalc vs ReadAndCalc..  Vector based with ReadThenCalc wins
# system.time({    txt.raw <- readLines(F, n = N, warn = TRUE, skipNul = TRUE)  })
# system.time({    df<-data.frame(sent.cnt = sc(txt.raw), word.cnt=wc(txt.raw), char.cnt=cc(txt.raw))  })
# system.time({    txt.cps <- corpus(txt.raw, docvars=df, source = "somewhere", citation = "over the rainbow", notes = "my notes") })
# > system.time({    txt.raw <- readLines(F, n = N, warn = TRUE, skipNul = TRUE)  })
# user  system elapsed
# 12.38    0.38   12.76
# >   system.time({    df<-data.frame(sentences = sc(txt.raw), words=wc(txt.raw), chars=cc(txt.raw))  })
# user  system elapsed
# 36.69    0.39   37.08
# >   system.time({    txt.cps <- corpus(txt.raw) })
# user  system elapsed
# 13.12    0.38   13.49
# > system.time({    txt.cps <- corpus(txt.raw, docvars=df, source = "somewhere", citation = "over the rainbow", notes = "my notes") })
# user  system elapsed
# 9.87    0.42   10.36

#
# ##------------------------------------------------------------
# ####https://rpubs.com/ml-fan/139151
# ##------------------------------------------------------------
# ### Generate Sample and Tokenization
# sample_single_big_file <- function(path, N) {
#     ## Sample N lines from the given file.
#     ## As the file may be very big, use reservoir sampling.
#     ## To keep it simple, Algorithm R by Waterman suffices,
#     ## but an even more efficient variant (Algorithm Z by Vitter) exists.
#
#     result <- vector("character", N)
#     idxline <-  0
#     con <- file(path, open = "r")
#     tryCatch({
#         ##TODO: This is a rather slow variant to read by line.
#         while (length(line <- readLines(con, n = 1, warn = F, skipNul = F)) > 0) {
#             idxline <- idxline + 1
#             if (idxline <= N) {
#                 result[idxline] <- line
#             } else {
#                 r <- sample.int(idxline, 1)
#                 if (r <= N) {
#                     result[r] <- line
#                 }
#             }
#         }
#     },
#     finally = {
#         close(con)
#     })
#
#     result
# }
#
#
#
# if (!file.exists(corpus_file)) {
#     set.seed(4218) # for reproducibility
#
#     corpustrain <- Reduce('+', lapply(source_files, function(path) {
#         raw_data <- sample_single_big_file(path, N)
#         lines <- unlist(lapply(raw_data, cleanup_text_line))
#         file_corpus <- quanteda::corpus(lines)
#         src <- stri_split_fixed(basename(path), ".")[[1]][2]
#         docvars(file_corpus, "source") <- src
#         file_corpus
#     }))
#
#     unigrams <- quanteda::dfm(corpustrain, ngrams = 1, groups = "source", verbose = FALSE)
#     bigrams  <- quanteda::dfm(corpustrain, ngrams = 2, groups = "source", verbose = FALSE)
#     trigrams <- quanteda::dfm(corpustrain, ngrams = 3, groups = "source", verbose = FALSE)
#     quadgrams <- quanteda::dfm(corpustrain, ngrams = 4, groups = "source", verbose = FALSE)
#     quintgrams <- quanteda::dfm(corpustrain, ngrams = 5, groups = "source", verbose = FALSE)
#
#     save(corpustrain, unigrams, bigrams, trigrams, quadgrams, quintgrams, file = corpus_file)
# } else {
#     load(corpus_file)
# }
#



