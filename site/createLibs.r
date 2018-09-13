packages <- c("jsonlite", "RCurl")

# Set repository to download packages from
options(repos = "http://cran.uni-muenster.de/")

# recursive check of packages needed to be installed
packages_to_install <- unique(c(packages, unlist(tools::package_dependencies(packages, recursive=TRUE))))

# Create library folder, and set path to this folder
dir.create("./libs")
.libPaths(paste0(getwd(), "/libs"))

# Install the actual packages in the new library folder
install.packages(packages_to_install)

# Install the git build
devtools::install_bitbucket("jvsoest/sparqlr")

# create tarball of libraries
libsTarFile = "libs.tar.gz"
if(file.exists(libsTarFile)) {
    file.remove(libsTarFile)
}
tar(libsTarFile, "./libs/", compression="gzip")