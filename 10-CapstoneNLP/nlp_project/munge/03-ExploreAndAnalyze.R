# http://zevross.com/blog/2014/07/09/making-use-of-external-r-code-in-knitr-and-r-markdown/

    # TASKS / OBJECTIVES
# 1) Exploratory analysis - perform a thorough exploratory analysis of the data, understanding the distribution of words and relationship between the words in the corpora.
# 2) Understand frequencies of words and word pairs - build figures and tables to understand variation in the frequencies of words and word pairs in the data.

# QUESTIONS
# 1) Some words are more frequent than others - what are the distributions of word frequencies?
# 2) What are the frequencies of 2-grams and 3-grams in the dataset?
# 3) How many unique words do you need in a frequency sorted dictionary to cover 50% of all word instances in the language? 90%?
# 4) How do you evaluate how many of the words come from foreign languages?
# 5) Can you think of a way to increase the coverage -- identifying words that may not be in the corpora or using a smaller number of words in the dictionary to cover the same number of phrases?

setwd("~/Analysis/data-science-specialization/10-CapstoneNLP/nlp_project")
source('munge/02-GetAndCLeanData.R')
rm(list=ls(pattern="*.raw"))

##Find top occuring words
lst.corpi.dfm <- c('corpi.dfm.ng1', 'corpi.dfm.ng2', 'corpi.dfm.ng3', 'corpi.dfm.ng4')
lst.blogs.dfm <- c('blogs.dfm.ng1', 'blogs.dfm.ng2', 'blogs.dfm.ng3', 'blogs.dfm.ng4')
lst.news.dfm <- c('news.dfm.ng1', 'news.dfm.ng2', 'news.dfm.ng3', 'news.dfm.ng4')
lst.twitter.dfm <- c('twitter.dfm.ng1', 'twitter.dfm.ng2', 'twitter.dfm.ng3', 'twitter.dfm.ng4')
lst.all.dfm <- c(lst.corpi.dfm,lst.blogs.dfm,lst.news.dfm,lst.twitter.dfm)

#Print a nice table of the top 20 words/ngrams for each dfm
l<-sort(ls(pattern="*twitter.dfm.ng*"))
n<-length(l)
a <- list(0)
for(i in 1:n) {
    a[i] <- list(names(topfeatures(get(l[i]), 20)))
    i<-i+1
}
df <-   data.frame(matrix(unlist(a), nrow=length(unlist(a[1]))),stringsAsFactors=FALSE)
colnames(df) <- l
df


### Plot Bar Chart(s) ------------------------------------------------------------
library(ggplot2)
library(grid)
library(gridExtra)

plotTopFeatures <- function(myDfm, n=20){
    top <- topfeatures(myDfm, n)
    df <- data.frame( key=names(top), value=top )

    ggplot(df, aes(x=reorder(key,value), y=value)) +
        geom_bar(stat='identity') +
        # geom_text(aes(label=value), vjust=0 ,hjust=0) +
        coord_flip() +
        theme_bw() +
        labs(y = "Count", x = "Words")
        ggtitle(paste("Top",n,"for",deparse(substitute(myDfm))))

}
N<-30
pb1<-plotTopFeatures(blogs.dfm.ng1, n=N)
pn1<-plotTopFeatures(news.dfm.ng1, n=N)
pt1<-plotTopFeatures(twitter.dfm.ng1, n=N)
pc1<-plotTopFeatures(corpi.dfm.ng1, n=N)
mp<-grid.arrange(pb1, pn1, pt1, pc1, ncol = 2)
mp
ggsave("./figures/plotTopFeatures.pdf",mp, width = 7.5, height=7.5)

### Plot Word Cloud ------------------------------------------------------------
txt.dfm<-blogs.dfm.ng1
if (require(RColorBrewer))
    plot(txt.dfm, max.words = 40, colors = brewer.pal(6, "Dark2"))

topFeatures()

###------------------------------------------------------------
# 3) How many unique words do you need in a frequency sorted dictionary to cover 50% of all word instances in the language? 90%?
# http://www.statmethods.net/graphs/density.html

#tokens (total features/words) or types (unique features/words)
myDfm <- corpi.dfm.ng1
totalWords<-sum(ntoken(myDfm))
totalFeatures <-sum(ntype(myDfm))
top <- topfeatures(myDfm, n=length(features(myDfm))) # wordCountByFeature
df <- data.frame( keys=names(top), wrdCnt=top )
df$wrdPct <- df$wrdCnt / totalWords
df$cumKey <- 1:dim(df)[1]
df$cumCnt <- cumsum(df$wrdCnt)
df$cumPct <- df$cumCnt / totalWords
head(df)

plot(x=df$cumKey, y=df$cumPct, type="l", xlab="x?", ylab="y?", main="main?" )

