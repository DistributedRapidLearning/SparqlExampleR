args <- commandArgs(trailingOnly = TRUE) # salva gli input della funzione in base a come vengono inserite da riga di comando
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

siteIds <- unlist(strsplit(siteIds, ","))
for(siteId in siteIds) {
    fileConn<-file(file.path(outputLocation, paste0("Input_", siteId, ".txt", sep=""), fsep="\\"))
    writeLines(c("test"), fileConn)
    close(fileConn)
}

if(iteration > 1) {
    fileConn<-file(file.path(outputLocation, "result.txt"))
    writeLines(c("test"), fileConn)
    close(fileConn)
}
    