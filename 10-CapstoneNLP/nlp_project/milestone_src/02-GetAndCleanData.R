
setwd("~/Analysis/data-science-specialization/10-CapstoneNLP/nlp_project")
source('munge/utils.R')
library(stringi)
library(plyr)
library(quanteda)



### INITIALIZE
N <- -1
PCT <- .1
blnSTEM <- FALSE
argSTOP <- NULL #stopwords('SMART'))
source_files <- c("./data/final/en_US/en_US.blogs.txt",
                  "./data/final/en_US/en_US.news.txt",
                  "./data/final/en_US/en_US.twitter.txt")
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
