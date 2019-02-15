# Set Working directory
setwd('stat-prog-2019')
# Devtools to build and install custom helper package
devtools::build('isoreferencing')
devtools::install('isoreferencing')

# load custom package
library(isoreferencing)
# load needed additional packages
library(magrittr)
library(dplyr)
library(purrr)
# Create directories if the don't exist for exporting data
if(!dir.exists(file.path('.', 'data')))
  dir.create(file.path('.','data'), showWarnings = TRUE)

# Manual for source-config: 
# "filepath" = --> path to the rawfile - make sure to use the "correct path to os" function from custom isoreferencing package  
# "exportOptions" = list('folder' = <targetfiolder>, 'name' = <filename>),
# "geocolumn" = --> name of the geocolumn,  
# "options" = list("header" = <boolean>) --> here you can define import options,
# "select" = c("column1","column2","column5"), --> which column you want in the processed file
# "filter" = list("cols" =list("WSTATUS"), "conds" = list("Unemployed persons")) # add multiple arguments support -_> should be a gnereic filter....but     supports currently only one filter. Should make the filter process configurable...

# Fileenvironemnets

# gho -> File contains Data about drinking behaviour on countrylevel
GHOconfig <- list(
  "filepath" = getSystemConformPath('rawdata/gho/gho_csv.csv'), 
  "exportOptions" = list('folder' = 'clean_gho_data', 'name' = 'gho_drink_data'),
  "geocolumn" = "GEO",   
  "options" = list("header" = TRUE),
  "select" = c("TIME","Beer","Wine","Spirits","Other","isocode")
)
# eurostat -> File contains data about un/employment in Europe
EUROconfig <- list(
  "filepath" = getSystemConformPath('rawdata/eurostat/lfsa_pganws_1_Data.csv'), 
  "exportOptions" = list('folder' = 'clean_euro_data', 'name' = 'unemployed_persons_data'),
  "geocolumn" = "GEO",  
  "options" = list("header" = TRUE),
  "select" = c("TIME","WSTATUS","Value","isocode"),
  "filter" = list("cols" =list("WSTATUS"), "conds" = list("Unemployed persons")) # add multiple arguments support
)
# undata -> File contains data about global gdp
UNconfig <- list(
  "filepath" = getSystemConformPath('rawdata/undata/UNdata_Export_20190125_180059631.txt'), 
  "exportOptions" = list('folder' = 'clean_un_data', 'name' = 'gdp_data'),
  "geocolumn" = "Country.or.Area", 
  "options" = list("sep"=";", "header" = TRUE),
  "select" = c("Year","Item","Value","isocode")
)

# ADD import config to global config --> NOTE that the key is the name of the local environment
IMPORTconfig = list('GHO' = GHOconfig, 'EURO' = EUROconfig, 'UN' = UNconfig)

## Load import relevant environments
source('import_helper.R')
# Iterate over provider environments and make tidy data
for (provider in names(IMPORTconfig)) {
  # get variable as environment
  tempENV = get(provider)
  # Read environment dependent data, overloading the function is possible
  readData(
    IMPORTconfig[[provider]][['filepath']], 
    tempENV, 
    # add es many options, is an ... function
    sep = ifelse("sep" %in% names(IMPORTconfig[[provider]][['options']]), IMPORTconfig[[provider]][['options']][['sep']], ","), 
    header=as.logical(ifelse("header" %in% names(IMPORTconfig[[provider]][['options']]), IMPORTconfig[[provider]][['options']][['header']], FALSE))
    )
  # rename geocolumn for later join
  # first get a column matrix for all columns which matches the geocolumn metatag and 0 wehn there is no match
  i1 <- match(colnames(tempENV$data), IMPORTconfig[[provider]][['geocolumn']], nomatch = 0)
  # get te position of the first occurence of such a column
  index = match(c(max(i1, na.rm=TRUE)),i1)
  colnames(tempENV$data)[index] <- 'geolabel'
  # isoreferencing the data
  # Sadly the handling fo dplyr with variable representation of strings is not suitable for dynamic joining...
  # So we have to harmonize geocolumn and to pass a constant to the function...
  referencedData = isoref(tempENV$data, 'geolabel')
  # select the matched dataframe
  tempENV$data = referencedData[['matched']]
  # fix datatypes
  tempENV$fixDatatypes(tempENV)
  # only use in config described select columns
  tempENV$data = selectColumns(tempENV, IMPORTconfig[[provider]][['select']])
  # if a filter is defined in config, filter dynamically
  if("filter" %in% names(IMPORTconfig[[provider]])) {
    tempENV$data = filterValue(tempENV,IMPORTconfig[[provider]][['filter']][['cols']], IMPORTconfig[[provider]][['filter']][['conds']])
  }
  # write csv with config options
  writeCSV(tempENV$data,IMPORTconfig[[provider]][['exportOptions']])
}


