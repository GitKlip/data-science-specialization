###
# set default numeric print to show 1 decimal place.
print <- function(x, ...) {
    if (is.numeric(x)) base::print(round(x, digits=2), ...)
    else base::print(x, ...)
}

###-----------------------------------------------
### Download Zip Data (550MB)
downloadAndExtract <- function(){
    if(!dir.exists("./data")) dir.create("./data")
    fileUrl <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
    zipFileName <- "./data/Coursera-SwiftKey.zip"
    if(!file.exists(zipFileName)){
        print(paste("downloading Zip File",fileUrl,"to",zipFileName,"..."))
        download.file(url = fileUrl, destfile = zipFileName, mode="wb")
        print("UnZipping File...")
        unzip(zipfile = zipFileName, exdir="./data")
        print("complete")
    }
}
downloadAndExtract()


###-----------------------------------------------
### Read Data via readLines()
#TODO - need to implement random sampling of data http://rpackages.ianhowson.com/cran/quanteda/man/sample.html
#TODO - need to implement pct of file size instead of num of records
readDataFile <- function(fileName, nLines = -1){
    con <- file(fileName, "r")
    tryCatch({
        l <- readLines(con, skipNul = TRUE, n = nLines, encoding = 'UTF-8')  ## Read the file in
    },
    finally = {
        close(con)  ##It's important to close the connection when you are done
    })
    print(paste('Read',length(l),'lines.'))
    return(l)
}
# x <- readDataLines('data/final/en_US/en_US.twitter.txt', nLines=50)

readDataFile2 <- function(fileName, nLines = -1, samplePct=1, verbose=F){
    set.seed(12345) # for reproducibility
    if(file.exists(fileName)){
        if(VERBOSE) print(paste("Reading & Loading:",basename(fileName),"nLines=",nLines,"samplePct=",samplePct))
        con <- file(fileName, "r")
        tryCatch({
            txt <- readLines(con, skipNul = TRUE, n = nLines, encoding = 'UTF-8')  ## Read the file in
        },
        finally = {
            close(con)  ##It's important to close the connection when you are done
        })
        print(paste('Read',length(txt),'lines.'))

        if(samplePct>0 & samplePct<1){  #Sample if desired
            if(VERBOSE) print(paste0("sampling data. samplePct=",samplePct))
            txt <- sample(txt, size = length(txt)*SAMPLE_PCT,  replace = FALSE)
        }

        return(txt)

    }
    else {
        stop(paste("FILE NOT FOUND:",f))
    }
}
###-----------------------------------------------
### Random Sample of Data (pct should be between 0 and 1)
getSampleData <- function(corpus, pct) {
    set.seed(12)
    return(df[sample(1:nrow(df))[1:round(nrow(df)*pct)],]) #sample random 10%
}
# x <- getSampleData(blogs, pct=.1)


###-----------------------------------------------
whatsit <- function(o){
    print(paste('class:',class(o)))
    print(paste('typeof:',typeof(o)))
    print(paste('str:',str(o)))
}

# whatsit(dfCorpus)
# str(dfCorpus)
# typeof(dfCorpus)
# class(dfCorpus)


###-----------------------------------------------
# http://stackoverflow.com/questions/1358003/tricks-to-manage-the-available-memory-in-an-r-session
# improved list of objects
.ls.objects <- function (pos = 1, pattern, order.by,
                         decreasing=FALSE, head=FALSE, n=5) {
    napply <- function(names, fn) sapply(names, function(x)
        fn(get(x, pos = pos)))
    names <- ls(pos = pos, pattern = pattern)
    obj.class <- napply(names, function(x) as.character(class(x))[1])
    obj.mode <- napply(names, mode)
    obj.type <- ifelse(is.na(obj.class), obj.mode, obj.class)
    obj.prettysize <- napply(names, function(x) {
        capture.output(format(utils::object.size(x), units = "auto")) })
    obj.size <- napply(names, object.size)
    obj.dim <- t(napply(names, function(x)
        as.numeric(dim(x))[1:2]))
    vec <- is.na(obj.dim)[, 1] & (obj.type != "function")
    obj.dim[vec, 1] <- napply(names, length)[vec]
    out <- data.frame(obj.type, obj.size, obj.prettysize, obj.dim)
    names(out) <- c("Type", "Size", "PrettySize", "Rows", "Columns")
    if (!missing(order.by))
        out <- out[order(out[[order.by]], decreasing=decreasing), ]
    if (head)
        out <- head(out, n)
    out
}

# shorthand
lsos <- function(..., n=10) {
    .ls.objects(..., order.by="Size", decreasing=TRUE, head=TRUE, n=n)
}

# lsos()


###-----------------------------------------------
# load('./cache/-1rows_30pct_raw.RData')
# load('./cache/-1rows_30pct_nobadTRUE_DT.RData')
# Create Train And Test

getTestData <- function(txt, SAMPLE_PCT, NTEST){
    set.seed(12345)
    train_ind <- sample(x=seq_len(length(txt)), size = length(txt)*SAMPLE_PCT,  replace = FALSE)
    return(as.vector(tail(txt[-train_ind], NTEST)))
}

validatePredicitonResults <- function(nWordsIn=150, nWordsOut=5){
    TST.RAW <- c(
        getTestData(blogs.raw, .3, nWordsIn),
        getTestData(news.raw, .3, nWordsIn),
        getTestData(twitter.raw, .3, nWordsIn)
    )

    #STRIP IT DOWN
    TEST <- str_trim(str_to_lower(TST.RAW), "both")
    TEST <- stri_replace_all_regex(TEST, "(\\b)[\\p{Pd}](\\b)", "$1_hy_$2") # to preserve intra-word hyphens, replace with _hy_
    TEST <- gsub('[[:punct:]]', '', TEST)
    TEST <- stri_replace_all_fixed(TEST, "_hy_", "-") # put hyphens back the fast way

    #BUILD VALIDATION TABLE
    DTV <- data.table(
        text = trimws(TEST),
        wc = str_count(TEST, pattern =regex("\\S+", ignore_case = T)))

    DTV[, predictor := word(text, start={if(wc>3) -4 else 1}, end=-2)]
    DTV<-DTV[!predictor %in% c(NA,"")]  #FILTER IF NO PREDICTOR EXTRACTED
    DTV[, answer := word(text, -1) ]
    PREDS<-sapply(DTV$predictor, FUN=function(x){paste(predictNextWord(x, predictN=nWordsOut, verbose=F), collapse="|")})
    DTV[, prediction := PREDS ]
    DTV[, correct := mapply(FUN=grepl, pattern=DTV$answer, x=DTV$prediction) ]

    # DTV[, P := grepl(answer,prediction), by=answer]
    # DTV[correct==F,.(answer,prediction,correct)]
    # print(DTV[correct==F,.(answer,prediction,correct)], topn=40)

    print(summary(DTV$correct))
}


