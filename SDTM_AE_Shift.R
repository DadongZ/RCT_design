# AE domain
# ------------------------------------------------------------------------------
# Part 1: Create example SDTM AE domain data
# ------------------------------------------------------------------------------
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
# Create a function to generate SDTM AE data
create_ae_domain <- function(n_subjects = 30, study_id = "STUDY001") {
  
  # Subject IDs
  subject_ids <- sprintf("S%03d", 1:n_subjects)
  usubjids <- paste(study_id, subject_ids, sep = "-")
  
  # Generate random number of AEs per subject (1-5)
  ae_count_per_subject <- sample(1:5, n_subjects, replace = TRUE)
  
  # Create AE records
  ae_data <- data.frame()
  
  for (i in 1:n_subjects) {
    n_events <- ae_count_per_subject[i]
    
    for (j in 1:n_events) {
      # Random AE terms
      ae_terms <- c("HEADACHE", "NAUSEA", "DIZZINESS", "FATIGUE", "INSOMNIA", 
                    "VOMITING", "RASH", "DIARRHEA", "COUGH", "FEVER")
      
      # Random severity
      severity <- sample(c("MILD", "MODERATE", "SEVERE"), 1)
      
      # Random relationship to drug
      relationship <- sample(c("RELATED", "NOT RELATED", "POSSIBLY RELATED"), 1)
      
      # Random start date (between day 1 and day 30)
      start_day <- sample(1:30, 1)
      start_date <- as.Date("2024-01-01") + start_day
      
      # Random end date (between start date and day 40)
      end_date <- start_date + sample(1:15, 1)
      
      # Create AE record
      ae_record <- data.frame(
        STUDYID = study_id,
        DOMAIN = "AE",
        USUBJID = usubjids[i],
        AESEQ = j,
        AETERM = sample(ae_terms, 1),
        AESEV = severity,
        AESER = sample(c("Y", "N"), 1, prob = c(0.1, 0.9)),
        AEREL = relationship,
        AESTDTC = format(start_date, "%Y-%m-%d"),
        AEENDTC = format(end_date, "%Y-%m-%d"),
        stringsAsFactors = FALSE
      )
      
      ae_data <- rbind(ae_data, ae_record)
    }
  }
  
  return(ae_data)
}

# Create AE domain data
ae_data <- create_ae_domain()

# View the first few rows
head(ae_data)

# ------------------------------------------------------------------------------
# Part 2: Create example SDTM LB domain data
# ------------------------------------------------------------------------------

