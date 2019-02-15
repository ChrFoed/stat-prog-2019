# Path to country translation data, Should be only adapt if sth at the project structure is changed
path2countries = 'countries/world_countries/data/'

#### NOTE: Do not load libs into your custom package
####################################################

# Function that gets an path and if there is  "os" windows running - regex it and gives it back 
#' @export
getSystemConformPath = function(path) {
  if (.Platform$OS.type == "windows") {
    # Fix returns ... \\ instead of /
    return(gsub("/",'\\\\',path))
  } else {
    return(path)
  }
}

# join isocode from the countries-translation-source to the input dataframe
joinNACountries <- function(targetDf, ldata) {
  # workaround for using the pipe operator
  `%>%` <- magrittr::`%>%`
  # join iso codes to dataframe based on the country column
  joined = targetDf %>% 
    dplyr::left_join( y = dplyr::select(ldata, c(name, alpha2)), by = c('geolabel'  = 'name')) %>%
    dplyr::mutate(isocode = dplyr::case_when(is.na(isocode) == TRUE ~ as.factor(alpha2), is.na(isocode) == FALSE ~ as.factor(isocode)))
  return(dplyr::select(joined, -alpha2))
}
# Export following function to make it public accesible
#' @export
# Description: adds the iso column to the inputdataframe
# Input Parameters: dataframe <df>, dataframe <String>
# Returns list with two dataframes: 'matched' and 'unmatched' rows
isoref <- function(dataframe,column){
  # add the iso column to the dataframe MISSING: check if exits
  dataframe['isocode'] <- NA
  dataframe['isocode'] = as.factor(dataframe['isocode'])
  # read all translated country files, use the systme-path-translator function to make sure that the files are readable
  files <- list.files(getSystemConformPath(path2countries), pattern="countries.csv$", include.dirs = TRUE, recursive=TRUE, full.names=TRUE)
  #iterate over files and join the correct isocodes
  for (currentFile in files) {
    langdata <- read.csv(currentFile, header=TRUE)
    dataframe = joinNACountries(dataframe,langdata)
  }
  return(list("matched" = dplyr::filter(dataframe, !is.na(dataframe$isocode)),"unmatched" = dplyr::filter(dataframe, is.na(dataframe$isocode))))
}