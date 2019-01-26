# Should be only adapt if sth at the project structure is changed
path2countries = 'countries/world_countries/data/'

joinNACountries <- function(targetDf, ldata) {
  `%>%` <- magrittr::`%>%`
  joined = targetDf %>% 
    dplyr::left_join( y = dplyr::select(ldata, c(name, alpha2)), by = c('geolabel'  = 'name')) %>%
    dplyr::mutate(isocode = dplyr::case_when(is.na(isocode) == TRUE ~ as.factor(alpha2), is.na(isocode) == FALSE ~ as.factor(isocode)))
  return(dplyr::select(joined, -alpha2))
}
#' @export
isoref <- function(dataframe,column){
  # add the iso column to the dataframe MISSING: check if exits
  dataframe['isocode'] <- NA
  dataframe['isocode'] = as.factor(dataframe['isocode'])
  # read all translated country files
  files <- list.files(path2countries, pattern="countries.csv$", include.dirs = TRUE, recursive=TRUE, full.names=TRUE)
  for (currentFile in files) {
    langdata <- read.csv(currentFile, header=TRUE)
    dataframe = joinNACountries(dataframe,langdata)
  }
  return(list("matched" = dplyr::filter(dataframe, !is.na(dataframe$isocode)),"unmatched" = dplyr::filter(dataframe, is.na(dataframe$isocode))))
}
# Function that gets an path and if there is some "os" windows running change it and gives it back 
#' @export
getSystemConformPath = function(path) {
  if (.Platform$OS.type == "windows") {
    # Fix returns ... \\ instead of /
    return(gsub("/",'\\\\',path))
  } else {
    return(path)
  }
}
