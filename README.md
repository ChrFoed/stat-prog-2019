# stat-prog-2019
Repository for the statistical programming endproject

# Load Data

## Rawdata Location:
Data is located in the folder rawdata, sadly it isn't automatic fetchable yet from the source

## Processingdata
will be processed by import_controller.R

## Dependencies
* custom isoreferencing package, has to be build with devtools, should be installed
* devtools
* magrittr
* dplyr

### Things to consider
* Take a look into the import_controller.R to change the sourceconfigs
* It should be not necessary to specify the language for the countrynames, custom iso ref package is multilingual
* data will be stored in data/... --> defined by the sourceconfig

# Additional Packages

## isoreferencing
Custom, selfmade package which uses data from the github repo world-countries (https://github.com/stefangabos/world_countries.git), Great thanks for that efford! It the exported function takes an dataframe and a column name and iterate over all languages and add the matched country-names alpha2 code to the input. 
