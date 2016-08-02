# R Programming - Week 2 Programming Assignment
## Caching the Inverse of a Matrix ##
#
# The following functions will be used to calculate the inverse of a matrix and be able to cache it for later use:
#  - makeCacheMatrix() is used to store/cache a matrix and also the inverse of that matrix.
#  - cacheSolve() is used to actually calculate the inverse of the matrix or retrieve it if the inverse has already been cached.
#
#Helpful Links
# - http://www.mathsisfun.com/algebra/matrix-inverse.html
# - https://class.coursera.org/rprog-004/forum/thread?thread_id=153

# makeCacheMatrix(): Creates a special "vector" object with a list of functions that can cache a matrix and cache the matrix inverse.
makeCacheMatrix <- function(x = matrix()) {
    cache_i <- NULL  ## Initialize cache_i to NULL so cacheSolve() can check if it's been solved already or not.          
    
    # set/cache the matrix passed into the function
    set_m <- function(y) {
      cache_m <<- y     ## Cache the original matrix
      cache_i <<- NULL  ## Initialize cache_i to NULL so we can tell when cacheSolve has run at least once.          
    }
    
    #get/return the original matrix
    get_m <- function() { x }
    
    #set the value of the inverse matrix
    set_i <- function(inverse) { cache_i <<- inverse }
    
    #get/return tthe inverse matrix
    get_i <- function() { cache_i }
    
    list(set_m = set_m, 
         get_m = get_m,
         set_i = set_i,
         get_i = get_i)
}

# cacheSolve: Computes the inverse of the original matrix that's stored in makeCacheMatrix() above. 
#               If the inverse has already been calculated (and the matrix has not changed), then cacheSolve() 
#               will retrieve the inverse from the cache.
cacheSolve <- function(x, ...) {  # Receive makeCacheMatrix
  
    #look for previously cached inverse matrix and return it if it exists
    if (!is.null(x$get_i())) {
        message("returning cached inverse matrix")  
        return(x$get_i())
    }
    # inverse matrix dosn't exist so we need to calulate it, cache it, and return it.
    else {
        message("calculating and caching inverse matrix")
        inverse <- solve(x$get_m())
        x$set_i(inverse)
        return(inverse)
    }
    
}
##TESTING
##Create a populated matrix for testing
# > m0 <- matrix(0, 3, 3)
# > m0 <- apply(m0, c(1,2), function(x) sample(1:10,1)) 
# > mcm <- makeCacheMatrix(m0)
# > cacheSolve(mcm)
# calculating and caching inverse matrix
# [,1]        [,2]       [,3]
# [1,]  0.5 -0.18571429 -0.2857143
# [2,] -1.0  0.62857143  0.4285714
# [3,]  0.0 -0.05714286  0.1428571
# > cacheSolve(mcm)
# returning cached inverse matrix
# [,1]        [,2]       [,3]
# [1,]  0.5 -0.18571429 -0.2857143
# [2,] -1.0  0.62857143  0.4285714
# [3,]  0.0 -0.05714286  0.1428571

