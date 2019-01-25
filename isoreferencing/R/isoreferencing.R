# Should be only adapt if sth at the project structure is changed
path2countries = 'stat-prog-2019/countries/world_countries/data/'

joinNACountries <- function(targetDf, ldata, column) {
  `%>%` <- magrittr::`%>%`
  joined = targetDf %>% 
    dplyr::left_join( y = dplyr::select(ldata, c(name, alpha2)), by = c(column='name')) %>%
    dplyr::mutate(isoref = dplyr::case_when(is.na(isocode) == TRUE ~ as.factor(alpha2), is.na(isocode) == FALSE ~ as.factor(isocode)))
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
    dataframe = joinNACountries(dataframe,langdata, column)
  }
  return(list("matched" = dplyr::filter(dataframe, !is.na(dataframe$isocode)),"unmatched" = dplyr::filter(dataframe, is.na(dataframe$isocode))))
}
