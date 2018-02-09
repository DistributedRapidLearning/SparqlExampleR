#################################################################################################
# Variable description
#################################################################################################
tableDescription <- function(dataVector) {
  result <- table(dataVector, useNA="always")
  
  resultPercentage <- (table(dataVector, useNA = "always")/sum(table(dataVector, useNA = "always")))*100
  
  rbind(result, resultPercentage)
}

loadTypeDependentResults <- function(dataVector) {
  if(sum(class(dataVector) %in% c("factor", "logical", "character"))>0) {
    return(tableDescription(dataVector))
  }
  
  if(class(dataVector) %in% c("numeric", "integer")) {
    return(data.frame(mean=mean(dataVector, na.rm=TRUE), 
                      sd=sd(dataVector, na.rm=TRUE),
                      min=min(dataVector, na.rm=TRUE),
                      median=median(dataVector, na.rm=TRUE),
                      max=max(dataVector, na.rm=TRUE),
                      amountNA=sum(is.na(dataVector))))
  }
}

castVars <- function(dataFrame, castTypes) {
  columnsToCast <- which(!is.na(castTypes))
  for (i in columnsToCast) {
    if(castTypes[i]=="factor")
      dataFrame[,i] <- as.factor(dataFrame[,i])
    if(castTypes[i]=="logical")
      dataFrame[,i] <- dataFrame[,i]==1
  }
  
  dataFrame
}

analyzeDataFrame <- function(dataFrame, castTypes=c(NA)) {
  
  dataFrame <- castVars(dataFrame, castTypes)
  
  lapply(dataFrame, loadTypeDependentResults)
}

describeVars <- function(dataSet) {
    varNames <- colnames(dataSet)
    varNames <- varNames[!(varNames %in% "patient")]
    patients <- dataSet$patient
    setSize <- nrow(dataSet)

    #only use unique patients, if there are multiple rows for one patient, only use the 1st row.
    indices <- sapply(unique(patients), function(x) { which(patients==x)[1] })

    dataSet <- dataSet[indices,varNames]

    variableDescription <- analyzeDataFrame(dataSet)

    #made subset of varnames for categorical and numerical vars
    numericVars <- names(which(sapply(dataSet, class)=="numeric"))
    categoricalVars <- names(which(sapply(dataSet, class)!="numeric"))

    #bind all list items in one table for numerical variables
    varDescription.numerical <- do.call(rbind, variableDescription[numericVars])
    #calculate percentage NA from absolute NA numbers
    varDescription.numerical$percentageNA <- (varDescription.numerical$amountNA/nrow(dataSet))*100

    #function to enrich variable description for categorical/binary values, and to translate/rotate data.frame, creating one large data.frame
    # containing all variables and distributions
    convertVarDescription <- function(x) {
        varDesc <- variableDescription[[x]]
        colnames(varDesc)[is.na(colnames(varDesc))] <- "MISSING"
        thisTable <- as.data.frame(t(varDesc))
        
        thisTable$categories <- rownames(thisTable)
        thisTable$variable <- x
        
        thisTable
    }

    #run function described above
    variableDescription <- sapply(colnames(dataSet), convertVarDescription)
    #make one large data.frame for categorical variables
    varDescription.categories <- do.call(rbind, variableDescription[categoricalVars])
    #remove row names
    rownames(varDescription.categories) <- NULL

    list(patients=length(unique(patients)), rows=setSize, numeric=varDescription.numerical, categories=varDescription.categories)
}