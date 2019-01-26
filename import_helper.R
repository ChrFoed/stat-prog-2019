## Description
# Import Config: (Goal is to define properties globally to make an harmonized dataset)
parseConfig = list('decimals' = 2)
# File contains import relevant function which will be accessed over the import controller
# Create environments for each importer
GHO <- new.env()
EURO <- new.env()
UN <- new.env()

######################### GLOBAL FUNCTIONS ####################################
# No need for adding to an special provider environment, because they don't 
# need any specialisation

# Read csv base functions can beo overloaded to dynamically enhance csv parsing
readData <- function (filepath,ENV, ...) {
  rData = try(read.csv(filepath, ...))
  if(class(rData) == 'try-error') {
    log('Failure during Reading GHO Data')
  } else {
    ENV$data = rData
  }
}

##Column cleaning
# Description:
# In this part for every source a function for clumn cleaning ia available
selectColumns <- function (env, vColumns) {
  env$data %<>%
    select(vColumns)
  # We remove NA values from here becasue replacing it with zero makes no sense....
}
# filter value base on a dynamic
filterValue <- function(env, cols, conds) {
  fp <- map2(cols, conds, function(x, y) quo((!!(as.name(x))) %in% !!y))
  env$data %<>%
    filter(!!!fp)
}

writeCSV <- function(data, config) {
  if(!dir.exists(file.path('data', config[['folder']])))
    dir.create(file.path('data',config[['folder']]), showWarnings = FALSE)
  write.csv(data, file = paste0(getwd(),"/data/",config[['folder']],"/",config[['name']],".csv"))
}

########################## Environment attached functions ##################
# This functions are named the same but for individualsarion they are 
# attahced to their environemnet

##Datatype claening
# Description:
# In this part for every source a function for DataType cleaning is available
GHO$fixDatatypes <- function (env) {
  # We remove NA values from here becasue replacing it with zero makes no sense....
  env$data %<>% 
    na.omit()
}
EURO$fixDatatypes <- function (env) {
  # replace all number formattin 5,432.10 to 5432.10 and cast it to double
  # mutate all NA values to zero
  env$data %<>%
    mutate(Value= as.double(gsub(",","",Value))) %>%
    mutate(Value= if_else(is.na(.$Value),0, .$Value)) %>%
    mutate(Value= round(.$Value, parseConfig[['decimals']]))
}
UN$fixDatatypes <- function (env) {
  env$data %<>%
    mutate(Value= if_else(is.na(.$Value),0, .$Value)) %>%
    mutate(Value= round(.$Value, parseConfig[['decimals']]))
}
