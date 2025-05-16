
library(sdtm.oak)

cm_raw <- read.csv(system.file("raw_data/cm_raw_data.csv",
                               package = "sdtm.oak"
))

cm_raw <- cm_raw %>%
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "cm_raw"
  )

dm <- read.csv(system.file("raw_data/dm.csv",
                           package = "sdtm.oak"
))
