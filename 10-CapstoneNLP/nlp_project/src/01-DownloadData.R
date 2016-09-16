### Download Zip Data (550MB) & Unzip file
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
