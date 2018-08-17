packages <- c("jsonlite", "RCurl")
dir.create("./libs")
.libPaths(paste0(getwd(), "/libs"))

install.packages(packages)

devtools::install_bitbucket("jvsoest/sparqlr")

tar("libs.tar", "./libs/")