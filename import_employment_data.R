# Devtools to build and install custom helper package
devtools::build(path='stat-prog-2019/isoreferencing')
devtools::install('stat-prog-2019/isoreferencing')

library(isoreferencing)
library(magrittr)
library(dplyr)
library(ggplot2)

# Path for eu employmnet data
filePath = 'stat-prog-2019/rawdata_employment_eu/lfsa_pganws_1_Data.csv'

# Create directories if the don't exist
if(!dir.exists(file.path('stat-prog-2019', 'data')))
  dir.create(file.path('stat-prog-2019','data'), showWarnings = FALSE)
# Create directories if the don't exist
if(!dir.exists(file.path('stat-prog-2019/data', 'clean_employment_data')))
  dir.create(file.path('stat-prog-2019/data','clean_employment_data'), showWarnings = FALSE)

# Load employment data eu
employment_data = read.csv(filePath,encoding="UTF-8")
str(employment_data)
# isorefernece it via custom package
isorefEmploymentData = isoref(employment_data, "GEO")
matchedEmployment = as.data.frame(isorefEmploymentData[["matched"]])
# Set Date element
# Use for time conversion if necessary
matchedEmployment %<>%
  mutate(TIME= format(as.character(matchedEmployment$TIME), "%Y"))
# make value an actual value of the format 0,000.3
matchedEmployment %<>%
  mutate(Value= as.double(gsub(",","",Value))*1000)
# Replace all NA withs with 0
matchedEmployment$Value[is.na(matchedEmployment$Value)] = 0
head(matchedEmployment)
# split it up by the Workstatus, can be Population, active persons,....
dfWstatus = split(matchedEmployment, matchedEmployment$WSTATUS, drop = TRUE)
# List for variable name
variableStorage = list()
# listvariable position
pos = 0
# iterate over list of splitted dataframe by workforce and assign dynamic variables by workforce
for(wstatus in dfWstatus){ 
  # Get used factor from dataframe, remove whitespace and lowercase it --> Inactive Person => inactive_person
  dfName = tolower(gsub(" ", "_", levels(droplevels(wstatus$WSTATUS)), fixed = TRUE))
  # Assign dataframe to dynamic created variable
  assign(dfName, wstatus)
  # assign variable to list to make it accesible later on
  variableStorage[(pos = pos+1)] = dfName 
  # Write data to file
  write.csv(wstatus, file = paste0("stat-prog-2019/data/clean_employment_data/",dfName,'.csv'))
}

## Create key frames of the differen work stati
for(variable in variableStorage){ 
  currentDataset = get(variable)
  print(variable)
  currentDataset %>%
    ggplot(aes(x=TIME, y=Value, title = paste0('Work status: ',variable))) + 
    geom_jitter(alpha=0.5) +
    geom_smooth() +
    facet_wrap( ~ GEO, scales = "free_x")
}

# Get Key facts from data, would be TIME, WS_STATUS and 

