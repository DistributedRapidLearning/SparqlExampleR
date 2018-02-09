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

query <- paste(readLines(userInputFileLocation), collapse = " ")
siteInput = list(query=query)

siteIds <- unlist(strsplit(siteIds, ","))
for(siteId in siteIds) {
    fileConn<-file(file.path(outputLocation, paste0("Input_", siteId, ".txt", sep=""), fsep="\\"))
    writeLines(toJSON(siteInput), fileConn)
    close(fileConn)
}

if(iteration > 1) {
    resultPath <- file.path(outputLocation, "result.txt", fsep="\\")
    #read JSON files from sites
    siteOutput <- lapply(siteIds, function(siteId) {
        filePath <- file.path(siteUpdateFolder, paste0("DistOutput_", siteId, ".txt", sep=""), fsep="\\")
        singleString <- paste(readLines(filePath), collapse="")
        objects <- fromJSON(singleString)
        write(paste0("------------------ Site ", siteId, " ------------------", sep=""), file=resultPath, append=TRUE)
        write(paste0("patients: ", objects$patients, sep=""), file=resultPath, append=TRUE)
        write(paste0("rows: ", objects$rows, sep=""), file=resultPath, append=TRUE)
        write("===== Numeric:", file=resultPath, append=TRUE)
        write.table(objects$numeric, file=resultPath, append=TRUE)
        write("===== Categoric:", file=resultPath, append=TRUE)
        write.table(objects$categories, file=resultPath, append=TRUE, row.names=FALSE)
        write(paste0("-------------------------------------------------------", sep=""), file=resultPath, append=TRUE)
        objects
    })

    #fileConn<-file(file.path(outputLocation, "result.txt"))
    #writeLines(c("test"), fileConn)
    #close(fileConn)
}
    