# Create a function to generate SDTM LB data
create_lb_domain <- function(n_subjects = 30, study_id = "STUDY001") {
  
  # Subject IDs
  subject_ids <- sprintf("S%03d", 1:n_subjects)
  usubjids <- paste(study_id, subject_ids, sep = "-")
  
  # Define lab tests
  lab_tests <- data.frame(
    LBTESTCD = c("ALT", "AST", "GLUC", "HGB", "PLAT", "WBC"),
    LBTEST = c("Alanine Aminotransferase", "Aspartate Aminotransferase", 
               "Glucose", "Hemoglobin", "Platelets", "White Blood Cell Count"),
    LBCAT = c("CHEMISTRY", "CHEMISTRY", "CHEMISTRY", "HEMATOLOGY", "HEMATOLOGY", "HEMATOLOGY"),
    LBSCAT = c("ENZYMES", "ENZYMES", "BIOCHEMISTRY", "HEMOGLOBIN", "DIFFERENTIAL", "DIFFERENTIAL"),
    LBSTRESU = c("U/L", "U/L", "mmol/L", "g/dL", "10^9/L", "10^9/L"),
    LBSTNRLO = c(10, 10, 3.9, 13, 150, 4),
    LBSTNRHI = c(40, 40, 7.1, 17, 400, 11),
    stringsAsFactors = FALSE
  )
  
  # Define visits
  visits <- data.frame(
    VISIT = c("SCREENING", "WEEK 4"),
    VISITNUM = c(1, 2),
    stringsAsFactors = FALSE
  )
  
  # Generate LB data
  lb_data <- data.frame()
  
  # Seq counter for the whole dataset
  seq_counter <- 1
  
  for (i in 1:n_subjects) {
    for (v in 1:nrow(visits)) {
      for (t in 1:nrow(lab_tests)) {
        # Random lab value with tendency to have more normal values
        # but some abnormal values too
        
        # For screening (baseline) - mostly normal values
        if (visits$VISITNUM[v] == 1) {
          z_score <- rnorm(1, mean = 0, sd = 0.8)  # Closer to normal range
        } else {
          # For week 4 (post-baseline) - potentially more abnormal values
          z_score <- rnorm(1, mean = 0, sd = 1.2)  # More spread out
        }
        
        # Calculate result based on reference range
        mid_range <- (lab_tests$LBSTNRLO[t] + lab_tests$LBSTNRHI[t]) / 2
        range_width <- lab_tests$LBSTNRHI[t] - lab_tests$LBSTNRLO[t]
        result <- mid_range + (z_score * range_width / 4)
        
        # Determine reference range indicator
        if (result < lab_tests$LBSTNRLO[t]) {
          nrind <- "LOW"
        } else if (result > lab_tests$LBSTNRHI[t]) {
          nrind <- "HIGH"
        } else {
          nrind <- "NORMAL"
        }
        
        # Convert to character for LBORRES with appropriate precision
        result_char <- sprintf("%.1f", result)
        
        # Generate random date based on visit
        if (visits$VISITNUM[v] == 1) {
          # Screening - days -14 to -1 before treatment start
          lb_date <- as.Date("2024-01-01") - sample(1:14, 1)
        } else {
          # Week 4 - days 25 to 35 after treatment start
          lb_date <- as.Date("2024-01-01") + sample(25:35, 1)
        }
        
        # Create LB record
        lb_record <- data.frame(
          STUDYID = study_id,
          DOMAIN = "LB",
          USUBJID = usubjids[i],
          LBSEQ = seq_counter,
          LBTESTCD = lab_tests$LBTESTCD[t],
          LBTEST = lab_tests$LBTEST[t],
          LBCAT = lab_tests$LBCAT[t],
          LBSCAT = lab_tests$LBSCAT[t],
          VISITNUM = visits$VISITNUM[v],
          VISIT = visits$VISIT[v],
          LBDTC = format(lb_date, "%Y-%m-%d"),
          LBORRES = result_char,
          LBORRESU = lab_tests$LBSTRESU[t],
          LBORNRLO = as.character(lab_tests$LBSTNRLO[t]),
          LBORNRHI = as.character(lab_tests$LBSTNRHI[t]),
          LBSTRESC = result_char,
          LBSTRESN = result,
          LBSTRESU = lab_tests$LBSTRESU[t],
          LBNRIND = nrind,
          stringsAsFactors = FALSE
        )
        
        lb_data <- rbind(lb_data, lb_record)
        seq_counter <- seq_counter + 1
      }
    }
  }
  
  # Add baseline flag
  lb_data <- lb_data %>%
    group_by(USUBJID, LBTESTCD) %>%
    mutate(LBBLFL = ifelse(VISITNUM == min(VISITNUM), "Y", ""))
  
  return(lb_data)
}

# Create LB domain data
lb_data <- create_lb_domain()

# View the first few rows
head(lb_data)

# ------------------------------------------------------------------------------
# Part 3: Create DM domain (Demographics) for treatment info
# ------------------------------------------------------------------------------

create_dm_domain <- function(n_subjects = 30, study_id = "STUDY001") {
  # Subject IDs
  subject_ids <- sprintf("S%03d", 1:n_subjects)
  usubjids <- paste(study_id, subject_ids, sep = "-")
  
  # Assign treatments
  treatment_groups <- sample(c("DRUG A", "PLACEBO"), n_subjects, replace = TRUE)
  
  # Generate demographics
  dm_data <- data.frame(
    STUDYID = study_id,
    DOMAIN = "DM",
    USUBJID = usubjids,
    SUBJID = subject_ids,
    ARM = treatment_groups,
    ACTARM = treatment_groups,
    SEX = sample(c("M", "F"), n_subjects, replace = TRUE),
    AGE = sample(18:80, n_subjects, replace = TRUE),
    RACE = sample(c("WHITE", "BLACK OR AFRICAN AMERICAN", "ASIAN"), 
                  n_subjects, replace = TRUE, prob = c(0.7, 0.2, 0.1)),
    RFSTDTC = "2024-01-01",  # Study start date
    stringsAsFactors = FALSE
  )
  
  return(dm_data)
}

# Create DM domain data
dm_data <- create_dm_domain()

