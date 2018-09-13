library(jsonlite)

initResults <- function() {
    list(dashboardResults=c())
}

writeToFile <- function(resObj, filePath) {
    # Write results file
    fileConn<-file(filePath)
    writeLines(createJSON(resObj), fileConn)
    close(fileConn)
}

addResult <- function(resObj, typeObj, type="text", title="New Object", caption="") {
    myObj <- list(
        type=type,
        title=title,
        caption_south=caption,
        type_vars=typeObj
    )
    resObj$dashboardResults[[length(resObj$dashboardResults)+1]] <- myObj
    resObj
}

createJSON <- function(resObj) {
    toJSON(resObj, auto_unbox=T)
}

addTable <- function(resObj, myDataFrame, title="New Table", caption="") {
    addResult(resObj, myDataFrame, type="table", title=title, caption=caption)
}

addFigure <- function(resObj, figureName, title="New Figure", caption="") {
    addResult(resObj, list(filename=figureName), type="figure", title=title, caption=caption)
}

addText <- function(resObj, text, textType="plain", title="New Figure", caption="") {
    addResult(resObj, list(type=textType, value=text), type="text", title=title, caption=caption)
}

createCoxObj <- function(covariateDataFrame, baselineTime, baselineHazard, timeUnit) {
    if(class(covariateDataFrame)!="data.frame") {
        throw("Error in createCoxObj in resultsProcessor.r: covariateDataFrame is not of class data.frame")
    }

    if(sum(c("name", "weight") %in% colnames(covariateDataFrame))!=2) {
        throw("Error in createCoxObj in resultsProcessor.r: covariateDataFrame missing column 'name' or 'weight'")
    }

    list(model_type="CoxPH", parameters=list(
        covariates=covariateDataFrame,
        baseline_time=baselineTime,
        baseline_hazard=baselineHazard,
        time_unit=timeUnit
        )
    )
}

addPredictionModel <- function(resObj, modelObj, title="New Model", caption="") {
    if(!(modelObj$model_type %in% c("CoxPH"))) {
        throw("Error in addPredictionModel in resultsProcessor.r: model type unknown")
    }
    addResult(resObj, modelObj, "predictionModel", title=title, caption=caption)
}