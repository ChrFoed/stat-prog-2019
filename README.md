# stat-prog-2019
Repository for the statistical programming endproject

# Load EU Employment Data

## Rawdata Location:
Data is located in the folder rawdata_employment_eu, sadly it isn't automatic fetchable yet from the source

## Processing
Can be fetched by execute the import_employment_data.R 

## Dependencies
* custom isoreferencing package, has to be build with devtools, should be installed
* devtools
* magrittr
* dplyr

### Things to consider
* Process can have multile work status variables (WSTATUS)
* It should be not necessary to specify the language, custom iso ref package is multilingual
* data will be stored in data/clean_employment_data

# Additional Packages

## isoreferencing
Custom, selfmade package which uses data from the github repo world-countries (https://github.com/stefangabos/world_countries.git), Great thanks for that efford! It the exported function takes an dataframe and a column name and iterate over all languages and add the matched country-names alpha2 code to the input. 