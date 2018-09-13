args <- commandArgs(trailingOnly = TRUE)

untar("libs.tar.gz", compressed="gzip")
.libPaths(paste0(getwd(), "/libs"))

#--------------------------------------------------------------------------------------------------
# libraries
suppressMessages(library(sparqlr))
suppressMessages(library(jsonlite))
source("varDescription.r")
#--------------------------------------------------------------------------------------------------
# arguments
# RunId : ID of algorithm "job" in infrastructure
runId<-args[1];
# IterationNo : iteration number
iteration<-args[2];
# InputParameterFile: Path to the input file that was sent from the master to this site. The format of this file is specific to the program.
#  This file was created by the master algorithm
InputParameterFile<-args[3]
# Outputparameterfile: location where the varian system expects a file (textfile) containing the results if this iteration
Outputparameterfile<-args[4]
# TempFolder : folder to put in anything you want to survive iterations (e.g. queried dataset)
tempFolder<-args[5]
# LogFile
LogFile<-args[6]

dataProxyUrl<-args[7]
proxyToken<-args[8]

#query <- "SELECT * WHERE { ?s ?p ?o. } LIMIT 100"
siteInputParams <- fromJSON(paste(readLines(InputParameterFile), collapse=""))
query <- siteInputParams$query


dataSet <- performSparqlQuery.vlp(dataProxyUrl, query, key="VATE", token=proxyToken, verbose=TRUE)
varDescription <- describeVars(dataSet)

write(toJSON(varDescription), Outputparameterfile)