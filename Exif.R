# Set Working Directory
setwd("C:/Users/rbrown/OneDrive - supplyFORCE/Documents/RProjects")

# Clear Work Space
rm(list = ls())


# ExifTool
# exiftool -r -d "%Y-%m-%d %H:%M:%S" "P:\_Game Cameras" >GameCameras.txt
# -d flag will format the datetime as needed for this work.


# Processing EXIF Data
# https://www.r-bloggers.com/processing-exif-data/

exifData <- readLines("GameCameras_20160913.txt")
exifData <- paste(exifData, collapse = "|")
exifData <- strsplit(exifData, "======== ")[[1]]
exifData <- strsplit(exifData, "|", fixed = TRUE)
exifData <- exifData[sapply(exifData, length) > 0]

extract <- function(d) {
  d <- d[-1]                  # Remove file name (redundant since it is also in first named record)
  d <- strsplit(d, ": ")      
  as.list(setNames(sapply(d, function(n) {n[2]}), sapply(d, function(n) {n[1]})))
}
exifData <- lapply(exifData, extract)

library(plyr)
exifData <- ldply(exifData, function(d) {as.data.frame(d)}) # this will take a little while.

# Remove trailing periods and whitespace.
trimdot <- function(x) {
 x <- gsub("\\.(?=\\.*$)", " ", x, perl=TRUE)
 x <- trimws(x, which = "right")
}
colnames(exifData) <- lapply(colnames(exifData), trimdot)

# Focal Length field needs to be fixed.
colnames(exifData)[94] <- "Focal.Length"


# Remove these columns:
# colnames(exifData)[138] "X..777.directories.scanned"   
# colnames(exifData)[139] "X40436.image.files.read"
exifData <- exifData[-c(138:139)]

# Convert Date.Time fields from character to POSIXlt.
exifData$File.Creation.Date.Time <- strptime(exifData$File.Creation.Date.Time, format = "%Y-%m-%d %H:%M:%S")
exifData$File.Modification.Date.Time <- strptime(exifData$File.Modification.Date.Time, format = "%Y-%m-%d %H:%M:%S")
exifData$File.Access.Date.Time <- strptime(exifData$File.Access.Date.Time, format = "%Y-%m-%d %H:%M:%S")
exifData$Modify.Date <- strptime(exifData$Modify.Date, format = "%Y-%m-%d %H:%M:%S")
exifData$Date.Time.Original <- strptime(exifData$Date.Time.Original, format = "%Y-%m-%d %H:%M:%S")
exifData$Create.Date <- strptime(exifData$Create.Date, format = "%Y-%m-%d %H:%M:%S")
exifData$Profile.Date.Time <- strptime(exifData$Profile.Date.Time, format = "%Y-%m-%d %H:%M:%S")

# How many pictures were taken in 2016?
nrow(subset(exifData, format(Create.Date, "%Y")== "2016"))


#   http://stackoverflow.com/questions/12222689/replace-trailing-periods-with-spaces
#   gsub("\\.(?=\\.*$)", " ", fields[1], perl=TRUE)
#   \.    # Match a dot
#   (?=   # only if followed by
#   \.*   # zero or more dots
#   $     # until the end of the string
#   )     # End of lookahead assertion.


strptime("2015-09-06 10:24:21", format = "%Y-%m-%d %H:%M:%S")
# [1] "2015-09-06 10:24:21 EDT"
strptime("2015-09-06 10:24:21", format = "%Y-%m-%d %H:%M:%S") - strptime("2015-09-06 08:24:21", format = "%Y-%m-%d %H:%M:%S")
# Time difference of 2 hours