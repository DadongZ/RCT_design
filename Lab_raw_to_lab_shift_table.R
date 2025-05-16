## ================================================================
## From Raw Lab Data to SDTM LB Domain and Shift Tables Using R
## ================================================================

## Install required packages if not already installed
## Load required libraries
library(admiral)
library(dplyr)
library(ggplot2)
library(lubridate)
library(stringr)
library(tidyr)
library(conflicted)
conflicts_prefer(dplyr::filter())

## ==============================================
## STEP 1: Create Sample Raw Laboratory Data
## ==============================================

# Create a sample study ID
study_id <- "STUDY001"

# Raw lab data in a CSV-like format
raw_lab_data <- tibble(
  STUDYID = study_id,
  SUBJID = rep(c("001", "002", "003"), each = 4),
  VISIT = rep(rep(c("SCREENING", "WEEK 4"), each = 2), 3),
  LBTEST = rep(c("Hemoglobin", "Platelets"), 6),
  LBORRESU = rep(c("g/dL", "10^9/L"), 6),
  LBRESULT = c(
    # Subject 001
    14.2, 210, 13.8, 195,
    # Subject 002
    12.1, 140, 12.5, 132,
    # Subject 003
    15.6, 300, 17.2, 415
  ),
  LBDTC = rep(c("2024-10-01", "2024-10-01", "2024-10-29", "2024-10-29",
                "2024-10-03", "2024-10-03", "2024-10-31", "2024-10-31",
                "2024-10-02", "2024-10-02", "2024-10-30", "2024-10-30")),
  LBSTNRLO = rep(c(13.0, 150), 6),
  LBSTNRHI = rep(c(17.0, 400), 6)
)

# Create a sample demographics dataset
dm <- tibble(
  STUDYID = study_id,
  USUBJID = paste(study_id, c("001", "002", "003"), sep = "-"),
  SUBJID = c("001", "002", "003"),
  RFSTDTC = c("2024-10-15", "2024-10-17", "2024-10-16"),
  ARM = c("Drug A", "Drug A", "Drug B"),
  ACTARM = c("Drug A", "Drug A", "Drug B"),
  SEX = c("M", "F", "M"),
  AGE = c(45, 52, 38),
  AGEU = rep("YEARS", 3),
  RACE = c("WHITE", "BLACK OR AFRICAN AMERICAN", "WHITE"),
  ETHNIC = c("NOT HISPANIC OR LATINO", "NOT HISPANIC OR LATINO", "HISPANIC OR LATINO")
)

## =========================================================
## STEP 2: Transform Raw Lab Data to SDTM LB Domain Format
## =========================================================

# Create USUBJID by combining STUDYID and SUBJID
lb_data <- raw_lab_data %>%
  mutate(USUBJID = paste(STUDYID, SUBJID, sep = "-"))

# Map raw lab test names to SDTM standard values
lab_test_mapping <- tibble(
  LBTEST = c("Hemoglobin", "Platelets"),
  LBTESTCD = c("HGB", "PLAT"),
  LBCAT = c("HEMATOLOGY", "HEMATOLOGY"),
  LBSCAT = c("", "")
)

# Join the lab test mapping to the lab data
lb_data <- lb_data %>%
  left_join(lab_test_mapping, by = "LBTEST")

# Create VISITNUM from VISIT
visit_mapping <- tibble(
  VISIT = c("SCREENING", "WEEK 4"),
  VISITNUM = c(1, 2)
)

lb_data <- lb_data %>%
  left_join(visit_mapping, by = "VISIT")

# Add standard SDTM variables
lb_data <- lb_data %>%
  rename(
    LBORRES = LBRESULT,
    LBORNRLO = LBSTNRLO,
    LBORNRHI = LBSTNRHI
  ) %>%
  mutate(
    # Standard result and unit variables
    LBSTRESC = as.character(LBORRES),
    LBSTRESN = as.numeric(LBORRES),
    LBSTRESU = LBORRESU,
    
    # Convert date string to date
    LBDTC = as.character(LBDTC),
    
    # Calculate normalized reference ranges indicator
    LBNRIND = case_when(
      LBSTRESN < LBORNRLO ~ "LOW",
      LBSTRESN > LBORNRHI ~ "HIGH",
      TRUE ~ "NORMAL"
    ),
    
    # Derive sequence number 
    LBSEQ = row_number()
  ) %>%
  # Add domain identifier
  mutate(DOMAIN = "LB")

# Select SDTM LB variables in standard order
lb_sdtm <- lb_data %>%
  select(
    STUDYID, DOMAIN, USUBJID, LBSEQ, LBTESTCD, LBTEST, LBCAT, LBSCAT, 
    VISITNUM, VISIT, LBDTC, LBORRES, LBORRESU, LBORNRLO, LBORNRHI, 
    LBSTRESC, LBSTRESN, LBSTRESU, LBNRIND
  )

# Print the SDTM LB dataset
print("SDTM LB Domain Data:")
head(lb_sdtm)