# View the first few rows
head(dm_data)

# ------------------------------------------------------------------------------
# Part 4: Create ADaM datasets (ADSL and ADLB) for analysis
# ------------------------------------------------------------------------------

# Create ADSL (Subject-Level Analysis Dataset)
adsl <- dm_data %>%
  select(STUDYID, USUBJID, SUBJID, SEX, AGE, RACE, ARM, ACTARM) %>%
  mutate(
    SAFFL = "Y",  # Safety flag (all subjects)
    TRTSDT = as.Date("2024-01-01"),  # Treatment start date
    TRTEDT = as.Date("2024-01-01") + 56,  # Treatment end date (8 weeks)
    TRT01P = ARM,
    TRT01A = ACTARM,
    TRT01PN = ifelse(ARM == "DRUG A", 1, 2),
    TRT01AN = ifelse(ACTARM == "DRUG A", 1, 2)
  )

# Create ADLB (Laboratory Analysis Dataset)
adlb <- lb_data %>%
  # Add treatment start date (assuming all subjects started on 2024-01-01)
  mutate(
    TRTSDT = as.Date("2024-01-01"),
    ADT = as.Date(LBDTC),
    PARAM = LBTEST,
    PARAMCD = LBTESTCD,
    AVAL = LBSTRESN,
    AVALU = LBSTRESU,
    ADY = as.integer(ADT - TRTSDT),
    AVISIT = VISIT,
    AVISITN = VISITNUM,
    AVALCAT1 = LBNRIND,
    AVALCAT1N = case_when(
      AVALCAT1 == "LOW" ~ 1,
      AVALCAT1 == "NORMAL" ~ 2,
      AVALCAT1 == "HIGH" ~ 3
    )
  ) %>%
  left_join(
    adsl %>% select(USUBJID, TRT01A, TRT01P, TRT01AN, TRT01PN),
    by = "USUBJID"
  )

# Add baseline info
adlb <- adlb %>%
  group_by(USUBJID, PARAMCD) %>%
  mutate(
    ABLFL = ifelse(LBBLFL == "Y", "Y", ""),
    BASE = ifelse(ABLFL == "Y", AVAL, NA),
    BASEC = ifelse(ABLFL == "Y", LBNRIND, NA)
  ) %>%
  fill(BASE, BASEC) %>%
  ungroup() %>%
  mutate(
    CHG = AVAL - BASE,
    PCHG = 100 * CHG / BASE,
    BASECAT1 = BASEC,
    BASECAT1N = case_when(
      BASECAT1 == "LOW" ~ 1,
      BASECAT1 == "NORMAL" ~ 2,
      BASECAT1 == "HIGH" ~ 3
    ),
    ANL01FL = "Y"  # Analysis flag
  )

# ------------------------------------------------------------------------------
# Part 5: Create laboratory shift tables
# ------------------------------------------------------------------------------

# Function to create a shift table for a specific lab parameter
create_shift_table <- function(data, param_code) {
  # Filter data for the parameter and post-baseline records
  shift_data <- data %>%
    filter(PARAMCD == param_code, VISITNUM > 1, ANL01FL == "Y")
  
  # Get subject counts for treatment groups
  n_by_trt <- shift_data %>%
    group_by(TRT01PN, TRT01P) %>%
    summarize(N = n_distinct(USUBJID), .groups = "drop")
  
  # Create the shift counts
  shift_counts <- shift_data %>%
    group_by(TRT01PN, TRT01P, BASECAT1, AVALCAT1) %>%
    summarize(count = n_distinct(USUBJID), .groups = "drop")
  
  # Calculate row totals (by baseline category)
  base_totals <- shift_counts %>%
    group_by(TRT01PN, TRT01P, BASECAT1) %>%
    summarize(count = sum(count), .groups = "drop") %>%
    mutate(AVALCAT1 = "TOTAL")
  
  # Calculate column totals (by post-baseline category)
  post_totals <- shift_counts %>%
    group_by(TRT01PN, TRT01P, AVALCAT1) %>%
    summarize(count = sum(count), .groups = "drop") %>%
    mutate(BASECAT1 = "TOTAL")
  
  # Calculate grand total
  grand_total <- base_totals %>%
    group_by(TRT01PN, TRT01P) %>%
    summarize(count = sum(count), .groups = "drop") %>%
    mutate(BASECAT1 = "TOTAL", AVALCAT1 = "TOTAL")
  
  # Combine all counts
  all_counts <- bind_rows(shift_counts, base_totals, post_totals, grand_total)
  
  # Add percentages
  all_counts_with_pct <- all_counts %>%
    left_join(n_by_trt, by = c("TRT01PN", "TRT01P")) %>%
    mutate(
      pct = round(count / N * 100, 1),
      count_pct = paste0(count, " (", pct, "%)")
    )
  
  # Create formatted shift table
  shift_table <- all_counts_with_pct %>%
    select(TRT01PN, TRT01P, BASECAT1, AVALCAT1, count_pct) %>%
    arrange(TRT01PN, BASECAT1, AVALCAT1) %>%
    pivot_wider(
      names_from = AVALCAT1,
      values_from = count_pct,
      names_prefix = "Post_",
      values_fill = "0 (0.0%)"
    ) %>%
    arrange(TRT01PN)
  
  # Get parameter name
  param_name <- unique(data$PARAM[data$PARAMCD == param_code])[1]
  
  return(list(
    shift_table = shift_table,
    param_name = param_name
  ))
}

