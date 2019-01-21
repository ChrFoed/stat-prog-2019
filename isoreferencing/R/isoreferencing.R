# Should be only adapt if sth at the project structure is changed
path2countries = 'stat-prog-2019/countries/world_countries/data/'

joinNACountries <- function(targetDf, ldata, column) {
  `%>%` <- magrittr::`%>%`
  print(head(targetDf))
  joined = targetDf %>% 
    dplyr::left_join( y = dplyr::select(ldata, c(name, alpha2)), by = c('GEO'='name')) %>%
    dplyr::mutate(isoref = dplyr::case_when(is.na(isoref) == TRUE ~ as.factor(alpha2), is.na(isoref) == FALSE ~ as.factor(isoref)))
  return(dplyr::select(joined, -alpha2))
}
#' @export
isoref <- function(dataframe,column){
  # add the iso column to the dataframe MISSING: check if exits
  dataframe['isoref'] <- NA
  dataframe['isoref'] = as.factor(dataframe['isoref'])
  # read all translated country files
  files <- list.files(path2countries, pattern="countries.csv$", include.dirs = TRUE, recursive=TRUE, full.names=TRUE)
  for (currentFile in files) {
    langdata <- read.csv(currentFile, header=TRUE)
    dataframe = joinNACountries(dataframe,langdata, column)
  }
  return(list("matched" = dplyr::filter(dataframe, !is.na(dataframe$isoref)),"unmatched" = dplyr::filter(dataframe, is.na(dataframe$isoref))))
}
