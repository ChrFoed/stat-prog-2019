# Devtools to build and install custom helper package
devtools::build(path='stat-prog-2019/isoreferencing')
devtools::install('stat-prog-2019/isoreferencing')

library(isoreferencing)
library(magrittr)
library(dplyr)

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
# isorefernece it via custom package
isorefEmploymentData = isoref(employment_data, "GEO")
matchedEmployment = as.data.frame(isorefEmploymentData[["matched"]])
print(head(matchedEmployment))
# Set Date element
# Use for time conversion if necessary
matchedEmployment %<>%
  mutate(TIME= format(as.character(matchedEmployment$TIME), "%Y"))
# split it up by the Workstatus, can be Population, active persons,....
dfWstatus = split(matchedEmployment, matchedEmployment$WSTATUS, drop = TRUE)
# iterate over list of splitted dataframe by workforce and assign dynamic variables by workforce
for(wstatus in dfWstatus){
  # Get used factor from dataframe, remove whitespace and lowercase it --> Inactive Person => inactive_person
  dfName = tolower(gsub(" ", "_", levels(droplevels(wstatus$WSTATUS)), fixed = TRUE))
  # Assign dataframe to dynamic created variable
  assign(dfName, wstatus)
  write.csv(wstatus, file = paste0("stat-prog-2019/data/clean_employment_data/",dfName,'.csv'))
}