# Create shift tables for Hemoglobin (HGB) and ALT
hgb_shift <- create_shift_table(adlb, "HGB")
alt_shift <- create_shift_table(adlb, "ALT")

# Display shift tables
cat("=========================================================\n")
cat("Shift Table for", hgb_shift$param_name, "\n")
cat("=========================================================\n")
print(hgb_shift$shift_table)

cat("\n=========================================================\n")
cat("Shift Table for", alt_shift$param_name, "\n")
cat("=========================================================\n")
print(alt_shift$shift_table)

# ------------------------------------------------------------------------------
# Part 6: Create formatted HTML shift tables
# ------------------------------------------------------------------------------

# Function to format shift table for display
format_shift_table <- function(shift_result) {
  shift_result$shift_table %>%
    select(-TRT01PN) %>%
    kable(
      caption = paste("Shift Table for", shift_result$param_name),
      format = "html"
    ) %>%
    kable_styling(
      bootstrap_options = c("striped", "hover", "condensed", "responsive"),
      full_width = FALSE
    ) %>%
    add_header_above(
      c(" " = 2, "Post-Baseline Category" = 4)
    ) %>%
    column_spec(1, bold = TRUE) %>%
    collapse_rows(columns = 1)
}

# Format and display shift tables (would display in an HTML output)
# In an interactive R environment, these would render as HTML tables
hgb_table <- format_shift_table(hgb_shift)
alt_table <- format_shift_table(alt_shift)

# ------------------------------------------------------------------------------
# Part 7: Visualize the shift patterns
# ------------------------------------------------------------------------------

# Function to create a heatmap visualization of shifts
visualize_shifts <- function(data, param_code) {
  # Filter data for the parameter and post-baseline records
  shift_data <- data %>%
    filter(PARAMCD == param_code, VISITNUM > 1, ANL01FL == "Y")
  
  # Get parameter name
  param_name <- unique(shift_data$PARAM)[1]
  
  # Create a count dataset for visualization
  viz_data <- shift_data %>%
    group_by(TRT01P, BASECAT1, AVALCAT1) %>%
    summarize(count = n_distinct(USUBJID), .groups = "drop") %>%
    # Ensure all categories are included even with zero count
    ungroup() %>%
    complete(
      TRT01P, 
      BASECAT1 = c("LOW", "NORMAL", "HIGH"),
      AVALCAT1 = c("LOW", "NORMAL", "HIGH"),
      fill = list(count = 0)
    )
  
  # Create a heatmap
  ggplot(viz_data, aes(x = BASECAT1, y = AVALCAT1, fill = count)) +
    geom_tile(color = "white") +
    geom_text(aes(label = count), color = "black") +
    scale_fill_gradient(low = "white", high = "steelblue") +
    facet_wrap(~TRT01P) +
    labs(
      title = paste("Shift Pattern for", param_name),
      x = "Baseline Category",
      y = "Post-Baseline Category",
      fill = "Count"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5),
      axis.text = element_text(size = 10),
      axis.title = element_text(size = 12),
      legend.position = "right"
    )
}

# Create visualization for HGB and ALT
# These would display in an interactive R environment
hgb_viz <- visualize_shifts(adlb, "HGB")
alt_viz <- visualize_shifts(adlb, "ALT")