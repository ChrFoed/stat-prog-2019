# Should be only adapt if sth at the project structure is changed
path2countries = 'project/countries/world_countries/data/en/'

joinNACountries <- function(targetDf, ldata, column) {
  `%>%` <- magrittr::`%>%`
  joined = targetDf %>% 
    dplyr::left_join( y = dplyr::select(ldata, c(name, alpha2)), by = c('GEO'='name')) %>%
    dplyr::mutate(isoref = dplyr::case_when(is.na(isoref) == TRUE ~ as.factor(alpha2), is.na(isoref) == FALSE ~ as.factor(isoref)))
  print(dplyr::filter(joined, GEO == 'Austria'))
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
    # print('result')
    # print(test)
    ## some code
    #write.table(newdata, file=sub(pattern=".txt$", replacement="test.txt", x=currentFile))
  }
  #MyData <- read.csv(file="c:/TheDataIWantToReadIn.csv", header=TRUE, sep=",")
  return('test1')
}
