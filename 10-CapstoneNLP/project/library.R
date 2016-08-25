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

### Read Data via readLines()
readDataLines <- function(fileName, nLines = -1){
    con <- file(fileName, "r")
    l <- readLines(con, skipNul = TRUE, n = nLines, encoding = 'UTF-8')  ## Read the file in
    close(con)  ##It's important to close the connection when you are done
    print(paste('Read',length(l),'lines.'))
    return(l)
}
# x <- readDataLines('data/final/en_US/en_US.twitter.txt', nLines=50)



### Random Sample of Data (pct should be between 0 and 1)
getSampleData <- function(df, pct) {
    set.seed(12)
    return(df[sample(1:nrow(df))[1:round(nrow(df)*pct)],]) #sample random 10%
}
# x <- getSampleData(blogs, pct=.1)
