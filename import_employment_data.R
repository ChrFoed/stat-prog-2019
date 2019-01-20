devtools::load(path='project/isoreferencing')
devtools::install('project/isoreferencing')
library(isoreferencing)

# Load employment data eu
employment_data = read.csv('project/employment_eu/lfsa_pganws_1_Data.csv',encoding="UTF-8")
isorefEmploymenttData = isoref(employment_data, "GEO")
# Georeference

# Returns a list of dataframe seperated by Wstatus
dfWstatus = split(employment_data, employment_data$WSTATUS)