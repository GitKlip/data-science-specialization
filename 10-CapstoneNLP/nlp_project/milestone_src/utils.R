###
# set default numeric print to show 1 decimal place.
print <- function(x, ...) {
    if (is.numeric(x)) base::print(round(x, digits=2), ...)
    else base::print(x, ...)
}

###-----------------------------------------------
### Read Data via readLines()
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


###-----------------------------------------------
whatsit <- function(o){
    print(paste('class:',class(o)))
    print(paste('typeof:',typeof(o)))
    print(paste('str:',str(o)))
}