## =========================================================
## STEP 3: Create ADaM ADSL and ADLB Datasets using admiral
## =========================================================

# First create ADSL (Subject-Level Analysis Dataset)
adsl <- dm %>%
  # Derive treatment variables using admiral
  mutate(
    SAFFL = "Y",  # All subjects are in safety population for this example
    TRTSDT = ymd(RFSTDTC),
    TRTEDT = ymd(RFSTDTC) + days(28),  # Assuming 28-day treatment period
    TRT01P = ARM,
    TRT01A = ACTARM,
    TRT01PN = case_when(
      TRT01P == "Drug A" ~ 1,
      TRT01P == "Drug B" ~ 2
    ),
    TRT01AN = case_when(
      TRT01A == "Drug A" ~ 1,
      TRT01A == "Drug B" ~ 2
    )
  )

# Print ADSL dataset
print("ADSL Dataset:")
head(adsl)

# Now create ADLB (Laboratory Analysis Dataset)
# First convert LB dates from character to date
adlb_start <- lb_sdtm %>%
  mutate(
    ADT = ymd(LBDTC),
    PARAM = LBTEST,
    PARAMCD = LBTESTCD,
    AVAL = LBSTRESN,
    AVALU = LBSTRESU
  )

# Merge with ADSL to get treatment information
adlb_with_trt <- adlb_start %>%
  inner_join(
    adsl %>% select(USUBJID, TRTSDT, TRTEDT, TRT01P, TRT01A, TRT01PN, TRT01AN),
    by = "USUBJID"
  )

# Derive relative day (study day)
adlb <- adlb_with_trt %>%
  mutate(
    ADY = as.integer(ADT - TRTSDT),
    
    # Derive treatment period
    APERIOD = case_when(
      ADT < TRTSDT ~ "SCREENING",
      ADT <= TRTEDT ~ "TREATMENT",
      TRUE ~ "FOLLOW-UP"
    ),
    
    # Add analysis visit
    AVISIT = VISIT,
    AVISITN = VISITNUM,
    
    # Create categorical variables for analysis
    AVALCAT1 = LBNRIND,
    AVALCAT1N = case_when(
      AVALCAT1 == "LOW" ~ 1,
      AVALCAT1 == "NORMAL" ~ 2, 
      AVALCAT1 == "HIGH" ~ 3
    )
  )

# Identify baseline records (the last record before treatment start)
adlb <- adlb %>%
  group_by(USUBJID, PARAMCD) %>%
  mutate(
    # Flag the baseline record
    ABLFL = ifelse(ADT < TRTSDT & ADT == max(ADT[ADT < TRTSDT]), "Y", ""),
    
    # Create baseline values
    BASE = ifelse(ABLFL == "Y", AVAL, NA),
    BASEC = ifelse(ABLFL == "Y", LBNRIND, NA)
  ) %>%
  # Fill the baseline values for all records of the same subject/parameter
  fill(BASE, BASEC) %>%
  ungroup() %>%
  mutate(
    # Derive change from baseline
    CHG = AVAL - BASE,
    
    # Add baseline categorical variables
    BASECAT1 = BASEC,
    BASECAT1N = case_when(
      BASECAT1 == "LOW" ~ 1,
      BASECAT1 == "NORMAL" ~ 2,
      BASECAT1 == "HIGH" ~ 3
    ),
    
    # Add analysis flags
    ANL01FL = "Y"  # All records included in the analysis
  )

# Print ADLB dataset
print("ADLB Dataset:")
head(adlb)

## =========================================================
## STEP 4: Create Laboratory Shift Tables
## =========================================================

# Subset to post-baseline records for shift analysis
adlb_post <- adlb %>%
  dplyr::filter(ADT >= TRTSDT)  # Only post-treatment records

# Create a function to generate shift table
create_shift_table <- function(adlb_dataset, parameter_code) {
  
  # Filter for the specified parameter
  param_data <- adlb_dataset %>%
    dplyr::filter(PARAMCD == parameter_code)
  
  # Get subject counts for the treatment groups (like "Big N")
  n_by_trt <- param_data %>%
    group_by(TRT01PN, TRT01P) %>%
    summarize(N = n_distinct(USUBJID), .groups = "drop")
  
  # Create the shift counts
  shift_counts <- param_data %>%
    group_by(TRT01PN, TRT01P, BASECAT1, AVALCAT1) %>%
    summarize(count = n_distinct(USUBJID), .groups = "drop")
  
  # Calculate row totals (total by baseline category)
  baseline_totals <- shift_counts %>%
    group_by(TRT01PN, TRT01P, BASECAT1) %>%
    summarize(count = sum(count), .groups = "drop") %>%
    mutate(AVALCAT1 = "TOTAL")
  
  # Calculate column totals (total by post-baseline category)
  postbase_totals <- shift_counts %>%
    group_by(TRT01PN, TRT01P, AVALCAT1) %>%
    summarize(count = sum(count), .groups = "drop") %>%
    mutate(BASECAT1 = "TOTAL")
  
  # Calculate the grand total
  grand_totals <- baseline_totals %>%
    group_by(TRT01PN, TRT01P) %>%
    summarize(count = sum(count), .groups = "drop") %>%
    mutate(BASECAT1 = "TOTAL", AVALCAT1 = "TOTAL")
  
  # Combine all totals with the main counts
  shift_table <- bind_rows(shift_counts, baseline_totals, postbase_totals, grand_totals)
  
  # Add percentages
  shift_table <- shift_table %>%
    left_join(n_by_trt, by = c("TRT01PN", "TRT01P")) %>%
    mutate(
      pct = round(count / N * 100, 1),
      count_pct = paste0(count, " (", pct, "%)")
    )
  
  # Create a proper cross-tabulation
  shift_cross_tab <- shift_table %>%
    select(TRT01PN, TRT01P, BASECAT1, AVALCAT1, count_pct) %>%
    pivot_wider(
      names_from = AVALCAT1,
      values_from = count_pct,
      names_prefix = "Post_",
      values_fill = "0 (0.0%)"
    )
  
  # Return the shift table
  return(shift_cross_tab)
}

