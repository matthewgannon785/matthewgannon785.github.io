# STAT 40780 Assignment 1 Question 1

# is.Orth.cpp is fairly straight forward using a dot product calculation "sum" and checking it using an equality parameter like those shown in lab 4 to check if sum is equal to zero. Firstly we change our working directory to location where the compiled file is stored.

setwd("C:/Users/Jellyflabman/Documents/R CPP Files")

# load the compiled function

dyn.load( "isOrth.dll" ) 

# Set two orthaganal integer vectors x and y in R to call using our compiled function. 

x <- c(-2L,1L,1L)
y <- c(1L,1L,1L)

# Use the length of x as the length described in our function. 
len <- length(x)

.C("isOrth", x, y, len, sum = as.numeric(0), 
   result = TRUE)

# As we can see here our output tells us that the following vectors are orthoganal.  

x <- c(-3L,1L,1L)
y <- c(1L,1L,1L)

len <- length(x)

.C("isOrth", x, y, len, sum = as.numeric(0), 
   result = TRUE)

# Here we can see our output is telling us that these vectors are not orthoganal

## Question B

# This can be found on the pdf file provided. 

## Question C 

# Now lets create a wrapper function to 

OrthWrap <- function(x,y){
  # check that our inputs are of type integer
  if(! is.integer( x )) stop("Input values must be integer")
  if(! is.integer( y )) stop("Input values must be integer")
  
  # check that both vectors are of the same length
  if(! length(x)==length(y)) stop("Vectors must be the same length")
  
  # Use .C interface function to evaluate our vectors
  .C("isOrth", x, y, len, sum = as.numeric(0), 
     result = TRUE)
}

x <- c(18L,0L,-3L)
y <- c(3L,12L,18L)
OrthWrap(x,y)
# These vectors are orthogonal. 

x <- c(1L,3L,-5L)
y <- c(2L,2L,2L)
OrthWrap(x,y)
# These vectors are not orthogonal.

x <- c(3L,1.5L,3L)
y <- c(-1L,6L,-2L)
OrthWrap(x,y)
# These vectors were rejected by our wrapper function as vector x is not an integer.

x <- c(4L,3L,6L)
y <- c(2L,-4L,5L,1L )
OrthWrap(x,y)
# These vectors were rejected as they are not the same length. 

# When finished with our compiled function, we can unload it using the following code.

dyn.unload( "isOrth.dll" )

## Question 2 a

# Unfortunately, I was unable to create the adequete source code for question 2.

# My first attempt was to divide vector x by the absolute value of x as outlined in SignC.cpp. Then following the following procedure: 

# Firstly we change our working directory to location where the compiled file is stored
setwd("C:/Users/Jellyflabman/Documents/R CPP Files")

# load the compiled function
dyn.load( "SignC.dll" ) 

# Set x to be a numeric vector.
x <- c(1,-2,1)
# Set y to be the absolute value of x. 
y<- abs(x)

# Check if x is numeric
is.numeric(x)

# Use the length of x as the length described in our function.
len <- length(x)

# Use the following .C function to call our required vector z. 
.C("signC", x, y, len, z=as.numeric(0))

# Im aware that R returns 0/abs(0) as Nan. In this case the following code would be used:
is.na(z) <- 0

# My second attempt is outlined in SignCA2.cpp. The idea was to use the while function to set positive and negative values of input x to correspond to values of a z output +1 and -1 respectively, leaving zero as it's default. Calling this into R would use largely the same code as in the first attempt except for:

dyn.load( "SignCA2.dll" ) 

.C("signC", x, len, z = as.numeric(0))

# In this case, a fatal error occurs in R. I was unable to find a cause of this error. 

## Question B

# Now lets create a wrapper function to the second attempt as it had only a single input argument. 

SignWrap <- function(x){
  # check that input is of type integer.
  if(! is.numeric( x )) stop("Input values must be numeric")
  # check that both vectors are of the same length
  if(! length(x)>=1) stop("X must be a numeric vector with a length greater or equal to 1")
  
  # .C interface to inspect the elements of our input.
  .C("signC", x, len, z=as.numeric(0))
}

# Testing the implementation of a numeric vector would only involve this code.
x<-c(8,-2.2,0,5,3.3)
SignWrap(x)




