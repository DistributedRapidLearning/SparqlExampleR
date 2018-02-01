args <- commandArgs(trailingOnly = TRUE)

if(!("devtools" %in% rownames(installed.packages()))) {
    install.packages(c("devtools"), repos = "https://cran.uni-muenster.de/")
}
if(!("devtools" %in% rownames(installed.packages()))) {
    devtools::install_bitbucket("jvsoest/sparqlr", force = TRUE)
}

#--------------------------------------------------------------------------------------------------
# libraries
suppressMessages(library(sparqlr))
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
query <- paste(readLines("query.sparql"), collapse = " ")


dataSet <- performSparqlQuery.vlp(dataProxyUrl, query, key="VATE", token=proxyToken, verbose=TRUE)
write.csv(x=dataSet, file=Outputparameterfile)