# Create shift tables for Hemoglobin (HGB) and Platelets (PLAT)
hgb_shift <- create_shift_table(adlb_post, "HGB")
plat_shift <- create_shift_table(adlb_post, "PLAT")

# Print the shift tables
print("Hemoglobin Shift Table:")
print(hgb_shift)

print("Platelets Shift Table:")
print(plat_shift)

## =========================================================
## STEP 5: Visualize Shift Data
## =========================================================

# Function to visualize shifts
visualize_shifts <- function(adlb_dataset, parameter_code) {
  # Filter for the specified parameter
  param_data <- adlb_dataset %>%
    dplyr::filter(PARAMCD == parameter_code)
  
  # Create a cleaner dataset for visualization
  viz_data <- param_data %>%
    select(USUBJID, TRT01P, PARAM, BASECAT1, AVALCAT1) %>%
    mutate(
      # Ensure categories are properly ordered
      BASECAT1 = factor(BASECAT1, levels = c("LOW", "NORMAL", "HIGH")),
      AVALCAT1 = factor(AVALCAT1, levels = c("LOW", "NORMAL", "HIGH"))
    )
  
  # Create a heatmap of shifts
  ggplot(viz_data, aes(x = BASECAT1, y = AVALCAT1, fill = ..count..)) +
    geom_count(aes(size = ..count..), alpha = 0.7) +
    facet_wrap(~TRT01P) +
    scale_size_continuous(range = c(3, 10)) +
    scale_fill_gradient(low = "lightblue", high = "darkblue") +
    labs(
      title = paste("Shift Pattern for", unique(param_data$PARAM)),
      x = "Baseline Category",
      y = "Post-Baseline Category",
      size = "Count",
      fill = "Count"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5),
      axis.text = element_text(size = 10),
      axis.title = element_text(size = 12),
      legend.position = "bottom"
    )
}

# Visualize shifts for Hemoglobin and Platelets
hgb_plot <- visualize_shifts(adlb_post, "HGB")
plat_plot <- visualize_shifts(adlb_post, "PLAT")

# Print plots (these would be displayed in an interactive R environment)
print("Plots would be displayed in an interactive R environment")

## =========================================================
## BONUS: Using admiral Specific Functions for Shift Tables
## =========================================================

# This section demonstrates how to use admiral's specific functions
# for creating shift tables if they were used directly

# Convert to proper admiral dataset format
adlb_admiral <- adlb %>%
  # Add required variables for admiral functions
  mutate(
    STUDYID = STUDYID,
    PARAMCD = PARAMCD,
    PARAM = PARAM,
    AVAL = AVAL,
    AVALCAT1 = AVALCAT1,
    AVALCAT1N = AVALCAT1N,
    BASETYPE = "LAST",  # Indicating we're using the last value before treatment
    BASECAT1 = BASECAT1,
    BASECAT1N = BASECAT1N,
    ANL01FL = ANL01FL,
    TRTP = TRT01P,
    TRTPN = TRT01PN
  )

# Create shift table using admiral functions
# Note: In reality, you would use functions like count_values from admiral
# but here we're simulating the approach

adlb_shift_count <- adlb_post %>%
  # Filter for analysis records
  dplyr::filter(ANL01FL == "Y") %>%
  # Group by treatment, parameter, and categories
  group_by(TRT01PN, TRT01P, PARAMCD, PARAM, BASECAT1, AVALCAT1) %>%
  # Count unique subjects
  summarize(n = n_distinct(USUBJID), .groups = "drop")

# Format for display
adlb_shift_display <- adlb_shift_count %>%
  pivot_wider(
    id_cols = c(TRT01PN, TRT01P, PARAMCD, PARAM, BASECAT1),
    names_from = AVALCAT1,
    values_from = n,
    values_fill = 0
  )

# Print admiral-style shift table
print("Admiral-style Shift Table:")
print(adlb_shift_display)