ggplot(df, aes(x=cumKey, y=cumPct)) +
    geom_line(colour="black") +
    # geom_vline(xintercept = 123, colour="green", show.legend = TRUE) + #50%
    # geom_vline(xintercept = 7286, colour="blue", show.legend = TRUE) + #90%
    # geom_vline(xintercept = 113636, colour="red", show.legend = TRUE) + #99%
    geom_hline(yintercept = .5, colour="green", show.legend = TRUE) + #50%
    geom_hline(yintercept = .80, colour="blue", show.legend = TRUE) + #80%
    geom_hline(yintercept = .90, colour="red", show.legend = TRUE) + #90%
    theme_bw() +
    labs(y = "Count", x = "Words")
    ggtitle("TITLE")

df[120:130,] #123 words provide 50% coverage
df[1500,] #123 words provide 50% coverage
df[120:130,] #123 words provide 50% coverage


# sumCover <- 0
# for(i in 1:length(onegrams$Freq)) {
#     sumCover <- sumCover + onegrams$Freq[i]
#     if(sumCover >= 0.5*sum(onegrams$Freq)){break}
# }
# print(i)

# ---------------------------------------
    # This next plot compares the coverage of the corpus using different N-Grams.
# ```{r cumPercentCoverageNGrams, echo=F, results='asis'}
#Create Data Frame with data.  tokens (total features/words) or types (unique features/words)
#Function to create a data frame with needed data to plot the feature coverage distribution


featureCoverage <- function(myDfm){
    totalWords<-sum(ntoken(myDfm))
    totalFeatures <-sum(ntype(myDfm))
    top <- topfeatures(myDfm, n=length(features(myDfm))) # Get all features and their wordcounts
    cutoff <- min( totalFeatures, 300000 )
    df <- data.frame( keys=head(names(top),cutoff),
                      wrdCnt=head(top,cutoff),
                      cumKey=1:cutoff,
                      cumPct=head(cumsum(top)/totalWords,cutoff) )
    return(df)
}


#function to lookup in df to find closest value.  if equates to 0 then is an exact match.  closest to 0 will give the best match.
getXfromY <- function(Y){df[ which.min(abs(df$cumPct-Y)),  "cumKey"] }

ggplot(NULL, aes(x=cumKey, y=cumPct)) +  theme_bw() +
    geom_line(data=featureCoverage(corpi.dfm.ng1), colour="green") +
    geom_line(data=featureCoverage(corpi.dfm.ng2), colour="blue") +
    geom_line(data=featureCoverage(corpi.dfm.ng3), colour="red") +
    scale_x_continuous(limits =c(NA,8000)) +  #cut the graph short on the right.
    labs(x = "Total Features", y = "Cumulative % of Corpus Coverage" ) +
    ggtitle("Cumulative % of Corpus Coverage by Total Features")

x<-featureCoverage(corpi.dfm.ng1)
head(x)
topfeatures(corpi.dfm.ng2)
min(length(features(corpi.dfm.ng2)),100000)


    #lookup the Xintercepts in df to create the vlines
    geom_vline( xintercept=getXfromY(.50), linetype="longdash", colour="green", show.legend = TRUE) +
    geom_vline( xintercept=getXfromY(.80), linetype="longdash", colour="blue", show.legend = TRUE) +
    geom_vline( xintercept=getXfromY(.90), linetype="longdash", colour="red", show.legend = TRUE) +
# ```

###------------------------------------------------------------
# 4) How do you evaluate how many of the words come from foreign languages?

###------------------------------------------------------------
# 5) Can you think of a way to increase the coverage -- identifying words that may not be in the corpora or using a smaller number of words in the dictionary to cover the same number of phrases?


###------------------------------------------------------------


#
# # ---
# # testing Twitter functions
# testTweets <- c("My homie @justinbieber #justinbieber shopping in #LA yesterday #beliebers",
#                 "2all the ha8ers including my bro #justinbieber #emabiggestfansjustinbieber",
#                 "Justin Bieber #justinbieber #belieber #fetusjustin #EMABiggestFansJustinBieber")
# dfm(testTweets, keptFeatures = "#*", removeTwitter = FALSE)  # keep only hashtags
# dfm(testTweets, keptFeatures = "^#.*$", valuetype = "regex", removeTwitter = FALSE)
#
# #---
# #PROFANITY FILTER
# http://www.frontgatemedia.com/a-list-of-723-bad-words-to-blacklist-and-how-to-use-facebooks-moderation-tool/
#     http://www.freewebheaders.com/full-list-of-bad-words-banned-by-google/
#     http://www.bannedwordlist.com/
#     https://raw.githubusercontent.com/shutterstock/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/master/en
