# Exercise 2 - Calculate n(%) for AE's 
library(Tplyr)
library(haven)
library(dplyr)

# Read in datasets 
adsl <- read_xpt("r-pharma2022/datasets/ADAM/adsl.xpt")
adae <- read_xpt("r-pharma2022/datasets/ADAM/adae.xpt") 
adaette <- read_xpt("r-pharma2022/datasets/ADAM/adaette.xpt") 
adpft <- read_xpt("r-pharma2022/datasets/ADAM/adpft.xpt") 
preadsl <- read_xpt("r-pharma2022/datasets/ADAM/preadsl.xpt") 


# A) ----------------------------------------------------------------------
# Calculate the number and percentage of *unique* subjects with at least one AE
# by AEBODSYS, AETERM, and treatment (hint: you will need to use multiple target
# variables in `group_count`)
?set_distinct_by

tplyr_table(adae, TRT01A) %>%
  set_pop_data(adsl)

# B) ----------------------------------------------------------------------
# Calculate the number and percentage of *unique* subjects with any AE
# by adding an additional count layer to the code from 5B. Also add a total
# treatment group. 

ae <- read_xpt("r-pharma2022/datasets/SDTM/ae.xpt")
dm <- read_xpt("r-pharma2022/datasets/SDTM/dm.xpt")
ex <- read_xpt("r-pharma2022/datasets/SDTM/ex.xpt")
re <- read_xpt("r-pharma2022/datasets/SDTM/re.xpt")
sv <- read_xpt("r-pharma2022/datasets/SDTM/sv.xpt")
tv <- read_xpt("r-pharma2022/datasets/SDTM/tv.xpt")
vs <- read_xpt("r-pharma2022/datasets/SDTM/vs.xpt")
