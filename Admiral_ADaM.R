library(admiral)
library(admiral.test)
library(admiralonco)
library(pharmaversesdtm) # data packages
library(pharmaverseadam) # data packages
library(sdtm.terminology)
library(lubridate)
library(stringr)
library(tidyverse)
library(metacore)
library(metatools)
library(xportr)


# Functions which derive a dedicated variable start with derive_var_ followed by the variable name, e.g., derive_var_trtdurd() derives the TRTDURD variable.
# 
# Functions which can derive multiple variables start with derive_vars_ followed by the variable name, e.g., derive_vars_dtm() can derive both the TRTSDTM and TRTSTMF variables.
# 
# Functions which derive a dedicated parameter start with derive_param_ followed by the parameter name, e.g., derive_param_bmi() derives the BMI parameter.


# Read in SDTM datasets
dm <- pharmaversesdtm::dm
ds <- pharmaversesdtm::ds
ex <- pharmaversesdtm::ex
vs <- pharmaversesdtm::vs
admiral_adsl <- admiral::admiral_adsl

ex_ext <- ex %>%
  derive_vars_dtm(
    dtc = EXSTDTC,
    new_vars_prefix = "EXST"
  )

vs <- vs %>%
  dplyr::filter(
    USUBJID %in% c(
      "01-701-1015", "01-701-1023", "01-703-1086",
      "01-703-1096", "01-707-1037", "01-716-1024"
    ) &
      VSTESTCD %in% c("SYSBP", "DIABP") &
      VSPOS == "SUPINE"
  )

adsl <- admiral_adsl %>%
  select(-TRTSDTM, -TRTSTMF)

advs <- vs %>%
  mutate(
    PARAM = VSTEST, PARAMCD = VSTESTCD, AVAL = VSSTRESN, AVALU = VSORRESU,
    AVISIT = VISIT, AVISITN = VISITNUM
  )

adsl <- adsl %>%
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = !is.na(EXSTDTM),
    new_vars = exprs(TRTSDTM = EXSTDTM, TRTSTMF = EXSTTMF),
    order = exprs(EXSTDTM, EXSEQ),
    mode = "first",
    by_vars = exprs(STUDYID, USUBJID)
  )
