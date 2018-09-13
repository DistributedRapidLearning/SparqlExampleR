args <- commandArgs(trailingOnly = TRUE) # salva gli input della funzione in base a come vengono inserite da riga di comando

installAndLoad <- function(packageName) {
    if(!(packageName %in% rownames(installed.packages()))) {
        install.packages(c(packageName), repos = "https://cran.uni-muenster.de/")
    }
    library(packageName, character.only = TRUE)
}

installAndLoad("jsonlite")

#--------------------------------------------------------------------------------------------------
# libraries
#--------------------------------------------------------------------------------------------------
# arguments j
# RunId: ID of algorithm "job" in infrastructure
runId <- args[1];
# IterationNo: iteration number
iteration <- args[2];
# FolderWhereSiteUpdatesAreStored: folder location where all site updates are located
siteUpdateFolder <- args[3]
# MasterOutputFolder: Output folder location for the algorithm
outputLocation <- args[4]
# TempFolder: folder to put in anything you want to survive iterations (e.g. queried dataset)
tempFolder <- args[5]
# Abort: if 1, application should abort (no further iteration)
abort <- args[6]
# SiteIds : comma-separated list (character string) of site ids involved
siteIds <- args[7]
# UserInputFile : Path to the file that the user provided upon execution
userInputFileLocation <- args[8]
# LogFile: If you want to add things to the log, add them to this file path
LogFile <- args[9]

# Read SPARQL query from User Input File
query <- paste(readLines(userInputFileLocation), collapse = " ")
# Make a list object (dictionary) with one variable "query"
siteInput = list(query=query)

# For all site IDs included in this run, create an input file
siteIds <- unlist(strsplit(siteIds, ","))
for(siteId in siteIds) {
    # template for the filename is in the outputLocation (given as input argument), and a filename like "Input_<siteID>.txt"
    fileConn<-file(file.path(outputLocation, paste0("Input_", siteId, ".txt", sep=""), fsep="\\"))
    # Write the dictionary (siteInput) into the input file for the specific site
    writeLines(c(toJSON(siteInput), ""), fileConn)
    close(fileConn)
}

# If iteration is > 0, then all sites have processed iteration 0. This means we can read the results from all sites, and put it in the result.txt file.
if(iteration > 1) {
    source("resultsProcessor.r")

    results <<- initResults()
    
    for(siteId in siteIds) {
        # read from site output
        filePath <- file.path(siteUpdateFolder, paste0("DistOutput_", siteId, ".txt", sep=""), fsep="\\")
        singleString <- paste(readLines(filePath), collapse="")
        objects <- fromJSON(singleString)

        # create example figure
        myVector <- rnorm(n=1000, mean=(63+as.numeric(siteId)), sd=10)
        figureFileName = paste0("hist_", siteId, ".png")
        dir.create(paste(outputLocation,"/Images",sep=""), showWarnings = FALSE)
        png(filename = file.path(outputLocation, "Images", figureFileName, fsep="\\"))
        hist(myVector)
        dev.off()

        # Compile results file
        results <<- addText(results, paste0("patients: ", objects$patients, "\r\nrows: ", objects$rows), title=paste0("Site ", siteId))
        results <<- addTable(results, objects$numeric, caption="Numeric variables")
        results <<- addTable(results, objects$categories, caption="Categorical variables")
        results <<- addFigure(results, figureFileName, title="My Figure Title", caption="Histogram showing something")
    }

    # Write results file
    writeToFile(results, file.path(outputLocation, "result.txt", fsep="\\"))
}
    
